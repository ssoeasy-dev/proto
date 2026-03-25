#!/bin/bash
# Определяет тип инкремента на основе коммитов между двумя ревизиями
# Аргументы: $1 = базовая ревизия (например, origin/main), $2 = HEAD
# Выводит: major|minor|patch|none

BASE=${1:-HEAD~}
HEAD=${2:-HEAD}

# Проверяем наличие BREAKING CHANGE в сообщениях
if git log "$BASE..$HEAD" --oneline | grep -qiE "major:|BREAKING CHANGE"; then
    echo "major"
    exit 0
fi

# Проверяем наличие feat: или minor:
if git log "$BASE..$HEAD" --oneline | grep -qiE "feat:|minor:"; then
    echo "minor"
    exit 0
fi

# Проверяем наличие fix:
if git log "$BASE..$HEAD" --oneline | grep -qiE "fix:"; then
    echo "patch"
    exit 0
fi

echo "none"
