.PHONY: run build clean clean-runtime pi tau prepare-runtime

CODING_AGENT ?= pi
AGENT_USER ?= agent
AGENT_GROUP ?= agent
AGENT_HOME ?= /home/$(AGENT_USER)

export CODING_AGENT
export AGENT_USER
export AGENT_GROUP
export AGENT_HOME

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

prepare-runtime:
	mkdir -p $(CODING_AGENT)/agent workspace
	chown $(UID):$(GID) $(CODING_AGENT) $(CODING_AGENT)/agent workspace
	chmod u+rwx,g+rwx $(CODING_AGENT) $(CODING_AGENT)/agent workspace

run: prepare-runtime
	docker compose run --rm --build $(if $(filter tau,$(CODING_AGENT)),--service-ports,) agent

build:
	docker compose build agent

pi: CODING_AGENT=pi
pi: run

tau: CODING_AGENT=tau
tau: run

clean:
	docker compose down

clean-runtime: clean
	$(MAKE) CODING_AGENT=pi prepare-runtime
	CODING_AGENT=pi docker compose run --rm --build --entrypoint sh agent -lc 'rm -rf "$$HOME/.pi"/*'
	$(MAKE) CODING_AGENT=tau prepare-runtime
	CODING_AGENT=tau docker compose run --rm --build --entrypoint sh agent -lc 'rm -rf "$$HOME/.tau"/*'
