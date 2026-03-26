#!/bin/bash
# Скрипт для синхронизации версии package.json с git тегом

set -e

# Получаем текущий git тег или версию из аргументов
if [ -n "$1" ]; then
    VERSION="$1"
else
    # Пытаемся получить версию из текущего git тега
    VERSION=$(git describe --tags --exact-match 2>/dev/null || git describe --tags --abbrev=0 2>/dev/null || echo "")
    
    if [ -z "$VERSION" ]; then
        echo "❌ Error: No git tag found and no version provided"
        echo "Usage: $0 <version>"
        echo "   or: git tag v1.0.0 && $0"
        exit 1
    fi
fi

# Убираем префикс 'v' если есть (npm версии не используют префикс v)
NPM_VERSION="${VERSION#v}"

# Проверяем формат версии (должен быть x.y.z или x.y.z-pre)
if [[ ! "$NPM_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-.*)?$ ]]; then
    echo "❌ Error: Invalid version format: $NPM_VERSION"
    echo "Expected format: x.y.z or x.y.z-pre (e.g., 1.0.0 or 1.0.0-beta.1)"
    exit 1
fi

echo "🔄 Syncing package.json version to $NPM_VERSION (from git tag $VERSION)"

# Определяем путь к корню проекта (где находится package.json)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGE_JSON="$PROJECT_ROOT/package.json"

# Обновляем версию в package.json используя node
node -e "
const fs = require('fs');
const packagePath = '$PACKAGE_JSON';
const package = JSON.parse(fs.readFileSync(packagePath, 'utf8'));
package.version = '$NPM_VERSION';
fs.writeFileSync(packagePath, JSON.stringify(package, null, 2) + '\n');
"

echo "✅ Version updated in package.json to $NPM_VERSION"

