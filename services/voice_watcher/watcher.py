#!/usr/bin/env python3
# ARK v3.1.1 | Module: Voice Note Watcher
# Classification: INTERNAL
# Purpose: Monitor input directory for audio files and process via transcription/summarization

import sys
import time
import json
import requests
from datetime import datetime
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# ARK v3.1.1: Use centralized configuration and logging
sys.path.insert(0, str(Path(__file__).parent.parent.parent))
from lib.config import (
    MODEL_CHAT, MODEL_CODER, MODEL_VISION, MODEL_EMBEDDING,
    OLLAMA_HOST, INPUT_DIR, OUTPUT_DIR, PROCESSED_DIR
)
from lib.logger import setup_logger
from lib.telemetry import capture_exception, capture_message

# Initialize structured logger
logger = setup_logger(__name__)

# Try to import Whisper (optional - will use Ollama if not available)
try:
    from faster_whisper import WhisperModel
    WHISPER_AVAILABLE = True
except ImportError:
    try:
        import whisper
        WHISPER_AVAILABLE = True
        WHISPER_TYPE = "openai"
    except ImportError:
        WHISPER_AVAILABLE = False
        logger.warning("Whisper not available. Will use Ollama for transcription (slower).")

SUPPORTED_EXTENSIONS = {".m4a", ".mp3", ".wav", ".ogg"}

# Ensure directories exist
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
PROCESSED_DIR.mkdir(parents=True, exist_ok=True)


