.PHONY: run build clean logs

run:
	docker compose run --rm pi

build:
	docker compose build

clean:
	docker compose down
	rm -fr pi/*

logs:
	docker compose logs -f
