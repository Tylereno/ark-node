#!/bin/bash
################################################################################
# DOWNLOAD-SURVIVAL-V2.SH - Enhanced Survival Guide Downloader
# Part of: Project Nomad (ARK Node)
# Uses archive.org and public domain sources with verified working URLs
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      SURVIVAL GUIDE DOWNLOADER V2 - PROJECT NOMAD             ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verify mount
if ! mountpoint -q /mnt/dock; then
    echo -e "${RED}ERROR: /mnt/dock is NOT mounted!${NC}"
    exit 1
fi

TARGET_DIR="/mnt/dock/data/resources/survival"
mkdir -p "$TARGET_DIR"

echo -e "${GREEN}Downloading survival guides from archive.org...${NC}"
echo ""

# Working public domain survival guides from archive.org
declare -a GUIDES=(
    "https://archive.org/download/SurvivalGuideUS/fm21-76.pdf|army_survival_fm21-76.pdf|Army Survival Manual FM 21-76"
    "https://archive.org/download/milmanual-tm-11-5820-890-10-1/TM%2031-210%20Improvised%20Munitions%20Handbook.pdf|improvised_munitions_handbook.pdf|Improvised Munitions Handbook"
    "https://archive.org/download/FirstAidManualStJohnAmbulance/First_Aid_Manual.pdf|first_aid_manual.pdf|First Aid Manual"
)

download_guide() {
    local URL="$1"
    local FILE="$2"
    local DESC="$3"
    
    echo -e "${BLUE}Downloading: $DESC${NC}"
    
    if [[ -f "$TARGET_DIR/$FILE" ]]; then
        echo -e "${YELLOW}  ✓ Already exists${NC}"
        return 0
    fi
    
    wget -c -t 3 --timeout=30 -q --show-progress \
         "$URL" \
         -O "$TARGET_DIR/$FILE.tmp" 2>&1 || {
        echo -e "${RED}  ✗ Failed${NC}"
        rm -f "$TARGET_DIR/$FILE.tmp"
        return 1
    }
    
    mv "$TARGET_DIR/$FILE.tmp" "$TARGET_DIR/$FILE"
    echo -e "${GREEN}  ✓ Saved: $FILE${NC}"
    echo ""
}

# Download all guides
for GUIDE in "${GUIDES[@]}"; do
    IFS='|' read -r URL FILE DESC <<< "$GUIDE"
    download_guide "$URL" "$FILE" "$DESC"
done

# Create essential text guides
cat > "$TARGET_DIR/water_purification.txt" << 'EOF'
WATER PURIFICATION METHODS - EMERGENCY GUIDE

1. BOILING (Most Reliable)
   - Bring water to rolling boil for 1 minute
   - At altitudes above 6,500 feet, boil for 3 minutes
   - Let cool before drinking
   - Most effective method, kills all pathogens

2. CHEMICAL TREATMENT
   Bleach (5.25% sodium hypochlorite):
   - Add 2 drops per quart of clear water
   - Add 4 drops per quart of cloudy water
   - Wait 30 minutes before drinking
   
   Iodine tablets:
   - Follow package directions (typically 1-2 tablets per liter)
   - Wait 30 minutes
   - Not suitable for pregnant women

3. FILTRATION
   - Use commercial filters rated for bacteria/protozoa removal
   - Coffee filters or cloth only remove large particles, not safe alone
   - Combine filtration with boiling for best results

4. SOLAR DISINFECTION (SODIS)
   - Fill clear plastic bottles with water
   - Place in direct sunlight for 6 hours (or 2 days if cloudy)
   - UV radiation kills pathogens
   - Only works with clear water

5. DISTILLATION
   - Boil water and capture steam
   - Removes heavy metals and salt
   - Time consuming but very effective

EMERGENCY WATER SOURCES:
- Rainwater (collect in clean containers)
- Dew (use cloth to absorb, wring into container)
- Ice and snow (melt before drinking, do not eat directly)
- Clear running streams (still need purification)

AVOID:
- Stagnant water
- Water with strong odor or color
- Water near industrial areas or farms
- Floodwater

SIGNS OF DEHYDRATION:
- Dark yellow urine
- Dry mouth and lips
- Headache
- Dizziness
- Confusion

Part of Project Nomad - Offline Survival Library
EOF

cat > "$TARGET_DIR/emergency_shelters.txt" << 'EOF'
EMERGENCY SHELTER CONSTRUCTION GUIDE

RULE OF 3s:
- 3 minutes without air
- 3 hours without shelter (in harsh conditions)
- 3 days without water
- 3 weeks without food

SHELTER PRIORITIES:
1. Protection from wind, rain, snow
2. Insulation from ground
3. Retain body heat
4. Stay dry

TYPES OF EMERGENCY SHELTERS:

