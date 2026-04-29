# Ecclesiastic Wallpapers

Fine art from the world's greatest museums as your desktop wallpaper.

Paintings are fetched from the [Metropolitan Museum of Art Open Access API](https://metmuseum.github.io/) — 475,000+ works, no API key needed. Each wallpaper is composed with a blurred, darkened version of the painting as background so it fits any screen resolution without ugly cropping.

A notification shows the painting's title, artist, year, style, and medium. Click to like it. Your preferences are stored in a local SQLite database so you can discover which art styles you're drawn to over time.

![](https://img.shields.io/badge/paintings-475%2C000%2B-blue)
![](https://img.shields.io/badge/API%20key-none-green)
![](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)

## How it works

1. On boot, a systemd service prefetches paintings into `~/Pictures/ArtWallpapers/`
2. Press your keybind → a random painting from a random art style is set instantly from the local pool
3. The painting is composed: blurred dark background + sharp centered original
4. A notification shows metadata with a like button
5. Multi-monitor: both screens get different paintings from the same style
6. Pool grows over time — eventually everything is local, zero latency

### Art styles

Baroque, Renaissance, Impressionism, Post-Impressionism, Romanticism, Realism, Rococo, Neoclassicism, Expressionism, Surrealism, Cubism, Art Nouveau, Mannerism, Pre-Raphaelite, Symbolism, Fauvism, Gothic, Hudson River School, Pointillism, Tonalism.

## Install

```bash
git clone https://github.com/rogersebastiany/ecclesiastic-wallpapers.git
cd ecclesiastic-wallpapers
./install.sh
```

### Dependencies

**Linux** (Arch/Ubuntu/Fedora):
```bash
# Arch
sudo pacman -S curl python sqlite imagemagick feh dunst xorg-xrandr

# Ubuntu/Debian
sudo apt install curl python3 sqlite3 imagemagick feh dunst x11-xserver-utils

# Fedora
sudo dnf install curl python3 sqlite ImageMagick feh dunst xrandr
```

**macOS**:
```bash
brew install imagemagick
# feh/dunst not needed — uses native osascript for wallpaper and notifications
```

### Prefetch your pool

```bash
# Download 16 paintings (default, runs on boot)
ecclesiastic-prefetch

# Build a large pool for instant switching
ecclesiastic-prefetch 500
```

## Usage

```bash
# Random style
ecclesiastic

# Specific style
ecclesiastic baroque
ecclesiastic impressionism
ecclesiastic "hudson river school"

# Show info about current wallpaper
ecclesiastic-info

# See your art preferences
ecclesiastic-stats
```

### Keyboard shortcuts

Bind to your window manager. Example for dwm `config.h`:

```c
{ MODKEY,           XK_g, spawn, SHCMD("ecclesiastic") },
{ MODKEY|ShiftMask, XK_g, spawn, SHCMD("ecclesiastic-info") },
```

For i3/sway `config`:
```
bindsym $mod+g exec ecclesiastic
bindsym $mod+Shift+g exec ecclesiastic-info
```

### Pywal integration

If [pywal](https://github.com/dylanaraps/pywal) is installed, terminal colors are automatically updated to match the painting. Set a hook script in `ecclesiastic.conf`:

```bash
PYWAL_HOOK="$HOME/scripts/pywal-hook"
```

## Configuration

Edit `~/.config/ecclesiastic/ecclesiastic.conf`:

```bash
POOL_DIR="$HOME/Pictures/ArtWallpapers"    # where paintings are stored
PREFETCH_BATCH=16                           # paintings per boot prefetch
MIN_SIZE=800                                # skip images smaller than this
```

## Ratings database

All paintings shown and liked are stored in SQLite at `~/.local/share/ecclesiastic/ratings.db`.

```sql
-- Your favorite styles
SELECT style, COUNT(*) as likes
FROM paintings WHERE rating = 1
GROUP BY style ORDER BY likes DESC;

-- All liked paintings
SELECT title, artist, date, style
FROM paintings WHERE rating = 1
ORDER BY rated_at DESC;

-- Most shown styles
SELECT style, COUNT(*) as shown
FROM paintings GROUP BY style
ORDER BY shown DESC;
```

## License

MIT

Data sourced from the [Metropolitan Museum of Art Collection API](https://metmuseum.github.io/) under the [Creative Commons Zero (CC0)](https://creativecommons.org/publicdomain/zero/1.0/) license.
