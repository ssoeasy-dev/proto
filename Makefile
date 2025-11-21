.PHONY: help generate clean lint breaking format install-tools tag commit-generated

help: ## Показать помощь
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

generate: ## Генерировать Go код из proto
	@echo "🔨 Генерация Go кода..."
	buf generate
	@echo "✅ Готово! Файлы в gen/go/"

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
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	@echo "📦 Установка protoc-gen-go-grpc..."
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	@echo "✅ Все инструменты установлены"

tag: ## Создать git tag (использовать: make tag VERSION=v1.2.3)
	@if [ -z "$(VERSION)" ]; then \
		echo "❌ Error: VERSION is required. Usage: make tag VERSION=v1.2.3"; \
		exit 1; \
	fi
	@echo "🏷️  Создание тега $(VERSION)..."
	git tag -a $(VERSION) -m "Release $(VERSION)"
	git push origin $(VERSION)
	@echo "✅ Тег $(VERSION) создан и отправлен"

.DEFAULT_GOAL := help