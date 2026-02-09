###############################################
# Stage 1 — Build latest Jellyfin Web
###############################################
FROM node:lts-alpine AS build-web

RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++

# Clone latest stable Jellyfin Web
RUN git clone --depth 1 --branch master https://github.com/jellyfin/jellyfin-web.git /src

WORKDIR /src

RUN npm ci && npm run build:production


###############################################
# Stage 2 — Final Jellyfin Runtime (Alpine Edge)
###############################################
FROM alpine:edge

# Enable all Edge repos
RUN printf "%s\n" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/main" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/community" \
  "https://dl-cdn.alpinelinux.org/alpine/edge/testing" \
  > /etc/apk/repositories

# Install Jellyfin + hardware support
RUN apk update && apk add --no-cache \
    jellyfin \
    ffmpeg \
    intel-media-driver \
    libva \
    libva-utils \
    mesa \
    tzdata \
    bash \
    ca-certificates \
    pciutils

###############################################
# Create writable directories for ANY runtime user
###############################################
RUN mkdir -p /config /cache /media && \
    chmod -R 0777 /config /cache /media

###############################################
# Hardware Acceleration Environment
###############################################

ENV LIBVA_DRIVER_NAME=iHD
ENV LIBVA_DRIVERS_PATH=/usr/lib/dri

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

###############################################
# Install Jellyfin Web
###############################################
COPY --from=build-web /src/dist /usr/lib/jellyfin/jellyfin-web

###############################################
# Drop root — runtime user comes from --user
###############################################
USER 65534:65534

EXPOSE 8096 8920

VOLUME /config /cache /media

CMD ["jellyfin", "--datadir", "/config", "--cachedir", "/cache"]
