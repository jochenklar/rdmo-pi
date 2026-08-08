# include the vars from the .env file
-include .env

# set a default value for AGENT
AGENT ?= pi

# only set UID/GID on linux as user
ifeq ($(UNAME_S),Darwin)
HOST_UID := 1000
HOST_GID := 1000
else ifeq ($(shell id -u),0)
HOST_UID := 1000
HOST_GID := 1000
else
HOST_UID := $(shell id -u)
HOST_GID := $(shell id -g)
endif

.PHONY: run bash build clean

run:
	docker compose run --rm $(AGENT)

bash:
	docker compose run --rm $(AGENT) bash

build:
	docker compose build $(AGENT)

clean:
	docker compose down -v $(AGENT)
	docker compose rm -v $(AGENT)
