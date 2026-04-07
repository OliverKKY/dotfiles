#!/usr/bin/env sh

if command -v powerprofilesctl >/dev/null 2>&1; then
    profile=$(powerprofilesctl get 2>/dev/null)
else
    profile=""
fi

case "$profile" in
    power-saver)
        text="Quiet"
        class="quiet"
        ;;
    balanced)
        text="Balanced"
        class="balanced"
        ;;
    performance)
        text="Performance"
        class="performance"
        ;;
    *)
        text="Power"
        class="default"
        ;;
esac

printf '{"text":"%s","class":"%s","tooltip":"Power profile: %s"}\n' "$text" "$class" "$text"
