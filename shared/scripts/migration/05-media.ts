import * as fs from 'fs';
import * as path from 'path';
import { createClient } from '@supabase/supabase-js';
import * as crypto from 'crypto';
import dotenv from 'dotenv';
// In a real scenario, we'd import 'googleapis' and authenticate with service account
// import { google } from 'googleapis';

dotenv.config({ path: path.resolve(process.cwd(), '../../.env') });

const DIR = path.resolve(process.cwd(), 'scripts/migration');
const IN_DIR = path.join(DIR, 'transformed');

const supabase = createClient(
  process.env.NUXT_PUBLIC_SUPABASE_URL || process.env.SUPABASE_URL || '',
  process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY || ''
);

const MAX_CONCURRENT = 10;
const MAX_RETRIES = 3;

async function sleep(ms: number) {
  return new Promise(r => setTimeout(r, ms));
}

// Dummy fetch drive file for scaffold
async function fetchDriveFile(url: string): Promise<Buffer> {
  // Real implementation: extract file ID from URL, use Drive API to download
  return Buffer.from('dummy image content ' + url);
}

async function uploadMedia(row: any, visitsMap: Map<string, string>) {
  if (row.upload_status === 'synced') return;

  const url = row.original_url;
  if (!url) return;

  let retries = 0;
  while (retries < MAX_RETRIES) {
    try {
      const buffer = await fetchDriveFile(url);
      const sha256 = crypto.createHash('sha256').update(buffer).digest('hex');
      const ext = 'jpg'; // detect actual ext
      const userId = visitsMap.get(row.visit_id) || 'unknown-user';
      const storagePath = `${userId}/${row.visit_id}/${sha256}.${ext}`;

      // Check if exists
      const { data: existing } = await supabase.storage.from('visit-media').list(`${userId}/${row.visit_id}`);
      const isUploaded = existing?.some(f => f.name === `${sha256}.${ext}`);

      if (!isUploaded) {
        const { error: uploadError } = await supabase.storage.from('visit-media').upload(storagePath, buffer, {
          contentType: 'image/jpeg',
          upsert: true
        });
        if (uploadError) throw uploadError;
      }

      await supabase.from('visit_media').update({
        storage_path: storagePath,
        upload_status: 'synced'
      }).eq('id', row.id);

      return;
    } catch (e: any) {
      retries++;
      if (retries === MAX_RETRIES) {
        console.error(`Failed to upload ${url} after ${MAX_RETRIES} attempts`, e.message);
        await supabase.from('visit_media').update({ upload_status: 'failed' }).eq('id', row.id);
      } else {
        await sleep(Math.pow(2, retries) * 1000); // exponential backoff
      }
    }
  }
}

async function run() {
  const file = path.join(IN_DIR, 'visit_media.json');
  if (!fs.existsSync(file)) return;
  const visitMedia = JSON.parse(fs.readFileSync(file, 'utf-8'));
  
  const visitsFile = path.join(IN_DIR, 'visits.json');
  const visits = fs.existsSync(visitsFile) ? JSON.parse(fs.readFileSync(visitsFile, 'utf-8')) : [];
  const visitsMap = new Map<string, string>();
  visits.forEach((v: any) => visitsMap.set(v.id, v.created_by));

  console.log(`Starting media upload for ${visitMedia.length} files...`);

  // Simple concurrency limiter
  for (let i = 0; i < visitMedia.length; i += MAX_CONCURRENT) {
    const chunk = visitMedia.slice(i, i + MAX_CONCURRENT);
    await Promise.all(chunk.map((row: any) => uploadMedia(row, visitsMap)));
    console.log(`Processed ${Math.min(i + MAX_CONCURRENT, visitMedia.length)} / ${visitMedia.length}`);
  }

  console.log(`Media migration complete.`);
}

run();
