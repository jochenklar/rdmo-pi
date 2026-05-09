FROM node:22-trixie-slim

# Tools Pi commonly shells out to (git, ripgrep, curl, build basics).
# Add/remove based on what your projects need.
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        jq \
        python3 \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Run as a non-root user. Pi has no permission prompts, so the container
# boundary IS your sandbox — keep it unprivileged.
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

COPY SKILL.md /home/pi/.agents/skills/rdmo/

CMD ["pi"]
