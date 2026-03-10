#! /bin/bash
set -e

current_script_dir="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

readarray -d '' batteries < <(
	find /sys/class/power_supply -mindepth 1 -maxdepth 1 -name "CMB*" -print0
)

batteries_filtered=()
for d in "${batteries[@]}"; do
    if [ -f "$d/type" ] && [ "$(cat "$d/type")" == "Battery" ] &&
        [ -f "$d"/status ] && [ -f "$d"/capacity ]; then
        batteries_filtered+=("$d")
    fi
done

if [ ${#batteries_filtered[@]} -eq 0 ]; then
    # No battery found
    exit 0

elif [ ${#batteries_filtered[@]} -gt 1 ]; then
    notify-send "Multiple batteries, monitoring ${batteries[1]}."
fi

# Set path to the battery
battery_path=${batteries_filtered[0]}

# Program states
NORMAL_STATE=0
LOW_STATE=1
CRITICAL_STATE=2

# Threshold
LOW_THRESHOLD=20
CRITICAL_THRESHOLD=8

# Initialise state
battery_level="$(cat "$battery_path"/capacity)"

if [ "$battery_level" -gt "$LOW_THRESHOLD" ]; then
    current_state="$NORMAL_STATE"
elif [ "$battery_level" -gt "$CRITICAL_THRESHOLD" ]; then
    current_state="$LOW_STATE"
else
    current_state="$CRITICAL_STATE"
fi

# Start monitoring
while true; do

    battery_level="$(cat "$battery_path"/capacity)"

    if [ "$(cat "$battery_path"/status)" = "Discharging" ]; then

        if [ "$current_state" = "$NORMAL_STATE" ]; then
            if [ "$battery_level" -le "$CRITICAL_THRESHOLD" ]; then
                current_state="$CRITICAL_STATE"
                notify-send "Battery level critical."
                pw-play "$current_script_dir"/low-battery-notification-sound.wav

            elif [ "$battery_level" -le "$LOW_THRESHOLD" ]; then
                current_state="$LOW_STATE"
                notify-send "Battery level low."
            fi

        elif [ "$current_state" = "$LOW_STATE" ]; then
            if [ "$battery_level" -le "$CRITICAL_THRESHOLD" ]; then
                current_state="$CRITICAL_STATE"
                notify-send "Battery level critical."
                pw-play "$current_script_dir"/low-battery-notification-sound.wav

            elif [ "$battery_level" -gt "$LOW_THRESHOLD" ]; then
                current_state="$NORMAL_STATE"

            fi
        else
            if [ "$battery_level" -gt "$LOW_THRESHOLD" ]; then
                current_state="$NORMAL_STATE"

            elif [ "$battery_level" -gt "$CRITICAL_THRESHOLD" ]; then
                current_state="$CRITICAL_STATE"
            fi

        fi
    else
        if [ "$battery_level" -gt "$LOW_THRESHOLD" ]; then
            current_state="$NORMAL_STATE"
        elif [ "$battery_level" -gt "$CRITICAL_THRESHOLD" ]; then
            current_state="$LOW_STATE"
        else
            current_state="$CRITICAL_STATE"
        fi
    fi
    sleep 5m
done
