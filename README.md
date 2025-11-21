# SSO Easy - Protocol Buffers

[![Go Reference](https://pkg.go.dev/badge/github.com/MoreWiktor/ssoeasy.proto.svg)](https://pkg.go.dev/github.com/MoreWiktor/ssoeasy.proto)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Централизованный репозиторий Protocol Buffers контрактов для SSO Easy микросервисной архитектуры.

## 📦 Установка

```bash
go get github.com/MoreWiktor/ssoeasy.proto@latest
```

Или конкретная версия:

```bash
go get github.com/MoreWiktor/ssoeasy.proto@v1.0.0
```

## 🚀 Использование

### Импорт в Go проект

```go
package main

import (
    pb "github.com/MoreWiktor/ssoeasy.proto/gen/go/companies/v1"
    "google.golang.org/grpc"
)

func main() {
    conn, _ := grpc.Dial("localhost:50051", grpc.WithInsecure())
    defer conn.Close()
    
    client := pb.NewCompanyServiceClient(conn)
    // Используйте client...
}
```

## 🛠️ Разработка

### Требования

- Go 1.24+
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
make generate          # Сгенерировать Go код из proto
make lint              # Проверить proto файлы на ошибки
make format            # Отформатировать proto файлы
make breaking          # Проверить breaking changes
make clean             # Очистить сгенерированные файлы
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
├── buf.yaml                       # Конфигурация Buf
├── buf.gen.yaml                   # Генерация Go кода
├── go.mod                         # Go модуль
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
# Сгенерировать Go код
make generate

# Проверить что все работает
go mod tidy
```

### 3. Коммит и релиз

```bash
# Закоммитить изменения (proto + gen/)
git add proto/ gen/
git commit -m "feat: add new field to Company"
git push origin main

# Создать релиз
make tag VERSION=v1.1.0
```

## 🔄 Обновление зависимости в проектах

```bash
# В вашем микросервисе
cd <Микросервис>

# Обновить до последней версии
go get github.com/MoreWiktor/ssoeasy.proto@latest

# Или до конкретной версии
go get github.com/MoreWiktor/ssoeasy.proto@v1.2.0

go mod tidy
```

## 📄 Лицензия

MIT License - см. [LICENSE](LICENSE) файл.

## 📞 Контакты

- GitHub: [@MoreWiktor](https://github.com/MoreWiktor)
- Проект: [https://github.com/MoreWiktor/ssoeasy.proto](https://github.com/MoreWiktor/ssoeasy.proto)
