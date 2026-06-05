.PHONY: run build clean

# only set UID/GID on linux
ifeq ($(shell uname),Linux)
ifeq ($(shell id -u),0)
export UID=1000
export GID=1000
else
export UID=$(shell id -u)
export GID=$(shell id -g)
endif
endif

run:
	mkdir -p pi/agent workspace
	chown -R $(UID):$(GID) pi workspace
	docker compose run --rm --build pi

build:
	docker compose build

clean:
	docker compose down
	rm -fr pi/*
