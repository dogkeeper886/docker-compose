.PHONY: help build up down logs setup install-apps

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

setup: build up install-apps	## Full setup: build, start, install apps

install-apps:		## Install custom apps (Cursor, Zed, Claude) into running container
	@echo "Waiting for container to be ready..."
	@sleep 5
	bash install-apps.sh
