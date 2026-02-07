.PHONY: help generate clean lint breaking format install-tools tag generate-go generate-ts build-ts publish

help: ## Показать помощь
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

generate: generate-go generate-ts ## Генерировать весь код (Go + TypeScript)
	@echo "✅ Вся генерация завершена!"

generate-go: validate-proto ## Генерировать Go код из proto
	@echo "🔨 Генерация Go кода..."
	buf generate
	@echo "✅ Готово! Файлы в gen/go/"

generate-ts: validate-proto ## Генерировать TypeScript код из proto
	@echo "🔨 Генерация TypeScript кода..."
	buf generate --template buf.gen.ts.yaml
	@echo "✅ TypeScript код сгенерирован в gen/ts/"
	@echo "📊 Статистика:"
	@find gen/ts -name "*.ts" | wc -l | xargs echo "  - Файлов TypeScript:"

lint: ## Проверить proto файлы
	@echo "🔍 Проверка proto файлов..."
	buf lint

format: ## Форматировать proto файлы
	@echo "✨ Форматирование proto..."
	buf format -w

breaking: ## Проверить breaking changes
	@echo "⚠️  Проверка breaking changes..."
	buf breaking --against '.git#branch=main'

clean: ## Очистить сгенерированный код
	@echo "🗑️  Очистка gen/..."
	rm -rf gen/

install-tools: ## Установить buf и protoc плагины
	@echo "📦 Установка buf..."
	go install github.com/bufbuild/buf/cmd/buf@latest
	@echo "📦 Установка protoc-gen-go..."
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.36.10
	@echo "📦 Установка protoc-gen-go-grpc..."
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.6.0
	@echo "📦 Установка pnpm зависимостей..."
	pnpm install
	@echo "✅ Все инструменты установлены"

validate-proto: ## Проверить наличие proto файлов
	@echo "🔍 Проверка структуры proto файлов..."
	@if [ ! -d "proto" ]; then \
		echo "❌ Ошибка: папка proto/ не найдена"; \
		exit 1; \
	fi
	@if [ -z "$$(find proto -name '*.proto' -type f)" ]; then \
		echo "❌ Ошибка: не найдены .proto файлы в proto/"; \
		exit 1; \
	fi
	@echo "✅ Структура proto файлов валидна"

tag: ## Создать git tag (использовать: make tag VERSION=v1.2.3)
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION is required. Usage: make tag VERSION=v1.2.3"; \
		exit 1; \
	fi
	@echo "🏷️  Создание тега $(VERSION)..."
	git tag -a $(VERSION) -m "Release $(VERSION)"
	git push origin $(VERSION)
	@echo "✅ Тег $(VERSION) создан и отправлен"
	@echo "📦 Для публикации npm пакета используйте: make publish-npm VERSION=$(VERSION)"

sync-version: ## Синхронизировать версию package.json с git тегом (использовать: make sync-version VERSION=v1.2.3)
	@if [ -z "$(VERSION)" ]; then \
		echo "🔄 Определение версии из git тега..."; \
		./scripts/sync-version.sh; \
	else \
		./scripts/sync-version.sh $(VERSION); \
	fi

publish-npm: generate-ts sync-version ## Публикация npm пакета (использовать: make publish-npm VERSION=v1.2.3)
	@if [ -z "$(VERSION)" ]; then \
		echo "🔄 Определение версии из git тега..."; \
		./scripts/sync-version.sh; \
	else \
		./scripts/sync-version.sh $(VERSION); \
	fi
	@echo "🚀 Публикация npm пакета..."
	pnpm publish --no-git-checks
	@echo "✅ Пакет опубликован!"

publish: publish-npm ## Публикация npm пакета (alias для publish-npm)

.DEFAULT_GOAL := help
