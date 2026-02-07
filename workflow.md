# Workflow работы с изменениями в proto репозитории

## 📋 Обзор

Репозиторий proto использует Git Flow с автоматизацией через GitHub Actions:
- **main** - стабильная production ветка
- **develop** - ветка разработки
- **feature ветки** - для разработки новых функций

## 🔄 Типы версий

### 1. Dev версии (dev-*)
- **Формат**: `dev-<branch-name>` (например: `dev-feat-user-registration`)
- **Создание**: Автоматически при открытии PR в develop/main
- **Удаление**: Автоматически при закрытии PR
- **Использование**: Для тестирования изменений в feature ветках

### 2. Pre-release версии (beta/rc/alpha)
- **Формат**: `v<major>.<minor>.<patch>-<type>.<number>` (например: `v1.0.0-beta.1`, `v1.0.0-rc.2`)
- **Создание**: 
  - Автоматически при мерже PR в develop
  - Вручную через GitHub Actions (Pre-Release workflow)
- **Ветка**: Только из develop
- **Использование**: Для тестирования в develop окружении

### 3. Production версии
- **Формат**: `v<major>.<minor>.<patch>` (например: `v1.0.0`)
- **Создание**: Вручную через GitHub Actions (Production Release workflow) или тег
- **Ветка**: Только из main
- **Использование**: Стабильные релизы для production

## 🚀 Процесс работы с изменениями

### Шаг 1: Подготовка изменений

```bash
# 1. Создать feature ветку от develop
git checkout develop
git pull origin develop
git checkout -b feat/my-feature

# 2. Внести изменения в proto файлы
vim proto/companies/v1/company.proto

# 3. Проверить форматирование и линтинг
make format
make lint

# 4. Проверить breaking changes (сравнение с main)
make breaking

# 5. Сгенерировать код
make generate

# 6. Проверить что все работает
go mod tidy
```

### Шаг 2: Коммит и Push

```bash
# 1. Добавить изменения (proto файлы + сгенерированный код)
git add proto/ gen/

# 2. Закоммитить
git commit -m "feat: add new field to Company"

# 3. Запушить ветку
git push origin feat/my-feature
```

**⚠️ ВАЖНО**: 
- Всегда коммитьте и proto файлы, и сгенерированный код (gen/)
- CI проверяет, что сгенерированный код синхронизирован

### Шаг 3: Создание Pull Request

1. Создайте PR из `feat/my-feature` в `develop`
2. GitHub Actions автоматически:
   - ✅ Проверит линтинг и форматирование
   - ✅ Проверит breaking changes
   - ✅ Проверит что код сгенерирован
   - ✅ Создаст dev версию `dev-feat-my-feature`
   - ✅ Добавит комментарий в PR с инструкциями по использованию

### Шаг 4: Использование dev версии

После создания PR, вы можете использовать dev версию в других сервисах:

```bash
# В вашем микросервисе
go get github.com/ssoeasy-dev/proto@dev-feat-my-feature
go mod tidy
```

### Шаг 5: Мерж в develop

После ревью и апрува:

1. Мержите PR в `develop`
2. GitHub Actions автоматически:
   - ✅ Удалит dev версию `dev-feat-my-feature`
   - ✅ Создаст новую beta версию (например: `v0.1.0-beta.2`)
   - ✅ Добавит комментарий в PR с новой версией

### Шаг 6: Использование beta версии

После мержа в develop, используйте beta версию:

```bash
# В вашем микросервисе
go get github.com/ssoeasy-dev/proto@v0.1.0-beta.2
go mod tidy
```

### Шаг 7: Production релиз

Когда накопилось достаточно изменений в develop:

#### Вариант A: Через GitHub Actions (рекомендуется)

1. Переключитесь на main и обновите:
```bash
git checkout main
git pull origin main
```

2. Мержите develop в main:
```bash
git merge develop
git push origin main
```

3. В GitHub: Actions → Production Release → Run workflow
4. Введите версию (например: `v1.0.0`)
5. Workflow создаст тег и релиз

#### Вариант B: Через Makefile

```bash
# 1. Переключиться на main
git checkout main
git pull origin main

# 2. Мерж develop
git merge develop
git push origin main

# 3. Создать тег
make tag VERSION=v1.0.0
```

**⚠️ ВАЖНО**: 
- Production релизы можно создавать ТОЛЬКО из main ветки
- Тег должен быть в формате `v<major>.<minor>.<patch>` (без суффиксов)

## 📝 Правила версионирования (Semantic Versioning)

- **MAJOR** (v1.0.0 → v2.0.0): Breaking changes
- **MINOR** (v1.0.0 → v1.1.0): Новые функции без breaking changes
- **PATCH** (v1.0.0 → v1.0.1): Исправления багов без breaking changes

## 🔍 Проверки перед коммитом

Перед каждым коммитом убедитесь:

```bash
# 1. Форматирование
make format

# 2. Линтинг
make lint

# 3. Breaking changes (если нужно)
make breaking

# 4. Генерация кода
make generate

# 5. Проверка что все закоммичено
git status
```

## 🚨 Частые ошибки

### ❌ Ошибка: "Generated code is out of sync"
**Решение**: Запустите `make generate` и закоммитьте изменения в `gen/`

### ❌ Ошибка: "Proto files are not formatted"
**Решение**: Запустите `make format` и закоммитьте изменения

### ❌ Ошибка: "Breaking changes detected"
**Решение**: 
- Проверьте изменения: `make breaking`
- Если breaking changes намеренные, увеличьте MAJOR версию
- Если нет, исправьте изменения чтобы они были обратно совместимы

### ❌ Ошибка: "Pre-release tags can only be created from develop"
**Решение**: Убедитесь что вы создаете pre-release тег из develop ветки

### ❌ Ошибка: "Production releases can only be created from main"
**Решение**: Убедитесь что вы создаете production релиз из main ветки

## 📊 Схема workflow

```
feature branch
    │
    ├─→ PR → develop ──→ beta версии (v1.0.0-beta.N)
    │                        │
    │                        └─→ (накопление изменений)
    │                                    │
    └────────────────────────────────────┘
                                         │
                                    merge to main
                                         │
                                         └─→ production (v1.0.0)
```

## 🛠️ Полезные команды

```bash
# Показать все команды
make help

# Установить инструменты
make install-tools

# Очистить сгенерированный код
make clean

# Проверить все перед коммитом
make format && make lint && make generate

# Посмотреть существующие теги
git tag --sort=-creatordate

# Посмотреть информацию о теге
git show v1.0.0
```

## 📌 Чеклист перед релизом

- [ ] Все изменения закоммичены
- [ ] Все тесты пройдены
- [ ] Линтинг пройден (`make lint`)
- [ ] Форматирование применено (`make format`)
- [ ] Breaking changes проверены (`make breaking`)
- [ ] Код сгенерирован (`make generate`)
- [ ] Изменения закоммичены в gen/
- [ ] PR создан и прошел все проверки CI
- [ ] PR замержен в develop (для beta) или main (для production)
- [ ] Версия соответствует Semantic Versioning

