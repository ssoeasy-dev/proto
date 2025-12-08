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

function createModuleIndexes() {
  for (const mod of modules) {
    const modDir = path.join(GEN_TS_DIR, mod);
    const v1Dir = path.join(modDir, 'v1');

    if (!fs.existsSync(v1Dir)) {
      console.log(`⚠️  Skipping ${mod}: v1 directory not found`);
      continue;
    }

    // Найти все .ts файлы в v1
    const tsFiles = fs.readdirSync(v1Dir).filter((f) => f.endsWith('.ts') && f !== 'index.ts');

    if (tsFiles.length === 0) {
      console.log(`⚠️  Skipping ${mod}: no .ts files found`);
      continue;
    }

    // Создать v1/index.ts
    const v1Exports = tsFiles.map((f) => `export * from './${f.replace('.ts', '')}';`).join('\n');

    fs.writeFileSync(path.join(v1Dir, 'index.ts'), `// Auto-generated\n${v1Exports}\n`);
    console.log(`✅ Created gen/ts/${mod}/v1/index.ts`);
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

