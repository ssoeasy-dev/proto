# Workflow — Proto Repository

## Ветки

- **`main`** — production. Мерж сюда → автоматический релиз.
- **`develop`** — ветка разработки. Мерж сюда → автоматическая beta версия.
- **`feat/*`**, **`fix/*`** и т.д. — feature ветки, создаются от `develop`.

## Версионирование

Формат: [Semantic Versioning](https://semver.org/)

| Тип        | Формат                    | Когда создаётся                                         |
| ---------- | ------------------------- | ------------------------------------------------------- |
| Dev        | `v1.1.1-dev-{branch}.{N}` | Автоматически при каждом push в открытый PR в `develop` |
| Beta       | `v1.1.1-beta.{N}`         | Автоматически при мерже PR в `develop`                  |
| Production | `v1.1.1`                  | Автоматически при мерже в `main`                        |

Версия для production и beta берётся из `package.json`. **Обновляй `package.json` вручную** перед мержем в `main`.

## Процесс работы с изменениями

### Шаг 1: Подготовка

```bash
git checkout develop
git pull origin develop
git checkout -b feat/my-feature

# Внести изменения в proto файлы
vim proto/auth/v1/my_service.proto

# Проверить
make format && make lint

# Проверить breaking changes относительно main
make breaking

# Сгенерировать код
make generate

# Закоммитить proto + gen/ вместе (CI проверяет синхронизацию)
git add proto/ gen/
git commit -m "feat: add MyService"
git push origin feat/my-feature
```

### Шаг 2: Pull Request в `develop`

Создай PR из `feat/my-feature` → `develop`.

GitHub Actions автоматически:

- Проверит линтинг и форматирование
- Проверит breaking changes относительно `main`
- Проверит что `gen/` синхронизирован с `proto/`
- Создаст dev версию: `v1.1.1-dev-feat-my-feature.1`
- Добавит комментарий в PR с инструкцией по использованию

При каждом следующем push в ветку — создаётся новая dev версия (`.2`, `.3`, ...).

### Шаг 3: Использование dev версии

```bash
# Go сервис
go get github.com/ssoeasy-dev/proto@v1.1.1-dev-feat-my-feature.1
go mod tidy

# TypeScript (auth.api)
npm install @ssoeasy-dev/proto@dev-feat-my-feature
```

### Шаг 4: Мерж в `develop`

После ревью и апрува:

- Мержи PR в `develop`
- GitHub Actions автоматически:
  - Удалит dev теги для этой ветки
  - Создаст beta версию: `v1.1.1-beta.N`
  - Опубликует beta в npm

```bash
# Использование beta
go get github.com/ssoeasy-dev/proto@v1.1.1-beta.1
```

### Шаг 5: Production релиз

Когда `develop` готов к релизу:

```bash
# 1. Обновить версию в package.json (например с 1.1.1 на 1.2.0)
vim package.json  # "version": "1.2.0"
git commit -am "chore: bump version to 1.2.0"
git push origin develop

# 2. Создать PR develop → main и смержить
```

GitHub Actions при мерже в `main` автоматически:

- Создаст git тег с версией из `package.json`
- Опубликует npm пакет с тегом `latest`
- Создаст GitHub Release (если тег соответствует `v*`)

## CI проверки (на каждый PR)

| Проверка  | Что делает                                     |
| --------- | ---------------------------------------------- |
| Lint      | `buf lint` — валидация proto файлов            |
| Format    | `buf format` — проверка форматирования         |
| Breaking  | `buf breaking` — сравнение с `main`            |
| Generate  | Проверка что `gen/` синхронизирован с `proto/` |
| Go import | `go build` сгенерированного Go кода            |

## Правила семантического версионирования

- **PATCH** (`v1.0.0 → v1.0.1`): исправления, некритичные изменения
- **MINOR** (`v1.0.0 → v1.1.0`): новые поля, новые сервисы (обратно совместимо)
- **MAJOR** (`v1.0.0 → v2.0.0`): breaking changes (удаление полей, переименование)

> Breaking changes будут пойманы `make breaking` и CI.

## Частые ошибки

**"Generated code is out of sync"**

```bash
make generate
git add proto/ gen/
git commit -m "chore: sync generated code"
```

**"Proto files are not formatted"**

```bash
make format
git add proto/
git commit -m "style: format proto files"
```

**"Breaking changes detected"**
Проверь изменения: `make breaking`. Если breaking change намеренный — увеличь MAJOR версию в `package.json`.

## Полезные команды

```bash
make help                          # Все доступные команды
make format && make lint           # Проверить перед коммитом
make generate                      # Сгенерировать весь код
git tag --sort=-creatordate | head # Последние теги
```
