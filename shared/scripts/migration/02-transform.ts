import * as fs from 'fs';
import * as path from 'path';
import Papa from 'papaparse';
import { v4 as uuidv4 } from 'uuid';
import * as bcrypt from 'bcryptjs';

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const DATA_DIR = path.join(DIR, 'data');
const OUT_DIR = path.join(DIR, 'transformed');

// Read CSV
function readCSV(filename: string) {
  try {
    const csvStr = fs.readFileSync(path.join(DATA_DIR, filename), 'utf-8');
    return Papa.parse<any>(csvStr, { header: true, skipEmptyLines: true }).data;
  } catch (e) {
    console.warn(`Warning: Could not read ${filename}`);
    return [];
  }
}

// Generate UUID from stable string or create new
const idMap = new Map<string, string>();
function getMappedId(oldId: string): string {
  if (!oldId) return uuidv4();
  if (!idMap.has(oldId)) idMap.set(oldId, uuidv4());
  return idMap.get(oldId)!;
}

async function transform() {
  const overridesPath = path.join(DIR, 'manual_overrides.json');
  const overrides = fs.existsSync(overridesPath) ? JSON.parse(fs.readFileSync(overridesPath, 'utf-8')) : {};
  
  // 1. Profiles (Users.csv)
  const usersCsv = readCSV('Users.csv');
  const profiles = [];
  for (const u of usersCsv) {
    const rawPass = u['Passcode'] || '000000';
    const hash = await bcrypt.hash(rawPass, 10);
    const id = getMappedId(u['Email']);
    profiles.push({
      id,
      email: u['Email'],
      role: (u['Role'] || 'field_user').toLowerCase(),
      whatsapp: u['WhatsApp'] || null,
      passcode_hash: hash,
      force_password_reset: true // Flagged for reset
    });
  }

  // 2. Masters (Deduped by name)
  const masterTables = [
    { file: 'Country.csv', name: 'countries', nameCol: 'Country Name' },
    { file: 'Core Areas.csv', name: 'core_areas', nameCol: 'Core Area' },
    { file: 'Activities.csv', name: 'activities', nameCol: 'Activity Name' },
    { file: 'Tree Species.csv', name: 'tree_species', nameCol: 'Species Name' },
    { file: 'Churches.csv', name: 'churches', nameCol: 'Church Name' },
    { file: 'Schools.csv', name: 'schools', nameCol: 'School Name' },
    { file: 'Units.csv', name: 'units', nameCol: 'Unit Name' },
  ];

  const masters: Record<string, any[]> = {};
  const translations: any[] = [];
  const transCols = ['Spanish', 'French', 'Amharic', 'Tanzania', 'Malawi', 'Thailand', 'Creole'];
  const localeMap: Record<string, string> = { 'Spanish': 'es', 'French': 'fr', 'Amharic': 'am', 'Tanzania': 'sw', 'Malawi': 'ny', 'Thailand': 'th', 'Creole': 'ht' };

  for (const table of masterTables) {
    const data = readCSV(table.file);
    const deduped = new Map();
    
    for (const row of data) {
      const name = row[table.nameCol];
      if (!name) continue;
      
      const newId = getMappedId(row['RecordID'] || name);
      
      if (!deduped.has(name)) {
        deduped.set(name, { id: newId, name_en: name, code: row['Code'] || name.substring(0, 3).toUpperCase() });
      }

      // Handle Translations
      for (const col of transCols) {
        if (row[col]) {
          translations.push({
            id: uuidv4(),
            entity_type: table.name === 'countries' ? 'country' : table.name.replace(/s$/, ''), // naive singular
            entity_id: newId,
            field: 'name',
            locale: localeMap[col],
            value: row[col]
          });
        }
      }
    }
    masters[table.name] = Array.from(deduped.values());
  }

  // Activity Units
  const actUnits = readCSV('Activity Units.csv');
  const activity_units = actUnits.map((au: any) => ({
    id: getMappedId(au['RecordID']),
    activity_id: getMappedId(au['Activity']),
    unit_id: getMappedId(au['Unit']),
    core_area_id: getMappedId(au['Core Area'])
  }));

  // 3. Visits & Visit Details
  const visitsCsv = readCSV('Visits.csv');
  const visits = [];
  const visit_trees = [];
  const visit_media = [];

  for (const v of visitsCsv) {
    const visitId = getMappedId(v['RecordID']);
    const creatorId = getMappedId(v['UserEmail']); // Mapping email to profile ID

    visits.push({
      id: visitId,
      client_uuid: v['RecordID'],
      country_id: getMappedId(v['Country']),
      core_area_id: getMappedId(v['Core Area']),
      activity_id: getMappedId(v['Activity']),
      community_id: getMappedId(v['Community']), // Sub-entities would be mapped
      trees_planted: Number(v['Total Trees'] || 0),
      attendance: Number(v['Attendance'] || 0),
      notes: v['Notes'] || '',
      created_by: creatorId,
      created_at: v['Date'] ? new Date(v['Date']).toISOString() : new Date().toISOString(),
      status: 'completed' // Assuming old data is completed
    });

    // Trees 1..9
    for (let i = 1; i <= 9; i++) {
      const species = v[`Tree Species ${i}`];
      const count = Number(v[`Tree Count ${i}`]);
      if (species && count > 0) {
        visit_trees.push({
          id: uuidv4(),
          visit_id: visitId,
          tree_species_id: getMappedId(species),
          quantity: count
        });
      }
    }

    // Media
    const mediaFields = [
      { key: 'Group Picture', kind: 'group_photo' },
      { key: 'Activity Picture 1', kind: 'activity_photo' },
      { key: 'Activity Picture 2', kind: 'activity_photo' },
      { key: 'Activity Picture 3', kind: 'activity_photo' },
      { key: 'Signature', kind: 'signature' },
    ];

    for (const mf of mediaFields) {
      if (v[mf.key]) {
        visit_media.push({
          id: uuidv4(),
          visit_id: visitId,
          kind: mf.kind,
          original_url: v[mf.key],
          upload_status: 'pending'
        });
      }
    }
  }

  // Write all transformed JSON
  fs.writeFileSync(path.join(OUT_DIR, 'profiles.json'), JSON.stringify(profiles, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'activity_units.json'), JSON.stringify(activity_units, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'visits.json'), JSON.stringify(visits, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'visit_trees.json'), JSON.stringify(visit_trees, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'visit_media.json'), JSON.stringify(visit_media, null, 2));
  fs.writeFileSync(path.join(OUT_DIR, 'translations.json'), JSON.stringify(translations, null, 2));

  for (const [key, val] of Object.entries(masters)) {
    fs.writeFileSync(path.join(OUT_DIR, `${key}.json`), JSON.stringify(val, null, 2));
  }

  console.log(`Transformed JSON saved to transformed/`);
}

transform();
