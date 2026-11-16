#!/usr/bin/env bash
# Declare the physical source of the /dev/video57 relay for Gaze.
# Gaze reads this root-owned marker (line 1: physical IPU4P capture node,
# line 2: relay sink) before trusting the virtual node for authentication.
set -euo pipefail

marker_dir=/run/xps7390-webcam
sink=/dev/video57
source=$(readlink -e /dev/video-ipu4-raw)

[[ $source =~ ^/dev/video[0-9]+$ && -c $source ]] || { echo "No IPU4P capture node" >&2; exit 1; }
driver=$(basename "$(readlink -f "/sys/class/video4linux/${source#/dev/}/device/driver")")
[[ $driver == intel-ipu4p ]] || { echo "$source is bound to $driver, not intel-ipu4p" >&2; exit 1; }
[[ -c $sink ]] || { echo "$sink is missing" >&2; exit 1; }

install -d -o root -g root -m 0755 "$marker_dir"
tmp=$(mktemp "$marker_dir/.rgb-source.XXXXXX")
printf '%s\n%s\n' "$source" "$sink" > "$tmp"
chmod 0644 "$tmp"
mv -f "$tmp" "$marker_dir/rgb-source"
