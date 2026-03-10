#!/bin/bash
set -e

CPU_HWMON_NAME="$XDG_RUNTIME_DIR"/cpu_hwmon
GPU_HWMON_NAME="$XDG_RUNTIME_DIR"/gpu_hwmon
CPU_MAX=95
GPU_MAX=86

cpu_max_temp=0
gpu_max_temp=0

cpu_sensor_name=""
if [ ! -f "$CPU_HWMON_NAME" ]; then
    if lscpu | grep "Model name" | grep -q "AMD"; then
        cpu_sensor_name="k10temp"

    elif lscpu | grep "Model name" | grep -q "INTEL"; then
        cpu_sensor_name="coretemp"

    else
        echo -e "\e[31mCPU model not found.\e[0m"
        exit 1
    fi

    for d in /sys/class/hwmon/*; do
        if [ "$(cat "$d"/name)" = "$cpu_sensor_name" ]; then
            echo "$d" >"$CPU_HWMON_NAME"
            break
        fi
    done
    unset cpu_sensor_name
fi

for cpu in "$(cat "$CPU_HWMON_NAME")"/temp*_input; do
    temp_src_name=$(cat "${cpu/_input/_label}")

    value="$(cat "$cpu")"
    value=$((value / 1000))

    [ "$value" -gt "$cpu_max_temp" ] && cpu_max_temp="$value"

    if [ -z "$tooltip" ]; then
        tooltip="$temp_src_name:  $value"
    else
        tooltip="$tooltip\n$temp_src_name:  $value"
    fi
done

if lspci | grep -E "(VGA|Display controller)" | grep -q "AMD"; then
    if [ ! -f "$GPU_HWMON_NAME" ]; then
        for d in /sys/class/hwmon/*; do
            if [ "$(cat "$d"/name)" = "amdgpu" ]; then
                echo "$d" >"$GPU_HWMON_NAME"
                break
            fi
        done
    fi

    for gpu in "$(cat "$GPU_HWMON_NAME")"/temp*_input; do
        value="$(cat "$gpu")"
        value="$((value / 1000))"
        [ "$value" -gt "$gpu_max_temp" ] && gpu_max_temp="$value"
        tooltip="$tooltip\nAMD GPU:  $value"
    done

fi

if lspci | grep -E "(VGA|Display controller)" | grep -q "NVIDIA"; then
    value="$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits)"
    [ "$value" -gt "$gpu_max_temp" ] && gpu_max_temp="$value"
    tooltip="$tooltip\nNvidia GPU:  $value"
fi

if [ "$cpu_max_temp" -ge "$CPU_MAX" ] || [ "$gpu_max_temp" -ge "$GPU_MAX" ]; then
    pw-play "$HOME/.config/my-config/notification_tones/Overheat.wav"
fi

if [ "$cpu_max_temp" -gt "$gpu_max_temp" ]; then
    max_temp="$cpu_max_temp"
else
    max_temp="$gpu_max_temp"
fi

printf '{"text":"%s", "tooltip": "%s"}' "$max_temp" "$tooltip"
