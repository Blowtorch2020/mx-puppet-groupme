FROM node:18-alpine AS builder

WORKDIR /opt/mx-puppet-groupme

# Install build dependencies for native modules (canvas, etc.)
RUN apk add --no-cache \
        python3 \
        make \
        g++ \
        build-base \
        cairo-dev \
        jpeg-dev \
        pango-dev \
        musl-dev \
        giflib-dev \
        pixman-dev \
        pangomm-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        pkgconfig

# Copy package files first for better caching
COPY package*.json ./

# Install dependencies as root to ensure native modules compile
RUN npm install --build-from-source

# Copy source and build
COPY . .
RUN npm run build


FROM node:18-alpine

VOLUME /data

ENV CONFIG_PATH=/data/config.yaml \
    REGISTRATION_PATH=/data/groupme-registration.yaml

# Runtime dependencies for native modules
RUN apk add --no-cache \
        su-exec \
        pixman \
        cairo \
        pango \
        giflib \
        libjpeg-turbo \
        freetype

WORKDIR /opt/mx-puppet-groupme
COPY docker-run.sh ./
COPY --from=builder /opt/mx-puppet-groupme/node_modules ./node_modules
COPY --from=builder /opt/mx-puppet-groupme/build ./build
COPY --from=builder /opt/mx-puppet-groupme/package*.json ./
RUN chmod +x docker-run.sh

# change workdir to /data so relative paths in the config.yaml
# point to the persistent volume
WORKDIR /data
ENTRYPOINT ["/opt/mx-puppet-groupme/docker-run.sh"]
