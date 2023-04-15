.PHONY: help
help: ## Show help menu
	@grep -E '^[a-z.A-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: up
up: ## 🐳 Setup Kafka stack with docker compose
	$(MAKE) -C external-services lake-setup

.PHONY: down
down: ## 🗑 Destroy Kafka stack lake with docker compose
	$(MAKE) -C external-services lake-destroy

.PHONY: step-1
step-1: ## 🚀 Run step 1
	$(MAKE) -C external-services step-1

.PHONY: step-2
step-2: ## 🚀 Run step 2
	$(MAKE) -C external-services step-2

.PHONY: step-3
step-3: ## 🚀 Run step 3
	$(MAKE) -C external-services step-3
