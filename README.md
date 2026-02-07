# SSO Easy - Protocol Buffers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Централизованный репозиторий Protocol Buffers контрактов для SSO Easy микросервисной архитектуры.

## 📦 Установка

### Go

```bash
go get github.com/ssoeasy-dev/proto@latest
```

Или конкретная версия:

```bash
go get github.com/ssoeasy-dev/proto@v1.0.0
```

### NPM

```bash
npm install @ssoeasy-dev/proto
```

Или конкретная версия:

```bash
npm install @ssoeasy-dev/proto@1.0.0
```

Для pre-release версий (beta, rc):

```bash
npm install @ssoeasy-dev/proto@1.0.0-beta.1
```

## 🚀 Использование

### Импорт в Go проект

```go
package main

import (
    pb "github.com/ssoeasy-dev/proto/gen/go/companies/v1"
    "google.golang.org/grpc"
)

func main() {
    conn, _ := grpc.Dial("localhost:50051", grpc.WithInsecure())
    defer conn.Close()
    
    client := pb.NewCompanyServiceClient(conn)
    // Используйте client...
}
```

### Импорт в TypeScript/JavaScript проект

```typescript
import { CompanyServiceClient } from '@ssoeasy-dev/proto/companies';
import { CredentialServiceClient } from '@ssoeasy-dev/proto/auth';
import { EmployeeAttributeServiceClient } from '@ssoeasy-dev/proto/abac';

// Используйте клиенты...
```

## 🛠️ Разработка

### Требования

- Go 1.24+
- Node.js 20+ (для TypeScript генерации и npm публикации)
- pnpm (для управления npm зависимостями)
- [Buf CLI](https://buf.build/docs/installation)

### Установка Buf

```bash
# macOS
brew install bufbuild/buf/buf

# Linux
curl -sSL "https://github.com/bufbuild/buf/releases/latest/download/buf-$(uname -s)-$(uname -m)" \
  -o "/usr/local/bin/buf"
chmod +x /usr/local/bin/buf

# Или через Go
make install-tools
```

### Команды

```bash
make help              # Показать все команды
make generate          # Сгенерировать весь код (Go + TypeScript)
make generate-go       # Сгенерировать только Go код
make generate-ts       # Сгенерировать только TypeScript код
make lint              # Проверить proto файлы на ошибки
make format            # Отформатировать proto файлы
make breaking          # Проверить breaking changes
make clean             # Очистить сгенерированные файлы
make tag VERSION=v1.0.0  # Создать git тег для релиза
make sync-version      # Синхронизировать версию package.json с git тегом
make publish-npm       # Опубликовать npm пакет (автоматически синхронизирует версию)
```

### Структура проекта

```
.
├── proto/                          # Исходные .proto файлы
│   ├── common/v1/                 # Общие типы
│   ├── <group>/<version>/         # Протофайлы
│   └── gateway/v1/                # Gateway
├── gen/go/                        # ✅ Сгенерированный Go код (коммитится!)
│   ├── common/v1/
│   ├── <group>/<version>/
│   └── gateway/v1/
├── gen/ts/                        # ✅ Сгенерированный TypeScript код (коммитится!)
│   ├── common/v1/
│   ├── <group>/<version>/
│   └── index.ts
├── scripts/                       # Скрипты для автоматизации
│   └── sync-version.sh           # Скрипт синхронизации версии
├── buf.yaml                       # Конфигурация Buf
├── buf.gen.yaml                   # Генерация Go кода
├── buf.gen.ts.yaml                # Генерация TypeScript кода
├── go.mod                         # Go модуль
├── package.json                   # NPM пакет конфигурация
├── Makefile                       # Команды разработки
└── README.md
```

## 📝 Workflow изменений

### 1. Изменение proto файлов

```bash
# Отредактировать proto файл
vim proto/companies/v1/company.proto

# Проверить стиль
make lint

# Отформатировать
make format

# Проверить breaking changes
make breaking
```

### 2. Генерация кода

```bash
# Сгенерировать весь код (Go + TypeScript)
make generate

# Или отдельно
make generate-go   # Только Go
make generate-ts   # Только TypeScript

# Проверить что все работает
go mod tidy
pnpm install
```

### 3. Коммит и релиз

```bash
# Закоммитить изменения (proto + gen/)
git add proto/ gen/
git commit -m "feat: add new field to Company"
git push origin main

# Создать релиз (создаст git тег)
make tag VERSION=v1.1.0

# GitHub Actions автоматически:
# - Создаст GitHub Release
# - Опубликует npm пакет с версией из тега
# - Go модуль будет доступен через git тег
```

**Важно:** Версия npm пакета автоматически синхронизируется с git тегом при публикации через GitHub Actions. Версия в `package.json` обновляется автоматически из git тега (без префикса `v`).

## 🔄 Обновление зависимости в проектах

### Go проекты

```bash
# В вашем микросервисе
cd <Микросервис>

# Обновить до последней версии
go get github.com/ssoeasy-dev/proto@latest

# Или до конкретной версии
go get github.com/ssoeasy-dev/proto@v1.2.0

go mod tidy
```

### TypeScript/JavaScript проекты

```bash
# Обновить до последней версии
npm install @ssoeasy-dev/proto@latest
# или
pnpm add @ssoeasy-dev/proto@latest

# Или до конкретной версии
npm install @ssoeasy-dev/proto@1.2.0

# Для pre-release версий
npm install @ssoeasy-dev/proto@1.2.0-beta.1
```

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) файл.

## 📞 Контакты

- GitHub: [@MoreWiktor](https://github.com/MoreWiktor)
- Проект: [https://github.com/ssoeasy-dev/proto](https://github.com/ssoeasy-dev/proto)
