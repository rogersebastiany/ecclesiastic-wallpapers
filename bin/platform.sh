#!/bin/bash
# Platform abstraction layer

case "$(uname -s)" in
    Linux)  PLATFORM="linux" ;;
    Darwin) PLATFORM="macos" ;;
    *)      echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

# macOS ships bash 3.2, no ${var^} — use tr instead
upper_first() {
    echo "$1" | sed 's/./\U&/'
}

# macOS has no shuf — fallback to awk
shuffle_pick() {
    if command -v shuf &>/dev/null; then
        shuf -n1
    else
        awk 'BEGIN{srand()} {lines[NR]=$0} END{print lines[int(rand()*NR)+1]}'
    fi
}

get_resolutions() {
    case "$PLATFORM" in
        linux) xrandr | grep " connected" | grep -oE '[0-9]+x[0-9]+' ;;
        macos) system_profiler SPDisplaysDataType 2>/dev/null | grep "Resolution:" | sed 's/.*: \([0-9]*\) x \([0-9]*\).*/\1x\2/' ;;
    esac
}

set_wallpaper() {
    case "$PLATFORM" in
        linux) feh --bg-fill "$@" ;;
        macos)
            for img in "$@"; do
                osascript <<APPLESCRIPT
tell application "System Events"
    set theDesktops to a reference to every desktop
    repeat with aDesktop in theDesktops
        set picture of aDesktop to POSIX file "$img"
    end repeat
end tell
APPLESCRIPT
            done
            ;;
    esac
}

get_current_wallpaper() {
    case "$PLATFORM" in
        linux) sed -n "s/.*'\(.*\.jpg\)'.*/\1/p" ~/.fehbg 2>/dev/null ;;
        macos) osascript -e 'tell application "System Events" to get picture of desktop 1' 2>/dev/null ;;
    esac
}

send_notification() {
    local title="$1"
    local body="$2"
    local icon="$3"
    local action_label="$4"

    case "$PLATFORM" in
        linux)
            if [ -n "$action_label" ]; then
                dunstify -t 12000 \
                    -h string:x-dunst-stack-tag:art-wallpaper \
                    -i "$icon" \
                    -A "like,$action_label" \
                    "$title" "$body"
            else
                dunstify -t 10000 \
                    -h string:x-dunst-stack-tag:art-wallpaper \
                    -i "$icon" \
                    "$title" "$body"
            fi
            ;;
        macos)
            # Strip pango/HTML markup for macOS native notifications
            local clean_body=$(echo -e "$body" | sed 's/<[^>]*>//g')
            if command -v terminal-notifier &>/dev/null; then
                terminal-notifier -title "$title" -message "$clean_body" -contentImage "$icon" -group ecclesiastic
            else
                osascript -e "display notification \"$clean_body\" with title \"$title\""
            fi
            ;;
    esac
}

apply_pywal() {
    if command -v wal &>/dev/null; then
        wal -n -i "$1" -o "${PYWAL_HOOK:-}" 2>/dev/null
    fi
}
