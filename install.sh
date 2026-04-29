#!/bin/bash
# Install Ecclesiastic Wallpapers

set -e

usage() {
    echo "Usage: ./install.sh [--prefix DIR]"
    echo "  --prefix DIR   Install scripts to DIR/bin (default: ~/.local)"
    exit 0
}

PREFIX="$HOME/.local"
while [ $# -gt 0 ]; do
    case "$1" in
        --prefix) PREFIX="$2"; shift 2 ;;
        --help|-h) usage ;;
        *) echo "Unknown option: $1"; usage ;;
    esac
done

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$PREFIX/bin"
CONF_DIR="$HOME/.config/ecclesiastic"

echo "Installing Ecclesiastic Wallpapers..."

mkdir -p "$BIN_DIR" "$CONF_DIR"

# Copy config (don't overwrite existing)
if [ ! -f "$CONF_DIR/ecclesiastic.conf" ]; then
    cp "$REPO_DIR/ecclesiastic.conf" "$CONF_DIR/ecclesiastic.conf"
    # Point scripts to user config location
    sed -i "s|../ecclesiastic.conf|$CONF_DIR/ecclesiastic.conf|g" "$REPO_DIR"/bin/*
fi

# Install scripts
for script in ecclesiastic ecclesiastic-compose ecclesiastic-prefetch ecclesiastic-info ecclesiastic-rate ecclesiastic-stats platform.sh; do
    cp "$REPO_DIR/bin/$script" "$BIN_DIR/$script"
    chmod +x "$BIN_DIR/$script"
done

# Fix config path in installed scripts
for script in "$BIN_DIR"/ecclesiastic*; do
    sed -i "s|\${SCRIPT_DIR}/../ecclesiastic.conf|$CONF_DIR/ecclesiastic.conf|g" "$script"
done

echo "Scripts installed to $BIN_DIR"

# Check dependencies
missing=()
for cmd in curl python3 sqlite3 magick identify; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
done

case "$(uname -s)" in
    Linux)
        for cmd in feh dunstify xrandr; do
            command -v "$cmd" &>/dev/null || missing+=("$cmd")
        done
        ;;
    Darwin)
        for cmd in osascript; do
            command -v "$cmd" &>/dev/null || missing+=("$cmd")
        done
        ;;
esac

if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    echo "Missing dependencies: ${missing[*]}"
    echo ""
    case "$(uname -s)" in
        Linux)
            echo "  Arch:   sudo pacman -S curl python sqlite imagemagick feh dunst xorg-xrandr"
            echo "  Ubuntu: sudo apt install curl python3 sqlite3 imagemagick feh dunst x11-xserver-utils"
            echo "  Fedora: sudo dnf install curl python3 sqlite ImageMagick feh dunst xrandr"
            ;;
        Darwin)
            echo "  brew install imagemagick terminal-notifier"
            ;;
    esac
    echo ""
fi

# Linux: install systemd service
if [ "$(uname -s)" = "Linux" ]; then
    SYSTEMD_DIR="$HOME/.config/systemd/user"
    mkdir -p "$SYSTEMD_DIR"
    cp "$REPO_DIR/systemd/ecclesiastic-prefetch.service" "$SYSTEMD_DIR/"
    systemctl --user daemon-reload
    systemctl --user enable ecclesiastic-prefetch.service
    echo "Systemd service enabled (prefetches on boot)"
fi

echo ""
echo "Done! Usage:"
echo "  ecclesiastic              # change wallpaper (random style)"
echo "  ecclesiastic baroque      # change wallpaper (specific style)"
echo "  ecclesiastic-info         # show current painting info"
echo "  ecclesiastic-prefetch     # download paintings in bulk"
echo "  ecclesiastic-prefetch 500 # download 500 paintings"
echo "  ecclesiastic-stats        # show your art preferences"
echo ""
echo "Bind to a keyboard shortcut for best experience."
