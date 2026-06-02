.PHONY: run build clean

ifeq ($(shell uname),Linux)
export UID=$(shell id -u)
export GID=$(shell id -g)
endif

run:
	mkdir -p pi/agent workspace
	docker compose run --rm --build pi

build:
	docker compose build

clean:
	docker compose down
	rm -fr pi/*
