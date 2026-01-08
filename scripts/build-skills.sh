#!/bin/bash
# Build script for Skills Marketplace
# Creates distributable packages for Claude Desktop users
#
# Usage:
#   ./build-skills.sh                     # Build all skills
#   ./build-skills.sh suno-music-creator  # Build single skill

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$ROOT_DIR/dist"

# Optional skill filter (first argument)
SKILL_FILTER="${1:-}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Validate skill filter if provided
if [[ -n "$SKILL_FILTER" ]]; then
    if [[ ! -d "$ROOT_DIR/$SKILL_FILTER" ]] || [[ ! -f "$ROOT_DIR/$SKILL_FILTER/SKILL.md" ]]; then
        echo -e "${RED}Error: Skill '$SKILL_FILTER' not found${NC}"
        echo ""
        echo "Available skills:"
        for skill_dir in "$ROOT_DIR"/*/; do
            if [[ -f "$skill_dir/SKILL.md" ]]; then
                echo "  - $(basename "$skill_dir")"
            fi
        done
        exit 1
    fi
    echo -e "${BLUE}Building skill: $SKILL_FILTER${NC}"
else
    echo -e "${BLUE}Building all skills...${NC}"
fi

# Create dist directory
mkdir -p "$DIST_DIR"

# Track what was built
built_count=0

# Find all skill directories (those containing SKILL.md)
for skill_dir in "$ROOT_DIR"/*/; do
    skill_name=$(basename "$skill_dir")

    # Skip non-skill directories
    if [[ ! -f "$skill_dir/SKILL.md" ]]; then
        continue
    fi

    # Apply filter if specified
    if [[ -n "$SKILL_FILTER" && "$skill_name" != "$SKILL_FILTER" ]]; then
        continue
    fi

    echo -e "${GREEN}Processing: $skill_name${NC}"

    # Create ZIP package
    echo "  Creating $skill_name.zip..."
    (cd "$ROOT_DIR" && zip -rq "$DIST_DIR/$skill_name.zip" "$skill_name")

    ((built_count++))
done

# Create summary
echo ""
echo -e "${BLUE}Build complete!${NC}"
echo ""
echo "Skills built: $built_count"
echo "Output directory: $DIST_DIR"
echo ""

if [[ -n "$SKILL_FILTER" ]]; then
    echo "Files created:"
    ls -lh "$DIST_DIR/$SKILL_FILTER"* 2>/dev/null || echo "  (no files)"
else
    echo "Files created:"
    ls -lh "$DIST_DIR"
fi

echo ""
echo "Usage:"
echo "  - Extract .zip into your project"
echo "  - Reference with @skill-name/SKILL.md in CLAUDE.md"
