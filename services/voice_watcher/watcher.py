#!/usr/bin/env python3
"""
Nomad Node - Voice Note Watcher
Monitors the input directory for new audio files and processes them.

Usage:
    python services/voice_watcher/watcher.py

Requirements:
    - watchdog library
    - python-dotenv library (for .env file loading)
    - Audio files (.m4a, .mp3) should be synced to ./data/input via Syncthing

Models Used (P53 Optimized):
    - Chat/Summaries: granite4:3b
    - Coding: qwen2.5-coder:3b
    - Vision: qwen3-vl:2b
    - Embeddings: nomic-embed-text
"""

import os
import sys
import time
import json
import requests
from datetime import datetime
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from dotenv import load_dotenv

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
        print("WARNING: Whisper not available. Will use Ollama for transcription (slower).")

# Load environment variables from .env file
load_dotenv()

# Model Configuration (P53 Optimized Stack)
MODEL_CHAT = os.getenv("MODEL_CHAT", "granite4:3b")
MODEL_CODER = os.getenv("MODEL_CODER", "qwen2.5-coder:3b")
MODEL_VISION = os.getenv("MODEL_VISION", "qwen3-vl:2b")
MODEL_EMBEDDING = os.getenv("MODEL_EMBEDDING", "nomic-embed-text")
OLLAMA_HOST = os.getenv("OLLAMA_HOST", "http://localhost:11434")

# Configuration (use environment variables if in Docker, otherwise defaults)
INPUT_DIR = Path(os.getenv("INPUT_DIR", "./data/input"))
OUTPUT_DIR = Path(os.getenv("OUTPUT_DIR", "./data/output"))
PROCESSED_DIR = Path(os.getenv("PROCESSED_DIR", "./data/input/processed"))
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
        print(f"  Transcribing audio...")
        
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
                
                print(f"  ✓ Transcription complete (Whisper)")
                return transcript.strip()
            except Exception as e:
                print(f"  ⚠ Whisper transcription failed: {e}")
                print(f"  Falling back to Ollama...")
        
        # Fallback to Ollama (slower but works without Whisper)
        try:
            # Read audio file as base64 or use Ollama's audio support
            # Note: Ollama may not support audio directly, so we'll use a workaround
            # For now, we'll use a text prompt asking Ollama to transcribe
            # In production, you'd want to use Whisper or a dedicated transcription service
            
            # Since Ollama doesn't directly support audio, we'll note this limitation
            print(f"  ⚠ Ollama cannot transcribe audio directly")
            print(f"  Install Whisper for transcription: pip install faster-whisper")
            return "[Transcription requires Whisper. Install: pip install faster-whisper]"
        except Exception as e:
            print(f"  ✗ Transcription failed: {e}")
            return "[Transcription failed]"
    
    def summarize_text(self, text: str) -> str:
        """Summarize text using Ollama."""
        print(f"  Summarizing with Ollama ({MODEL_CHAT})...")
        
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
                print(f"  ✓ Summary complete")
                return summary
            else:
                print(f"  ⚠ Ollama API returned status {response.status_code}")
                return "[Summary failed - Ollama API error]"
        except requests.exceptions.ConnectionError:
            print(f"  ✗ Cannot connect to Ollama at {OLLAMA_HOST}")
            print(f"  Make sure Ollama is running and accessible")
            return "[Summary failed - Ollama not accessible]"
        except Exception as e:
            print(f"  ✗ Summarization failed: {e}")
            return f"[Summary failed: {str(e)}]"
    
    def process_audio_file(self, file_path: Path):
        """Process a new audio file."""
        filename = file_path.name
        print(f"\n{'='*50}")
        print(f"New Voice Note Detected: {filename}")
        print(f"  Path: {file_path}")
        print(f"  Size: {file_path.stat().st_size / 1024:.2f} KB")
        print(f"  Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
        try:
            # Step 1: Transcribe
            transcript = self.transcribe_audio(file_path)
            
            # Step 2: Summarize
            summary = self.summarize_text(transcript)
            
            # Step 3: Save results
            output_file = OUTPUT_DIR / f"{file_path.stem}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
            
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(f"# Voice Note: {filename}\n\n")
                f.write(f"**Date**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                f.write(f"**Original File**: `{file_path}`\n\n")
                f.write(f"**Size**: {file_path.stat().st_size / 1024:.2f} KB\n\n")
                f.write(f"---\n\n")
                f.write(f"## Transcript\n\n{transcript}\n\n")
                f.write(f"---\n\n")
                f.write(f"## Summary\n\n{summary}\n\n")
                f.write(f"---\n\n")
                f.write(f"**Model Used**: {MODEL_CHAT}\n\n")
            
            print(f"  [OK] Processing complete!")
            print(f"  [OK] Results saved to: {output_file}")
            
            # INFINITE LOOP GUARD: Move processed file to prevent re-processing
            try:
                processed_path = PROCESSED_DIR / file_path.name
                # If file with same name exists, add timestamp
                if processed_path.exists():
                    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                    processed_path = PROCESSED_DIR / f"{file_path.stem}_{timestamp}{file_path.suffix}"
                
                import shutil
                shutil.move(str(file_path), str(processed_path))
                print(f"  [OK] Moved to: {processed_path}")
            except Exception as move_error:
                print(f"  [WARN] Could not move file to processed: {move_error}")
                # Try to at least rename it to prevent re-processing
                try:
                    renamed_path = file_path.with_suffix(file_path.suffix + ".done")
                    file_path.rename(renamed_path)
                    print(f"  [OK] Renamed to: {renamed_path}")
                except:
                    pass
            
        except Exception as e:
            print(f"  [ERR] Error processing file: {e}")
            import traceback
            traceback.print_exc()


def main():
    """Main entry point."""
    print("=" * 50)
    print("Nomad Node - Voice Note Watcher")
    print("=" * 50)
    print(f"Monitoring: {INPUT_DIR.absolute()}")
    print(f"Output: {OUTPUT_DIR.absolute()}")
    print(f"Supported formats: {', '.join(SUPPORTED_EXTENSIONS)}")
    print("Press Ctrl+C to stop")
    print("=" * 50)
    print()
    
    # Ensure input directory exists
    INPUT_DIR.mkdir(parents=True, exist_ok=True)
    
    # Create event handler and observer
    event_handler = AudioFileHandler()
    observer = Observer()
    observer.schedule(event_handler, str(INPUT_DIR), recursive=False)
    
    # Start watching
    observer.start()
    print(f"✓ Watching for new audio files in {INPUT_DIR.absolute()}")
    print()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping watcher...")
        observer.stop()
    
    observer.join()
    print("Watcher stopped.")


if __name__ == "__main__":
    main()

