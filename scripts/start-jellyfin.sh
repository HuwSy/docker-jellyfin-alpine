#!/bin/sh
set -e

# Detect host GPU group IDs from /dev/dri
if [ -e /dev/dri/renderD128 ]; then
    VIDEO_GID=$(stat -c "%g" /dev/dri/renderD128)
fi

if [ -e /dev/dri/controlD64 ]; then
    RENDER_GID=$(stat -c "%g" /dev/dri/controlD64)
fi

# Create matching groups inside the container
if [ -n "$VIDEO_GID" ]; then
    echo "Video:$VIDEO_GID"
    addgroup -g "$VIDEO_GID" hostvideo
    adduser jellyfin hostvideo
fi

if [ -n "$RENDER_GID" ]; then
    echo "Render:$RENDER_GID"
    addgroup -g "$RENDER_GID" hostrender
    adduser jellyfin hostrender
fi

# Drop privileges and run Jellyfin with CMD arguments
exec "$@"
