# Simplest Jellyfin on Alpine I could muster

Build
```
docker build -t docker-jellyfin-alpine .
```

Make the paths needed and permissions, assuming 1002 uid:gid but could be any
```
mkdir -p /home/jellyfin/config /home/jellyfin/cache
chown -R 1002:1002 /home/jellyfin
chattr -R +C /home/jellyfin
```

Run the container, on older systems it may need --security-opt seccomp=unconfined 
```
docker run --name=jellyfin \
    --user 1002:1002 \
    --restart=unless-stopped \
    --group-add=$(cat /etc/group | grep -e video -e render | cut -d ":" -f 3)\
    -v /home/jellyfin/config:/config \
    -v /home/jellyfin/cache:/cache \
    --mount type=bind,source=/media/USB,target=/media/USB,readonly \
    --device=/dev/dri:/dev/dri \
    -p 8096:8096 \
    --cap-drop=ALL \
    docker-jellyfin-alpine
