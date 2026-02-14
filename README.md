# Simplest Jellyfin on Alpine I could muster

## Build
```
docker build -t docker-jellyfin-alpine .
```

## Configuration

Create the required paths and set permissions, assuming 1002 uid:gid (or any other user):
```
mkdir -p /home/jellyfin/config
chown -R 1002:1002 /home/jellyfin
chattr -R +C /home/jellyfin
```

## Running the Container

Run the container. On older systems, you may need to add `--security-opt seccomp=unconfined`:
```
docker run --name=jellyfin \
    --user 1002:1002 \
    --cap-drop=ALL \
    -p 8096:8096 \
    -v /home/jellyfin/config:/config \
    --mount type=bind,source=/media,target=/media,readonly \
    docker-jellyfin-alpine
```

## Hardware Acceleration (Optional)

The following options can be added for hardware acceleration, though support is limited with musl libc:
```
    --group-add=$(cat /etc/group | grep -e video -e render | cut -d ":" -f 3) \
    --device=/dev/dri:/dev/dri 
```