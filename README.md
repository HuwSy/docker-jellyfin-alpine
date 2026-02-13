# Simplest Jellyfin on Alpine I could muster

Build
```
docker build -t docker-jellyfin-alpine .
```

Make the paths needed and permissions, assuming 1002 uid:gid but could be any
```
mkdir -p /home/jellyfin/config
chown -R 1002:1002 /home/jellyfin
chattr -R +C /home/jellyfin
```

Run the container, on older systems it may need --security-opt seccomp=unconfined 
```
docker run --name=jellyfin \
    --user 1002:1002 \
    --cap-drop=ALL \
    -p 8096:8096 \
    -v /home/jellyfin/config:/config \
    --mount type=bind,source=/media,target=/media,readonly \
    --group-add=$(cat /etc/group | grep -e video -e render | cut -d ":" -f 3)\
    --device=/dev/dri:/dev/dri \
    docker-jellyfin-alpine
