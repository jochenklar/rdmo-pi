FROM node:22-trixie-slim

ARG PI_VERSION=latest

ENV NPM_CONFIG_PREFIX=/home/pi/.npm-global
ENV PATH=/home/pi/.npm-global/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        jq \
        python3 \
        python3-dev \
        ripgrep \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash pi \
    && install -d -o pi -g pi /home/pi/.pi /home/pi/.npm-global /workspace

USER pi
WORKDIR /home/pi

RUN npm install -g @earendil-works/pi-coding-agent@${PI_VERSION} \
    && npm cache clean --force

WORKDIR /workspace

CMD ["pi"]
