###############################################
# Stage 1 — Jellyfin (Alpine Edge)
###############################################
FROM alpine:edge

ENV LIBVA_DRIVER_NAME=i965
ENV LIBVA_DRIVERS_PATH=/usr/lib/dri
ENV LIBVA_DEVICE_GROUP=44

# Enable all Edge repos
RUN printf "%s\n" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
  > /etc/apk/repositories

# Install Jellyfin + web + hardware support 
# /usr/share/jellyfin/web is to prevent jellyfin post install fail
# /usr/lib/jellyfin/jellyfin-web is to run the site
RUN mkdir -p /usr/share/jellyfin/web \
    && apk update && apk add --no-cache \
    jellyfin \
    jellyfin-web \
    jellyfin-ffmpeg \
    tzdata \
    ca-certificates \
    && ln -s /usr/share/webapps/jellyfin-web /usr/lib/jellyfin/ \
    && ln -s /usr/lib/jellyfin-ffmpeg/* /usr/bin/

ADD https://raw.githubusercontent.com/HuwSy/docker-jellyfin-alpine/refs/heads/main/scripts/start-jellyfin.sh /opt/start-jellyfin.sh
RUN chmod 0755 /opt/start-jellyfin.sh

RUN apk update && apk add --no-cache \
    libva-intel-driver \
    intel-media-driver \
    libdrm \
    libvpl \
    libva \
    libva-utils \
    pciutils \
    gcompat

###############################################
# Create writable directories for ANY runtime user
###############################################
RUN mkdir -p /config /cache && \
    chmod -R 0777 /config /cache

###############################################
# Drop root — runtime user comes from --user
###############################################
USER 65534:65534

EXPOSE 8096 8920

VOLUME /config /cache

ENTRYPOINT ["/opt/start-jellyfin.sh"]
CMD ["jellyfin", "--datadir", "/config", "--cachedir", "/cache"]
