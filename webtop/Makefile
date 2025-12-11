.PHONY: help build up down logs

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  build  Build the Docker image"
	@echo "  up     Start the container in detached mode"
	@echo "  down   Stop the container"
	@echo "  logs   Follow container logs"
	@echo "  help   Show this help message"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f
