## rdmo-base base

FROM alpine:latest AS rdmo-agent

ARG UID=1000
ARG GID=1000

ENV UID="${UID}"
ENV GID="${GID}"

ENV USER=agent \
    GROUP=agent \
    HOME=/home/agent

RUN apk add --no-cache --update \
    bash \
    curl \
    fd \
    git \
    grep \
    jq \
    nodejs \
    npm \
    ripgrep \
    uv

RUN addgroup -g "${GID}" -S "${GROUP}"
RUN adduser -S "${USER}" -u "${UID}" -G "${GROUP}" -h "${HOME}" -s "/bin/sh"

RUN mkdir -p /workspace /opt/env /opt/npm /opt/python
RUN chown -R "${USER}:${GID}" "${HOME}" /workspace /opt/env /opt/npm /opt/python

USER "${USER}"
WORKDIR /workspace

ENV VIRTUAL_ENV="/opt/env" \
    UV_PROJECT_ENVIRONMENT="/opt/env" \
    UV_PYTHON_INSTALL_DIR="/opt/python" \
    UV_LINK_MODE=copy \
    PATH="/opt/npm/bin:/opt/env/bin:${PATH}"

RUN npm config set prefix "/opt/npm"

RUN uv venv --seed --python 3.14 "$VIRTUAL_ENV"

## rdmo-pi

FROM rdmo-agent AS rdmo-pi

RUN npm install -g @earendil-works/pi-coding-agent
RUN mkdir -p /home/agent/.pi/agent

CMD ["pi"]

## rdmo-claude

FROM rdmo-agent AS rdmo-claude

RUN npm install -g @anthropic-ai/claude-code
RUN mkdir -p /home/agent/.claude/skills

CMD ["claude", "--dangerously-skip-permissions"]

## rdmo-codex

FROM rdmo-agent AS rdmo-codex

RUN npm install -g @openai/codex
RUN mkdir -p /home/agent/.codex /home/agent/.agents/skills/

CMD ["codex", "--yolo"]

## rdmo-tau

FROM rdmo-agent AS rdmo-tau

RUN uv pip install --no-cache tau-ai
RUN mkdir -p /home/agent/.tau

CMD ["tau"]
