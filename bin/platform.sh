#!/bin/bash
# Platform abstraction layer

case "$(uname -s)" in
    Linux)  PLATFORM="linux" ;;
    Darwin) PLATFORM="macos" ;;
    *)      echo "Unsupported platform: $(uname -s)" >&2; exit 1 ;;
esac

get_monitor_count() {
    case "$PLATFORM" in
        linux) xrandr | grep " connected" | wc -l ;;
        macos) system_profiler SPDisplaysDataType | grep -c "Resolution:" ;;
    esac
}

get_resolutions() {
    case "$PLATFORM" in
        linux) xrandr | grep " connected" | grep -oP '\d+x\d+' ;;
        macos) system_profiler SPDisplaysDataType | grep "Resolution:" | sed 's/.*: \([0-9]*\) x \([0-9]*\).*/\1x\2/' ;;
    esac
}

set_wallpaper() {
    case "$PLATFORM" in
        linux) feh --bg-fill "$@" ;;
        macos)
            local i=0
            for img in "$@"; do
                osascript -e "tell application \"System Events\" to tell desktop $((i+1)) to set picture to POSIX file \"$img\""
                i=$((i+1))
            done
            ;;
    esac
}

get_current_wallpaper() {
    case "$PLATFORM" in
        linux) grep -oP "(?<=')[^']+\.jpg(?=')" ~/.fehbg 2>/dev/null ;;
        macos) osascript -e 'tell application "System Events" to get picture of every desktop' 2>/dev/null | tr ',' '\n' | sed 's/^ //' ;;
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
            osascript -e "display notification \"$body\" with title \"$title\""
            ;;
    esac
}

apply_pywal() {
    if command -v wal &>/dev/null; then
        wal -n -i "$1" -o "${PYWAL_HOOK:-}" 2>/dev/null
    fi
}
