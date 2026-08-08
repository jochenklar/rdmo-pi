# include the vars from the .env file
-include .env

# set default values
AGENT ?= pi
WORKSPACE_PATH ?= workspace
COMPOSE_PROJECT_NAME ?= rdmo-agent

ifeq ($(shell uname -s),Darwin)
# macOS
AGENT_UID := 1000
AGENT_GID := 1000
else ifeq ($(shell id -u),0)
# root
AGENT_UID := 1000
AGENT_GID := 1000
else
# regular user
AGENT_UID := $(shell id -u)
AGENT_GID := $(shell id -g)
endif

export AGENT_UID AGENT_GID COMPOSE_PROJECT_NAME

.PHONY: run bash build setup clean

run: setup
	docker compose run --rm $(AGENT)

bash: setup
	docker compose run --rm $(AGENT) bash

build:
	docker compose build $(AGENT)

setup:
	mkdir -p $(WORKSPACE_PATH)
ifeq ($(shell id -u),0)
	chown $(AGENT_UID):$(AGENT_GID) $(WORKSPACE_PATH)
endif

clean:
	-docker compose rm -sfv $(AGENT)
	-docker volume rm $(COMPOSE_PROJECT_NAME)_$(AGENT)
