.PHONY: up down build rebuild logs ps clean

up:
	@docker compose up -d

down:
	@docker compose down

build:
	@docker compose build

up-build:
	@docker compose up -d --build

rebuild: down build up

logs:
	@docker compose logs -f

ps:
	@docker compose ps

clean:
	@docker compose down -v
