import * as fs from 'fs';
import * as path from 'path';
import Papa from 'papaparse';

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const DATA_DIR = path.join(DIR, 'data');
const REPORTS_DIR = path.join(DIR, 'reports');

interface AnalysisReport {
  files: Record<string, FileReport>;
  orphanReferences: Record<string, number>;
  duplicateTranslations: number;
}

interface FileReport {
  rowCount: number;
  nullRates: Record<string, string>;
  duplicateRecordIds: number;
  malformedDates: number;
  outOfRangeNumbers: number;
  encodingIssues: number;
}

function hasEncodingIssue(str: string) {
  return str.includes('') || /[^\x00-\x7F]/.test(str) && !/^[\p{L}\p{M}\p{Z}\p{P}\p{N}]+$/u.test(str);
}

async function analyze() {
  const files = fs.readdirSync(DATA_DIR).filter(f => f.endsWith('.csv'));
  const report: AnalysisReport = { files: {}, orphanReferences: {}, duplicateTranslations: 0 };
  
  // Basic structures for cross-referencing
  const sets: Record<string, Set<string>> = {};

  // First pass: Read all IDs
  for (const file of files) {
    const csvStr = fs.readFileSync(path.join(DATA_DIR, file), 'utf-8');
    const parsed = Papa.parse<any>(csvStr, { header: true, skipEmptyLines: true });
    
    sets[file] = new Set(parsed.data.map((r: any) => r['RecordID'] || r['ID'] || r['Id'] || r['id']));
    
    let nulls: Record<string, number> = {};
    let dupes = 0;
    let malformedDates = 0;
    let outOfRangeNumbers = 0;
    let encIssues = 0;
    let seenIds = new Set();
    
    parsed.data.forEach((row: any) => {
      const id = row['RecordID'] || row['ID'] || row['Id'] || row['id'];
      if (id) {
        if (seenIds.has(id)) dupes++;
        seenIds.add(id);
      }
      
      for (const [key, val] of Object.entries(row) as [string, string][]) {
        if (!val || val.trim() === '') {
          nulls[key] = (nulls[key] || 0) + 1;
        } else {
          // Check encoding
          if (hasEncodingIssue(val)) encIssues++;
          
          // Check dates
          if (key.toLowerCase().includes('date') && isNaN(Date.parse(val))) {
            malformedDates++;
          }
          
          // Check numbers
          if ((key.toLowerCase().includes('count') || key.toLowerCase().includes('quantity') || key.toLowerCase().includes('trees')) && !isNaN(Number(val))) {
            const num = Number(val);
            if (num < 0 || num > 1000000) outOfRangeNumbers++;
          }
        }
      }
    });
    
    const rowCount = parsed.data.length;
    const nullRates: Record<string, string> = {};
    for (const [k, v] of Object.entries(nulls)) {
      nullRates[k] = `${((v / rowCount) * 100).toFixed(2)}%`;
    }
    
    report.files[file] = {
      rowCount,
      nullRates,
      duplicateRecordIds: dupes,
      malformedDates,
      outOfRangeNumbers,
      encodingIssues: encIssues
    };
  }
  
  // Second pass: Cross reference logic (simplified)
  // Check Visits -> Activities, Core Areas, Countries, etc.
  if (sets['Visits.csv']) {
    const visitsStr = fs.readFileSync(path.join(DATA_DIR, 'Visits.csv'), 'utf-8');
    const visits = Papa.parse<any>(visitsStr, { header: true, skipEmptyLines: true }).data;
    let orphans = 0;
    visits.forEach((v: any) => {
      if (v['Activity'] && sets['Activities.csv'] && !sets['Activities.csv'].has(v['Activity'])) orphans++;
    });
    report.orphanReferences['visit.activity -> activities.csv'] = orphans;
  }
  
  fs.writeFileSync(path.join(REPORTS_DIR, 'analysis.json'), JSON.stringify(report, null, 2));
  console.log(`Analysis saved to reports/analysis.json`);
}

analyze();
