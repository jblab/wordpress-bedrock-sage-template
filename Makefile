SHELL:=/bin/bash
.SILENT:

.PHONY: help up

help: ## Display this help and exit
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m  %-30s\033[0m %s\n", $$1, $$2}'

up: ## Run project and install composer dependencies
	touch src/.env
	docker compose up -d
	docker compose exec php-cli composer install
	docker compose exec php-cli composer install --working-dir ./web/app/themes/sage