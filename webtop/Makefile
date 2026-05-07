.PHONY: help build up down logs

help:			## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | awk -F ':.*## ' '{printf "  %-15s %s\n", $$1, $$2}'

build:			## Build the Docker image
	docker compose build

up:			## Start the container in detached mode
	docker compose up -d

down:			## Stop the container
	docker compose down

logs:			## Follow container logs
	docker compose logs -f
