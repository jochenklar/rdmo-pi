FROM alpine:latest

ARG UID GID

ENV USER=pi
ENV GROUP=grp
ENV HOME=/home/pi

RUN apk add --no-cache --update curl bash fd git grep ripgrep
RUN apk add --no-cache --update nodejs npm
RUN apk add --no-cache --update python3 python3-dev

RUN addgroup -g "${GID}" -S "${GROUP}"
RUN adduser -S "${USER}" -u "${UID}" -G "${GROUP}" -h "${HOME}" -s "/bin/sh"
RUN chown -R "${USER}:${GID}" "${HOME}" /var/log

RUN npm install -g @earendil-works/pi-coding-agent

USER pi
CMD ["pi"]
