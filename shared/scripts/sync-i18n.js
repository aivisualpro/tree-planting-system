import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const sourceDir = path.join(__dirname, '../i18n');
const flutterDir = path.join(__dirname, '../../mobile/lib/l10n');

if (!fs.existsSync(flutterDir)) {
  fs.mkdirSync(flutterDir, { recursive: true });
}

const files = fs.readdirSync(sourceDir).filter(f => f.endsWith('.json'));

for (const file of files) {
  const content = fs.readFileSync(path.join(sourceDir, file), 'utf8');
  const json = JSON.parse(content);
  
  const arb = {};
  
  if (file === 'en.json') {
    arb['@@locale'] = 'en';
  } else {
    arb['@@locale'] = file.replace('.json', '');
  }

  for (const [key, value] of Object.entries(json)) {
    if (!key.startsWith('_')) {
      arb[key] = value;
      if (file === 'en.json') {
        arb[`@${key}`] = {
          description: `Description for ${key}`
        };
      }
    }
  }

  const locale = file.replace('.json', '');
  fs.writeFileSync(
    path.join(flutterDir, `app_${locale}.arb`),
    JSON.stringify(arb, null, 2)
  );
}

console.log('Successfully synced shared/i18n/ to mobile/lib/l10n/');
