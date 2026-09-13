FROM alpine:edge

ARG APP_VERSION=0.0.5

ENV LIBVA_DRIVER_NAME=i965
ENV LIBVA_DRIVERS_PATH=/usr/lib/dri
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=video,utility,graphics
ENV DOTNET_SYSTEM_NET_HTTP_SOCKETSHTTPHANDLER_POOLEDCONNECTIONLIFETIME=00:05:00

# Enable all Edge repos
RUN printf "%s\n" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
  > /etc/apk/repositories \
  && apk update \
  && apk upgrade --available --no-cache

# Install Jellyfin + web + hardware support 
# /usr/share/jellyfin/web is to prevent jellyfin post install fail
# /usr/lib/jellyfin/jellyfin-web is to run the site
RUN mkdir -p /usr/share/jellyfin/web \
    && apk add --no-cache \
    jellyfin \
    jellyfin-web \
    jellyfin-ffmpeg \
    tzdata \
    ca-certificates \
    && ln -s /usr/share/webapps/jellyfin-web /usr/lib/jellyfin/ \
    && ln -s /usr/lib/jellyfin-ffmpeg/* /usr/bin/ \
    && apk add --no-cache \
    libdrm \
    libva \
    libva-utils \
    pciutils \
    gcompat \
    vulkan-loader \
    vulkan-tools \
    && (apk add --no-cache $(apk search -q 'mesa-vulkan-*') || true) \
    && (apk add --no-cache libva-intel-driver intel-media-driver libvpl onevpl-intel-gpu mesa-va-gallium || true)

RUN mkdir -p /config /cache && \
    chmod -R 0777 /config /cache

EXPOSE 8096 8920

VOLUME /config /cache

CMD ["jellyfin", "--datadir", "/config", "--cachedir", "/cache"]
