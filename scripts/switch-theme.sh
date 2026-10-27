#!/bin/bash
# ==============================================================================
# EL BASHA NET HOTSPOT THEME SWITCHER
# Copies a theme's login, status, alogin and logout pages to the project root.
# Usage: ./scripts/switch-theme.sh [theme-name]
# Available:
#   oled-matrix | spatial-glass | nordic-studio | cyberpunk
#   swiss-minimal | aurora-glass | neo-brutalist | luxury-gold
# ==============================================================================

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
THEME="$1"
PAGES="login.html status.html alogin.html logout.html"

if [ -z "$THEME" ]; then
    echo "Usage: $0 [oled-matrix | spatial-glass | nordic-studio | cyberpunk | swiss-minimal | aurora-glass | neo-brutalist | luxury-gold]"
    exit 1
fi

THEME_DIR="$PROJECT_DIR/themes/$THEME"

for page in $PAGES; do
    if [ ! -f "$THEME_DIR/$page" ]; then
        echo "Error: Theme '$THEME' is missing $page at $THEME_DIR"
        exit 1
    fi
done

for page in $PAGES; do
    cp -f "$THEME_DIR/$page" "$PROJECT_DIR/$page"
done
echo ">>> Theme successfully switched to '$THEME'!"
echo ">>> Root pages updated: $PAGES"
