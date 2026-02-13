###############################################
# Stage 1 — Jellyfin (Alpine Edge)
###############################################
FROM alpine:edge

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
    && mkdir -p /usr/lib/jellyfin/jellyfin-web \
    && apk update && apk add --no-cache \
    jellyfin \
    jellyfin-web \
    jellyfin-ffmpeg \
    intel-media-driver \
    libdrm \
    libva \
    libva-utils \
    libva-intel-driver \
    linux-firmware-i915 \
    mesa \
    mesa-dri-gallium \
    mesa-va-gallium \
    mesa-vdpau-gallium \
    tzdata \
    ca-certificates \
    && cp -r /usr/share/webapps/jellyfin-web/* /usr/lib/jellyfin/jellyfin-web/ \
    && ln -s /usr/lib/dri /usr/lib/jellyfin-ffmpeg/lib/dri \
    && ln -s /usr/lib/va /usr/lib/jellyfin-ffmpeg/lib/va

###############################################
# Create writable directories for ANY runtime user
###############################################
RUN mkdir -p /config /cache && \
    chmod -R 0777 /config /cache

###############################################
# Hardware Acceleration Environment
###############################################

ENV LIBVA_DRIVER_NAME=iHD
#ENV LIBVA_DRIVER_NAME=nouveau
ENV LIBVA_DRIVERS_PATH=/usr/lib/dri
ENV MESA_LOADER_DRIVER_OVERRIDE=crocus
#ENV MESA_LOADER_DRIVER_OVERRIDE=nouveau
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

###############################################
# Drop root — runtime user comes from --user
###############################################
USER 65534:65534

EXPOSE 8096 8920

VOLUME /config /cache

CMD ["jellyfin", "--datadir", "/config", "--cachedir", "/cache"]
