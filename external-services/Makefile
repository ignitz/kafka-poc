.PHONY: help
help: ## Show help menu
	@grep -E '^[a-z.A-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: lake-setup
lake-setup: ## Setup Confluent lake with docker compose, create buckets and Debezium's connectors
	@bash setup_lake_stack.sh

.PHONY: lake-destroy
lake-destroy: ## Destroy Confluent lake with docker compose
	@bash destroy_lake_stack.sh

.PHONY: step-1
step-1: ## Run step 1
	@bash step_1.sh

.PHONY: step-2
step-2: ## Run step 2
	@bash step_2.sh

.PHONY: step-3
step-3: ## Run step 3
	@bash step_3.sh
