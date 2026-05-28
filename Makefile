.DEFAULT_GOAL := run

.PHONY: run build clean logs

run:
	docker compose run --rm --build pi

build:
	docker compose build

clean:
	docker compose down
	rm -rf workspace

logs:
	docker compose logs -f