class AudioFileHandler(FileSystemEventHandler):
    """Handles new audio file events."""
    
    def __init__(self):
        self.processed_files = set()
    
    def on_created(self, event):
        """Called when a new file is created."""
        if event.is_directory:
            return
        
        file_path = Path(event.src_path)
        
        # Check if it's a supported audio file
        if file_path.suffix.lower() not in SUPPORTED_EXTENSIONS:
            return
        
        # Avoid processing the same file multiple times
        if str(file_path) in self.processed_files:
            return
        
        # Wait a moment for file to be fully written
        time.sleep(2)
        
        # Check if file still exists and is readable
        if not file_path.exists() or not file_path.is_file():
            return
        
        # Mark as processed
        self.processed_files.add(str(file_path))
        
        # Process the file
        self.process_audio_file(file_path)
    
    def transcribe_audio(self, file_path: Path) -> str:
        """Transcribe audio file to text using Whisper or Ollama."""
        logger.info(f"Transcribing audio file: {file_path.name}")
        
        # Try Whisper first (faster, more accurate)
        if WHISPER_AVAILABLE:
            try:
                if 'WHISPER_TYPE' in globals() and WHISPER_TYPE == "openai":
                    # OpenAI Whisper
                    import torch
                    device = "cuda" if torch.cuda.is_available() else "cpu"
                    model = whisper.load_model("base")
                    result = model.transcribe(str(file_path))
                    transcript = result["text"]
                else:
                    # Faster Whisper
                    import torch
                    device = "cuda" if torch.cuda.is_available() else "cpu"
                    model = WhisperModel("base", device=device)
                    segments, info = model.transcribe(str(file_path), language="en")
                    transcript = " ".join([segment.text for segment in segments])
                
                logger.info("Transcription complete (Whisper)")
                return transcript.strip()
            except Exception as e:
                logger.warning(f"Whisper transcription failed: {e}. Falling back to Ollama...")
                capture_exception(e, context={"file": str(file_path), "module": "transcribe_audio"})
        
        # Fallback to Ollama (slower but works without Whisper)
        try:
            # Since Ollama doesn't directly support audio, we'll note this limitation
            logger.warning("Ollama cannot transcribe audio directly. Install Whisper for transcription: pip install faster-whisper")
            return "[Transcription requires Whisper. Install: pip install faster-whisper]"
        except Exception as e:
            logger.error(f"Transcription failed: {e}")
            capture_exception(e, context={"file": str(file_path), "module": "transcribe_audio"})
            return "[Transcription failed]"
    
    def summarize_text(self, text: str) -> str:
        """Summarize text using Ollama."""
        logger.info(f"Summarizing with Ollama ({MODEL_CHAT})...")
        
        try:
            prompt = f"""Summarize this voice note transcript. Extract key points, action items, and important information.

Transcript:
{text}

Provide a concise summary with:
- Key points
- Action items (if any)
- Important details

Summary:"""
            
            response = requests.post(
                f"{OLLAMA_HOST}/api/generate",
                json={
                    "model": MODEL_CHAT,
                    "prompt": prompt,
                    "stream": False
                },
                timeout=120
            )
            
            if response.status_code == 200:
                result = response.json()
                summary = result.get("response", "").strip()
                logger.info("Summary complete")
                return summary
            else:
                logger.warning(f"Ollama API returned status {response.status_code}")
                capture_message(f"Ollama API error: {response.status_code}", level="warning", context={"endpoint": OLLAMA_HOST})
                return "[Summary failed - Ollama API error]"
        except requests.exceptions.ConnectionError:
            logger.error(f"Cannot connect to Ollama at {OLLAMA_HOST}. Make sure Ollama is running and accessible")
            capture_message(f"Ollama connection failed: {OLLAMA_HOST}", level="error")
            return "[Summary failed - Ollama not accessible]"
        except Exception as e:
            logger.error(f"Summarization failed: {e}")
            capture_exception(e, context={"module": "summarize_text", "model": MODEL_CHAT})
            return f"[Summary failed: {str(e)}]"
    
    def process_audio_file(self, file_path: Path):
        """Process a new audio file."""
        filename = file_path.name
        file_size_kb = file_path.stat().st_size / 1024
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        logger.info(f"New voice note detected: {filename} (Size: {file_size_kb:.2f} KB, Time: {timestamp})")
        
        try:
            # Step 1: Transcribe
            transcript = self.transcribe_audio(file_path)
            
            # Step 2: Summarize
            summary = self.summarize_text(transcript)
            
            # Step 3: Save results
            output_file = OUTPUT_DIR / f"{file_path.stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(f"# Voice Note: {filename}\n\n")
                f.write(f"**Date**: {timestamp}\n\n")
                f.write(f"**Original File**: `{file_path}`\n\n")
                f.write(f"**Size**: {file_size_kb:.2f} KB\n\n")
                f.write(f"---\n\n")
                f.write(f"## Transcript\n\n{transcript}\n\n")
                f.write(f"---\n\n")
                f.write(f"## Summary\n\n{summary}\n\n")
                f.write(f"---\n\n")
                f.write(f"**Model Used**: {MODEL_CHAT}\n\n")
            
            logger.info(f"Processing complete. Results saved to: {output_file}")
            
            # INFINITE LOOP GUARD: Move processed file to prevent re-processing
            try:
                processed_path = PROCESSED_DIR / file_path.name
                # If file with same name exists, add timestamp
                if processed_path.exists():
                    timestamp_str = datetime.now().strftime('%Y%m%d_%H%M%S')
                    processed_path = PROCESSED_DIR / f"{file_path.stem}_{timestamp_str}{file_path.suffix}"
                
                import shutil
                shutil.move(str(file_path), str(processed_path))
                logger.info(f"Moved processed file to: {processed_path}")
            except Exception as move_error:
                logger.warning(f"Could not move file to processed: {move_error}")
                capture_exception(move_error, context={"file": str(file_path), "module": "process_audio_file"})
                # Try to at least rename it to prevent re-processing
                try:
                    renamed_path = file_path.with_suffix(file_path.suffix + ".done")
                    file_path.rename(renamed_path)
                    logger.info(f"Renamed to: {renamed_path}")
                except Exception as rename_error:
                    logger.error(f"Failed to rename file: {rename_error}")
            
        except Exception as e:
            logger.error(f"Error processing file: {e}", exc_info=True)
            capture_exception(e, context={"file": str(file_path), "module": "process_audio_file"})


def main():
    """Main entry point."""
    logger.info("=" * 50)
    logger.info("ARK v3.1.1 - Voice Note Watcher")
    logger.info("=" * 50)
    logger.info(f"Monitoring: {INPUT_DIR.absolute()}")
    logger.info(f"Output: {OUTPUT_DIR.absolute()}")
    logger.info(f"Supported formats: {', '.join(SUPPORTED_EXTENSIONS)}")
    logger.info("Press Ctrl+C to stop")
    logger.info("=" * 50)
    
    # Ensure input directory exists
    INPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Create event handler and observer
    event_handler = AudioFileHandler()
    observer = Observer()
    observer.schedule(event_handler, str(INPUT_DIR), recursive=False)
    
    # Start watching
    observer.start()
    logger.info(f"Watching for new audio files in {INPUT_DIR.absolute()}")
    capture_message("Voice watcher started", level="info", context={"input_dir": str(INPUT_DIR)})
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("Stopping watcher...")
        observer.stop()
    
    observer.join()
    logger.info("Watcher stopped.")


if __name__ == "__main__":
    main()

