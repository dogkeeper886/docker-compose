.PHONY: help setup up down restart logs ps fix-permissions clean

help:
	@echo "Monitoring Stack Management"
	@echo ""
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  setup            Create volume directories with correct permissions"
	@echo "  up               Start all services"
	@echo "  down             Stop all services"
	@echo "  restart          Restart all services"
	@echo "  logs             Show logs (follow mode)"
	@echo "  ps               Show service status"
	@echo "  fix-permissions  Fix volume directory permissions (requires sudo)"
	@echo "  clean            Stop services and remove volumes"

setup: fix-permissions
	@echo "Setup complete. Run 'make up' to start services."

fix-permissions:
	@mkdir -p volume/prometheus volume/grafana
	@echo "Fixing permissions for Prometheus (UID 65534) and Grafana (UID 472)..."
	sudo chown -R 65534:65534 volume/prometheus
	sudo chown -R 472:472 volume/grafana
	@echo "Permissions fixed."

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

clean:
	docker compose down -v
	rm -rf volume/prometheus volume/grafana
