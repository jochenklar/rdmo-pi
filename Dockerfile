FROM alpine:latest AS base

ARG UID=1000
ARG GID=1000
ARG AGENT_USER=agent
ARG AGENT_GROUP=agent
ARG AGENT_HOME=/home/agent

ENV AGENT_USER="${AGENT_USER}"
ENV AGENT_GROUP="${AGENT_GROUP}"
ENV AGENT_HOME="${AGENT_HOME}"
ENV USER="${AGENT_USER}"
ENV GROUP="${AGENT_GROUP}"
ENV HOME="${AGENT_HOME}"
ENV PATH="/usr/local/bin:${AGENT_HOME}/.local/bin:${PATH}"
ENV TAU_OAUTH_CALLBACK_HOST=0.0.0.0

RUN apk add --no-cache --update curl bash fd git grep ripgrep jq

RUN addgroup -g "${GID}" -S "${GROUP}"
RUN adduser -S "${USER}" -u "${UID}" -G "${GROUP}" -h "${HOME}" -s "/bin/sh"
RUN addgroup "${USER}" root
RUN chown -R "${USER}:${GID}" "${HOME}" /var/log

FROM base AS pi

RUN apk add --no-cache --update nodejs npm
RUN npm install -g @earendil-works/pi-coding-agent

USER ${AGENT_USER}
CMD ["pi"]

FROM base AS tau

RUN apk add --no-cache --update python3 uv
RUN UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin uv tool install tau-ai

USER ${AGENT_USER}
CMD ["tau"]
