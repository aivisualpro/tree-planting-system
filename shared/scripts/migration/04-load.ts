import * as fs from 'fs';
import * as path from 'path';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(process.cwd(), '../../.env') }); // Or path to env

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const IN_DIR = path.join(DIR, 'transformed');
const REPORTS_DIR = path.join(DIR, 'reports');
const CHECKPOINT_FILE = path.join(REPORTS_DIR, 'checkpoint.json');

const supabase = createClient(
  process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

// Order of insertion is important due to foreign keys
const loadOrder = [
  { table: 'profiles', conflict: 'id' },
  { table: 'countries', conflict: 'id' },
  { table: 'core_areas', conflict: 'id' },
  { table: 'activities', conflict: 'id' },
  { table: 'tree_species', conflict: 'id' },
  { table: 'churches', conflict: 'id' },
  { table: 'schools', conflict: 'id' },
  { table: 'units', conflict: 'id' },
  { table: 'activity_units', conflict: 'id' },
  { table: 'visits', conflict: 'client_uuid' },
  { table: 'visit_trees', conflict: 'id' },
  { table: 'visit_media', conflict: 'id' },
  { table: 'translations', conflict: 'id' }
];

async function load() {
  if (!process.env.NUXT_PUBLIC_SUPABASE_URL && !process.env.SUPABASE_URL) {
    console.error("Missing Supabase URL");
    process.exit(1);
  }

  let checkpoints: Record<string, number> = {};
  if (fs.existsSync(CHECKPOINT_FILE)) {
    checkpoints = JSON.parse(fs.readFileSync(CHECKPOINT_FILE, 'utf-8'));
  }

  for (const { table, conflict } of loadOrder) {
    const file = path.join(IN_DIR, `${table}.json`);
    if (!fs.existsSync(file)) continue;

    const data = JSON.parse(fs.readFileSync(file, 'utf-8'));
    let startIdx = checkpoints[table] || 0;
    
    console.log(`Loading ${table}... (${startIdx}/${data.length})`);
    
    const batchSize = 500;
    for (let i = startIdx; i < data.length; i += batchSize) {
      const batch = data.slice(i, i + batchSize);
      
      const { error } = await supabase.from(table).upsert(batch, { onConflict: conflict });
      
      if (error) {
        console.error(`Error inserting into ${table} at index ${i}:`, error.message);
        process.exit(1);
      }
      
      checkpoints[table] = i + batch.length;
      fs.writeFileSync(CHECKPOINT_FILE, JSON.stringify(checkpoints, null, 2));
      console.log(`  Loaded ${i + batch.length} / ${data.length}`);
    }
  }
  
  console.log(`Data load complete!`);
}

load();
