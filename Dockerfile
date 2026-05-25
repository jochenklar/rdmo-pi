FROM node:22-trixie-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        fd-find \
        git \
        jq \
        ripgrep \
        python3 \
        python3-dev \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which fdfind) /usr/local/bin/fd

# Run as a non-root user.
RUN useradd -m -s /bin/bash pi
USER pi
WORKDIR /home/pi

# Install Pi globally for the pi user.
RUN npm config set prefix '/home/pi/.npm-global' \
    && npm install -g @earendil-works/pi-coding-agent
ENV PATH="/home/pi/.npm-global/bin:${PATH}"

# Pre-create the config dir as the pi user. When the named volume mounts
# at /home/pi/.pi, Docker initializes a fresh volume by copying this
# directory's contents AND ownership — without this, the volume is
# owned by root and Pi can't write its session files.
RUN mkdir -p /home/pi/.pi

# Working directory you'll mount your project into.
WORKDIR /workspace

CMD ["pi"]
