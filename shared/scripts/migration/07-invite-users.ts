import * as fs from 'fs';
import * as path from 'path';
import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config({ path: path.resolve(process.cwd(), '../../.env') });

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const IN_DIR = path.join(DIR, 'transformed');

const supabase = createClient(
  process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

async function run() {
  const file = path.join(IN_DIR, 'profiles.json');
  if (!fs.existsSync(file)) {
    console.error('profiles.json not found in transformed/');
    process.exit(1);
  }

  const profiles = JSON.parse(fs.readFileSync(file, 'utf-8'));
  
  console.log(`Ready to invite ${profiles.length} users. This will send actual emails.`);
  console.log(`Wait 5 seconds to abort...`);
  await new Promise(r => setTimeout(r, 5000));

  let count = 0;
  for (const p of profiles) {
    if (!p.email) continue;

    console.log(`Inviting ${p.email}...`);
    
    const { data: authData, error: authErr } = await supabase.auth.admin.inviteUserByEmail(p.email);
    if (authErr) {
      console.error(`  Error inviting ${p.email}:`, authErr.message);
      continue;
    }

    const newUserId = authData.user.id;

    // Update profile record with imported roles/passcodes, but link to new auth ID
    const { error: profileErr } = await supabase.from('profiles').update({
      role: p.role,
      whatsapp: p.whatsapp,
      passcode_hash: null, // Clear old passcode to force reset as per prompt requirements
      force_password_reset: true
    }).eq('id', newUserId);

    if (profileErr) {
      console.error(`  Error updating profile for ${p.email}:`, profileErr.message);
    } else {
      count++;
    }
  }

  console.log(`Successfully invited and updated ${count} / ${profiles.length} users.`);
}

run();
