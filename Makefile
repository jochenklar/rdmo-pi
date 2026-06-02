.PHONY: run build clean

export UID=$(shell id -u)
export GID=$(shell id -g)

run:
	mkdir -p pi/agent workspace
	docker compose run --rm pi

build:
	docker compose build

clean:
	docker compose down
	rm -fr pi/*
