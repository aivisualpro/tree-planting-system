import * as fs from 'fs';
import * as path from 'path';
import { z } from 'zod';

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const IN_DIR = path.join(DIR, 'transformed');
const REPORTS_DIR = path.join(DIR, 'reports');

const schemas: Record<string, z.ZodTypeAny> = {
  profiles: z.object({
    id: z.string().uuid(),
    email: z.string().email(),
    role: z.enum(['super_admin', 'admin', 'coordinator', 'field_user', 'viewer']),
    whatsapp: z.string().nullable(),
    passcode_hash: z.string(),
    force_password_reset: z.boolean()
  }),
  visits: z.object({
    id: z.string().uuid(),
    client_uuid: z.string(),
    country_id: z.string().uuid(),
    core_area_id: z.string().uuid(),
    activity_id: z.string().uuid(),
    trees_planted: z.number().min(0),
    attendance: z.number().min(0),
    created_by: z.string().uuid(),
    created_at: z.string().datetime(),
    status: z.enum(['draft', 'scheduled', 'completed', 'cancelled'])
  })
};

async function validate() {
  const files = fs.readdirSync(IN_DIR).filter(f => f.endsWith('.json'));
  const rejects: Record<string, any[]> = {};
  
  for (const file of files) {
    const table = file.replace('.json', '');
    const data = JSON.parse(fs.readFileSync(path.join(IN_DIR, file), 'utf-8'));
    
    const schema = schemas[table] || z.object({ id: z.string().uuid() }).passthrough(); // default loosely validates id
    
    rejects[table] = [];
    
    for (const row of data) {
      const res = schema.safeParse(row);
      if (!res.success) {
        rejects[table].push({ row, errors: res.error.errors });
      }
    }
    
    if (rejects[table].length === 0) {
      delete rejects[table];
    } else {
      console.warn(`Validation: ${rejects[table].length} rejected rows in ${table}`);
    }
  }
  
  fs.writeFileSync(path.join(REPORTS_DIR, 'rejects.json'), JSON.stringify(rejects, null, 2));
  console.log(`Validation complete. Rejects written to reports/rejects.json`);
}

validate();
