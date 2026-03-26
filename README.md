# SSO Easy — Protocol Buffers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Централизованный репозиторий Protocol Buffers контрактов для SSO Easy микросервисной архитектуры.

## Пространства имён

| Пакет          | Сервисы                                         | Потребители                 |
| -------------- | ----------------------------------------------- | --------------------------- |
| `auth.v1`      | AuthService, VerificationService                | `auth.api`, `auth.svc`      |
| `companies.v1` | CompanyService, EmployeeService, ServiceService | `auth.api`, `companies.svc` |
| `common.v1`    | Общие типы (StatusResponse и др.)               | все сервисы                 |

## Структура проекта

```
.
├── proto/                   # Исходные .proto файлы
│   ├── auth/v1/             # AuthService, VerificationService
│   ├── companies/v1/        # CompanyService, EmployeeService, ServiceService
│   └── common/v1/           # Общие типы
├── gen/go/                  # Сгенерированный Go код (коммитится)
│   ├── auth/v1/
│   ├── companies/v1/
│   └── common/v1/
├── gen/ts/                  # Сгенерированный TypeScript код (коммитится)
│   ├── index.ts
│   ├── index.auth.ts
│   ├── index.companies.ts
│   └── index.common.ts
├── buf.yaml
├── buf.gen.yaml             # Генерация Go кода
├── buf.gen.ts.yaml          # Генерация TypeScript кода
├── go.mod
├── package.json
├── Makefile
├── workflow.md              # Процесс работы с изменениями и релизами
└── README.md
```

## Использование в сервисах

### `auth.svc` и `companies.svc` (Go)

Подключение в `go.mod`:

```go
require github.com/ssoeasy-dev/proto v1.1.1
```

Импорт в коде:

```go
import (
    authpb    "github.com/ssoeasy-dev/proto/gen/go/auth/v1"
    companiespb "github.com/ssoeasy-dev/proto/gen/go/companies/v1"
    commonpb  "github.com/ssoeasy-dev/proto/gen/go/common/v1"
)
```

Обновление до последней версии:

```bash
go get github.com/ssoeasy-dev/proto@latest
go mod tidy
```

### `auth.api` (TypeScript / NestJS)

Подключение в `package.json`:

```json
"dependencies": {
  "@ssoeasy-dev/proto": "1.1.1"
}
```

Импорт в коде:

```typescript
// gRPC клиенты для auth.svc
import {
  AuthServiceClient,
  VerificationServiceClient,
} from "@ssoeasy-dev/proto/auth";

// gRPC клиенты для companies.svc
import {
  CompanyServiceClient,
  ServiceServiceClient,
} from "@ssoeasy-dev/proto/companies";

// Общие типы
import { StatusResponse } from "@ssoeasy-dev/proto/common";
```

Подключение gRPC-клиентов через NestJS ClientsModule — см. `src/infra/grpc/grpc.module.ts` в `auth.api`.

Обновление:

```bash
pnpm add @ssoeasy-dev/proto@latest
```

## Разработка

### Требования

- Go 1.24+
- Node.js 20+
- pnpm
- [Buf CLI](https://buf.build/docs/installation)

### Установка инструментов

```bash
make install-tools
```

### Команды

```bash
make generate     # Сгенерировать весь код (Go + TypeScript)
make generate-go  # Только Go
make generate-ts  # Только TypeScript
make lint         # Проверить proto файлы
make format       # Отформатировать proto файлы
make breaking     # Проверить breaking changes относительно main
make clean        # Очистить gen/
```

### Добавление нового proto файла

```bash
# 1. Создать файл в нужном пространстве имён
vim proto/auth/v1/my_service.proto

# 2. Проверить и отформатировать
make format && make lint

# 3. Сгенерировать код
make generate

# 4. Закоммитить proto и сгенерированный код вместе
git add proto/ gen/
git commit -m "feat: add MyService"
```

> **Важно:** всегда коммитьте `proto/` и `gen/` вместе. CI проверяет их синхронизацию.

## Релизы

Подробный процесс — в [workflow.md](./workflow.md). Кратко:

| Событие                              | Результат                                                              |
| ------------------------------------ | ---------------------------------------------------------------------- |
| Открытие / обновление PR в `develop` | dev версия `v1.1.1-dev-{branch}.N`                                     |
| Закрытие PR в `develop`              | dev версия удаляется                                                   |
| Мерж в `develop`                     | beta версия `v1.1.1-beta.N`                                            |
| Мерж в `main`                        | production версия из `package.json`, публикация в npm с тегом `latest` |

## Лицензия

MIT — см. [LICENSE](LICENSE).

## Контакты

- Email: morewiktor@yandex.ru
- Telegram: [@MoreWiktor](https://t.me/MoreWiktor)
- GitHub: [@MoreWiktor](https://github.com/MoreWiktor)
