import { createClient } from '@supabase/supabase-js';
import * as fs from 'fs';
import * as path from 'path';
import { parse } from 'csv-parse/sync';
import dotenv from 'dotenv';

dotenv.config({ path: path.join(__dirname, '../../web/.env') });

const supabaseUrl = process.env.SUPABASE_URL || '';
const supabaseKey = process.env.SUPABASE_SERVICE_KEY || '';

const supabase = createClient(supabaseUrl, supabaseKey);

async function migrateTranslations(csvFilePath: string) {
  if (!fs.existsSync(csvFilePath)) {
    console.error(`CSV file not found: ${csvFilePath}`);
    return;
  }

  const fileContent = fs.readFileSync(csvFilePath, 'utf-8');
  const records = parse(fileContent, { columns: true, skip_empty_lines: true });

  console.log(`Loaded ${records.length} records from CSV.`);

  const translations = [];

  for (const record of records) {
    const entityType = record.entity_type;
    const entityId = record.entity_id;
    const field = record.field;

    // Loop through all keys to find language codes
    for (const key of Object.keys(record)) {
      if (!['entity_type', 'entity_id', 'field'].includes(key)) {
        const locale = key;
        const value = record[key] || null;

        translations.push({
          entity_type: entityType,
          entity_id: entityId,
          field: field,
          locale: locale,
          value: value
        });
      }
    }
  }

  console.log(`Preparing to insert ${translations.length} translations.`);

  // Batch insert
  const batchSize = 1000;
  for (let i = 0; i < translations.length; i += batchSize) {
    const batch = translations.slice(i, i + batchSize);
    const { error } = await supabase
      .from('translations')
      .upsert(batch, { onConflict: 'entity_type,entity_id,field,locale' });

    if (error) {
      console.error(`Error inserting batch ${i}:`, error);
    } else {
      console.log(`Inserted batch ${i} to ${i + batch.length}`);
    }
  }

  console.log('Migration complete.');
}

const args = process.argv.slice(2);
if (args.length > 0) {
  migrateTranslations(args[0]);
} else {
  console.log('Usage: ts-node migrate-translations.ts <path-to-csv>');
}
