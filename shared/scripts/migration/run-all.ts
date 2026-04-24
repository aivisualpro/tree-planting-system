import { execSync } from 'child_process';
import { resolve } from 'path';
import * as fs from 'fs';

const scripts = [
  '01-analyze.ts',
  '02-transform.ts',
  '03-validate.ts',
  '04-load.ts',
  '05-media.ts',
  '06-verify.ts'
];

async function run() {
  const dir = resolve(process.cwd(), 'scripts/migration');
  
  // Ensure report dirs exist
  const reportsDir = resolve(dir, 'reports');
  const transformedDir = resolve(dir, 'transformed');
  const dataDir = resolve(dir, 'data'); // where CSVs live
  
  if (!fs.existsSync(reportsDir)) fs.mkdirSync(reportsDir, { recursive: true });
  if (!fs.existsSync(transformedDir)) fs.mkdirSync(transformedDir, { recursive: true });
  if (!fs.existsSync(dataDir)) {
    console.error(`Please place AppSheet CSV exports in ${dataDir}`);
    process.exit(1);
  }

  for (const script of scripts) {
    console.log(`\n========================================`);
    console.log(`Running ${script}...`);
    console.log(`========================================`);
    try {
      execSync(`tsx ${resolve(dir, script)}`, { stdio: 'inherit' });
    } catch (e) {
      console.error(`Script ${script} failed. Halting migration.`);
      process.exit(1);
    }
  }

  console.log('\nMigration complete! Please check reports/verification.md');
}

run();
