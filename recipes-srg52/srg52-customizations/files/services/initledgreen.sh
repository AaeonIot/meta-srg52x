#!/bin/sh

set -e
echo 255 > /sys/bus/platform/devices/user_leds/leds/srt3352\:led2/brightness
echo "Default turn on led-green"

