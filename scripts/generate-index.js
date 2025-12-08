#!/usr/bin/env node

/**
 * Скрипт для генерации index.ts файлов после buf generate
 */

const fs = require('fs');
const path = require('path');

const GEN_TS_DIR = path.join(__dirname, '..', 'gen', 'ts');

// Модули для экспорта
const modules = ['auth', 'companies', 'services', 'abac', 'common'];

function createRootIndex() {
  const exports = modules
    .map((mod) => `export * as ${mod} from './${mod}/v1';`)
    .join('\n');

  const content = `// Auto-generated index file
${exports}
`;

  fs.writeFileSync(path.join(GEN_TS_DIR, 'index.ts'), content);
  console.log('✅ Created gen/ts/index.ts');
}

function getDirectlyExportedFiles(mod) {
  // Проверяем index.*.v1.ts файлы, которые генерируются автоматически
  // и могут экспортировать файлы напрямую
  const indexV1File = path.join(GEN_TS_DIR, `index.${mod}.v1.ts`);
  
  if (!fs.existsSync(indexV1File)) {
    return new Set();
  }

  const content = fs.readFileSync(indexV1File, 'utf8');
  const directlyExported = new Set();
  
  // Ищем прямые экспорты вида: export * from "./mod/v1/filename"
  const directExportRegex = new RegExp(`export \\* from ["']\\./${mod}/v1/([^"']+)"`, 'g');
  let match;
  while ((match = directExportRegex.exec(content)) !== null) {
    directlyExported.add(match[1]);
  }
  
  // Также проверяем, какие типы экспортируются из напрямую экспортированных файлов
  // чтобы исключить файлы, которые экспортируют те же типы
  const v1Dir = path.join(GEN_TS_DIR, mod, 'v1');
  if (fs.existsSync(v1Dir)) {
    directlyExported.forEach(fileName => {
      const filePath = path.join(v1Dir, `${fileName}.ts`);
      if (fs.existsSync(filePath)) {
        const fileContent = fs.readFileSync(filePath, 'utf8');
        // Извлекаем имена экспортируемых типов/интерфейсов
        const exportRegex = /export\s+(?:interface|type|const|class)\s+(\w+)/g;
        const exportedTypes = new Set();
        let typeMatch;
        while ((typeMatch = exportRegex.exec(fileContent)) !== null) {
          exportedTypes.add(typeMatch[1]);
        }
        
        // Проверяем другие файлы в той же директории на дубликаты
        const otherFiles = fs.readdirSync(v1Dir).filter(f => 
          f.endsWith('.ts') && 
          f !== `${fileName}.ts` && 
          f !== 'index.ts'
        );
        
        otherFiles.forEach(otherFile => {
          const otherFilePath = path.join(v1Dir, otherFile);
          const otherContent = fs.readFileSync(otherFilePath, 'utf8');
          // Проверяем, экспортирует ли этот файл те же типы
          const hasDuplicate = Array.from(exportedTypes).some(type => {
            const typeRegex = new RegExp(`export\\s+(?:interface|type|const|class)\\s+${type}\\b`);
            return typeRegex.test(otherContent);
          });
          
          if (hasDuplicate) {
            // Исключаем файл с дубликатами
            const otherFileName = otherFile.replace('.ts', '');
            directlyExported.add(otherFileName);
          }
        });
      }
    });
  }
  
  return directlyExported;
}

function createModuleIndexes() {
  for (const mod of modules) {
    const modDir = path.join(GEN_TS_DIR, mod);
    const v1Dir = path.join(modDir, 'v1');

    if (!fs.existsSync(v1Dir)) {
      console.log(`⚠️  Skipping ${mod}: v1 directory not found`);
      continue;
    }

    // Получить файлы, которые уже экспортируются напрямую в index.*.v1.ts
    const directlyExported = getDirectlyExportedFiles(mod);

    // Найти все .ts файлы в v1, исключая те, что уже экспортируются напрямую
    const tsFiles = fs.readdirSync(v1Dir).filter((f) => {
      if (!f.endsWith('.ts') || f === 'index.ts') {
        return false;
      }
      const fileName = f.replace('.ts', '');
      return !directlyExported.has(fileName);
    });

    // Если все файлы исключены, все равно создаем index.ts со всеми файлами
    // чтобы корневой index.ts мог импортировать модуль
    if (tsFiles.length === 0) {
      // Получаем все .ts файлы для создания index.ts
      const allTsFiles = fs.readdirSync(v1Dir).filter((f) => f.endsWith('.ts') && f !== 'index.ts');
      if (allTsFiles.length === 0) {
        console.log(`⚠️  Skipping ${mod}: no .ts files found`);
        continue;
      }
      // Создаем index.ts со всеми файлами
      const v1Exports = allTsFiles.map((f) => `export * from './${f.replace('.ts', '')}';`).join('\n');
      fs.writeFileSync(path.join(v1Dir, 'index.ts'), `// Auto-generated\n${v1Exports}\n`);
      console.log(`✅ Created gen/ts/${mod}/v1/index.ts (all files exported, ${allTsFiles.length} files)`);
      continue;
    }

    // Создать v1/index.ts
    const v1Exports = tsFiles.map((f) => `export * from './${f.replace('.ts', '')}';`).join('\n');

    fs.writeFileSync(path.join(v1Dir, 'index.ts'), `// Auto-generated\n${v1Exports}\n`);
    console.log(`✅ Created gen/ts/${mod}/v1/index.ts (excluded ${directlyExported.size} directly exported files)`);
  }
}

function main() {
  if (!fs.existsSync(GEN_TS_DIR)) {
    console.error('❌ gen/ts directory not found. Run buf generate first.');
    process.exit(1);
  }

  console.log('📦 Generating index files...\n');

  createModuleIndexes();
  createRootIndex();

  console.log('\n✅ Index generation complete!');
}

main();