1. DEBRIS HUT
   Materials: Sticks, leaves, bark, grass
   - Create A-frame with ridge pole
   - Lean branches against ridge pole
   - Cover with thick layer of debris (2-3 feet)
   - Create door plug with leaves/grass
   - Insulate floor with dry leaves
   Good for: Cold weather, forest environments

2. LEAN-TO
   Materials: Tarp, rope, branches
   - Tie rope between two trees
   - Drape tarp over rope
   - Secure corners with stakes
   - Add branch reinforcement
   Good for: Rain protection, quick setup

3. SNOW CAVE
   Materials: Snow (at least 6 feet deep)
   - Dig into snowbank horizontally
   - Create sleeping platform above entrance
   - Make small air hole in roof
   - Door should be lower than sleeping area
   WARNING: Risk of collapse, needs ventilation
   Good for: Extreme cold, mountain environments

4. TARP TENT
   Materials: Tarp, rope, stakes
   Multiple configurations:
   - A-frame: Classic tent shape
   - Diamond: Single trekking pole
   - Flat roof: Four corner stakes

5. NATURAL SHELTERS
   - Caves (check for animals first)
   - Rock overhangs
   - Fallen logs (create lean-to against)
   - Dense evergreen trees (natural roof)

INSULATION:
- Always insulate from ground
- Use pine boughs, leaves, or grass
- Air pockets = warmth
- Smaller shelter = warmer

LOCATION SELECTION:
✓ High ground (avoid flooding)
✓ Near water source
✓ Protected from wind
✓ Flat, dry area
✓ Near firewood

✗ River valleys (cold air sinks)
✗ Under dead trees (widowmakers)
✗ Hilltops (exposed to wind)
✗ Animal trails

EMERGENCY HEAT:
- Body heat (huddle together)
- Hot stones (heat near fire, place in shelter)
- Candles (can raise temp 10-15°F in small space)

Part of Project Nomad - Offline Survival Library
EOF

cat > "$TARGET_DIR/fire_starting.txt" << 'EOF'
FIRE STARTING METHODS - SURVIVAL GUIDE

FIRE TRIANGLE:
1. Heat (ignition source)
2. Fuel (material to burn)
3. Oxygen (air flow)

TINDER (catches spark/flame easily):
- Dry grass
- Birch bark
- Char cloth
- Cotton balls + petroleum jelly
- Dryer lint
- Fine wood shavings
- Cattail fluff

KINDLING (small sticks):
- Pencil-thick twigs
- Small dry branches
- Fatwood (pine resin)
- Split wood (dry inner core)

FUEL (sustains fire):
- Logs (wrist-thick to arm-thick)
- Hardwood burns longer
- Softwood ignites easier

FIRE STARTING METHODS:

1. LIGHTER/MATCHES (Primary)
   - Keep waterproof
   - Strike-anywhere matches
   - Store in multiple locations

2. FERROCERIUM ROD (Ferro Rod)
   - Scrape fast and hard
   - Aim sparks at tinder
   - Works when wet
   - 10,000+ strikes

3. MAGNIFYING GLASS
   - Focus sun to smallest point
   - Hold steady over tinder
   - Needs direct sunlight
   - Can use eyeglasses, camera lens

4. FIRE PLOW
   - Cut groove in soft wood board
   - Rub hardwood stick rapidly in groove
   - Friction creates wood dust that ignites
   - Very difficult, last resort

5. BOW DRILL
   - Most reliable primitive method
   - Requires practice
   - Components: bow, spindle, fireboard, handhold
   - Friction creates ember in wood dust

FIRE LAYS:

TEEPEE:
- Tinder in center
- Lean kindling in cone shape
- Burns hot and fast
- Good for starting fire

LOG CABIN:
- Stack logs in square pattern
- Tinder/kindling in center
- Burns steady
- Good for cooking

LEAN-TO:
- Large log as windbreak
- Lean kindling against it
- Tinder at base
- Good in wind

DAKOTA HOLE:
- Dig two holes connected by tunnel
- Fire in one, air intake in other
- Hides light, reduces wind
- Very efficient

WET WEATHER TIPS:
- Look for dead standing wood (drier inside)
- Use birch bark (burns when wet)
- Split wood to access dry core
- Create shelter for fire site
- Feather stick (shave curls on stick end)

SAFETY:
- Clear area 10 feet around fire
- Keep water/dirt nearby
- Never leave fire unattended
- Fully extinguish before leaving

Part of Project Nomad - Offline Survival Library
EOF

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              SURVIVAL GUIDES DOWNLOADED!                      ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "Location: ${BLUE}$TARGET_DIR${NC}"
echo -e "PDFs: ${BLUE}$(ls -1 "$TARGET_DIR"/*.pdf 2>/dev/null | wc -l) files${NC}"
echo -e "Text Guides: ${BLUE}$(ls -1 "$TARGET_DIR"/*.txt 2>/dev/null | wc -l) files${NC}"
echo ""
