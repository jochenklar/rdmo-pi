FROM alpine:latest

ARG UID=1000
ARG GID=1000

ENV USER=pi
ENV GROUP=pi
ENV HOME=/home/pi

RUN apk add --no-cache --update curl bash fd git grep ripgrep jq
RUN apk add --no-cache --update nodejs npm
RUN apk add --no-cache --update python3 py3-pip

RUN addgroup -g "${GID}" -S "${GROUP}"
RUN adduser -S "${USER}" -u "${UID}" -G "${GROUP}" -h "${HOME}" -s "/bin/sh"
RUN chown -R "${USER}:${GID}" "${HOME}" /var/log

RUN npm install -g @earendil-works/pi-coding-agent

USER pi
CMD ["pi"]
