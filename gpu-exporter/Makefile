.PHONY: help up down restart logs ps clean test

help:
	@echo "GPU Exporter Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  up       Start gpu exporter"
	@echo "  down     Stop gpu exporter"
	@echo "  restart  Restart gpu exporter"
	@echo "  logs     Show logs (follow mode)"
	@echo "  ps       Show service status"
	@echo "  test     Curl metrics endpoint"
	@echo "  clean    Stop service and remove volumes"

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

ps:
	docker compose ps

test:
	@curl -s http://localhost:9835/metrics | grep -E '^nvidia_smi' | head -20

clean:
	docker compose down -v
