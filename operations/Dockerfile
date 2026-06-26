FROM ubuntu:22.04 AS build

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    clang cmake ninja-build pkg-config \
    libgtk-3-dev liblzma-dev \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash developer
USER developer
WORKDIR /home/developer

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git --depth 1 -b stable /home/developer/flutter
ENV PATH="/home/developer/flutter/bin:${PATH}"

# Pre-cache
RUN flutter precache

COPY --chown=developer:developer . /app
WORKDIR /app

RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY operations/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
