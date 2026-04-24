import * as fs from 'fs';
import * as path from 'path';
import Papa from 'papaparse';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(process.cwd(), '../../.env') });

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const DATA_DIR = path.join(DIR, 'data');
const REPORTS_DIR = path.join(DIR, 'reports');

const supabase = createClient(
  process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

async function run() {
  const visitsCsvPath = path.join(DATA_DIR, 'Visits.csv');
  if (!fs.existsSync(visitsCsvPath)) return;

  const csvStr = fs.readFileSync(visitsCsvPath, 'utf-8');
  const allOldVisits = Papa.parse<any>(csvStr, { header: true, skipEmptyLines: true }).data;
  
  // Randomly sample up to 100
  const sampleSize = Math.min(allOldVisits.length, 100);
  const sample = [...allOldVisits].sort(() => 0.5 - Math.random()).slice(0, sampleSize);

  let passed = 0;
  let markdown = `# Migration Verification Report\n\n**Total Sampled:** ${sampleSize}\n\n`;

  for (const old of sample) {
    const recordId = old['RecordID'];
    
    // Fetch from Supabase
    const { data: current, error } = await supabase
      .from('visits')
      .select('*, visit_media(count), activities(name_en)')
      .eq('client_uuid', recordId)
      .single();

    if (error || !current) {
      markdown += `### ❌ FAIL: ${recordId}\n- Not found in Supabase.\n\n`;
      continue;
    }

    // Compare fields
    const diffs: string[] = [];
    if (Number(old['Total Trees'] || 0) !== current.trees_planted) {
      diffs.push(`Trees: AppSheet=${old['Total Trees']} vs Supabase=${current.trees_planted}`);
    }
    if (Number(old['Attendance'] || 0) !== current.attendance) {
      diffs.push(`Attendance: AppSheet=${old['Attendance']} vs Supabase=${current.attendance}`);
    }
    
    // Count media fields in old
    let oldMediaCount = 0;
    ['Group Picture', 'Activity Picture 1', 'Activity Picture 2', 'Activity Picture 3', 'Signature'].forEach(f => {
      if (old[f]) oldMediaCount++;
    });
    const currentMediaCount = current.visit_media[0]?.count || 0;
    
    if (oldMediaCount !== currentMediaCount) {
      diffs.push(`Media Count: AppSheet=${oldMediaCount} vs Supabase=${currentMediaCount}`);
    }

    if (diffs.length > 0) {
      markdown += `### ❌ FAIL: ${recordId}\n${diffs.map(d => `- ${d}`).join('\n')}\n\n`;
    } else {
      passed++;
      markdown += `### ✅ PASS: ${recordId}\n\n`;
    }
  }

  markdown = `# Verification Summary\n**Passed:** ${passed} / ${sampleSize}\n\n---\n\n` + markdown;
  
  fs.writeFileSync(path.join(REPORTS_DIR, 'verification.md'), markdown);
  console.log(`Verification complete. Passed: ${passed}/${sampleSize}. Report: reports/verification.md`);
}

run();
