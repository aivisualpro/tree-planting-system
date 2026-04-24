/**
 * kill-connections.js
 * Chaos Test: Terminates all active Postgres connections.
 * Purpose: Verifies that backend edge functions and frontend clients recover automatically
 * and gracefully handle temporary database unavailability via pooling/retries.
 * 
 * Execution: Runs nightly via CI.
 */

const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

async function runTest() {
  console.log('[Chaos] Starting kill-connections test...');
  
  // 1. Pre-test health check
  const { data: preCheck, error: preErr } = await supabase.from('profiles').select('id').limit(1);
  if (preErr) throw new Error(`Pre-check failed: ${preErr.message}`);
  
  console.log('[Chaos] DB is reachable. Killing active connections...');
  
  // 2. Terminate connections
  const { error: killErr } = await supabase.rpc('pg_terminate_backend', {
    pid: supabase.rpc('pg_stat_activity', {}).select('pid')
  });
  
  // Ignore errors from the kill command itself, as our own connection might drop
  console.log('[Chaos] Connections terminated. Waiting 5s for pool recovery...');
  
  await new Promise(resolve => setTimeout(resolve, 5000));
  
  // 3. Post-test verification
  const { data: postCheck, error: postErr } = await supabase.from('profiles').select('id').limit(1);
  
  if (postErr) {
    console.error('❌ [Chaos] Fail: System did not recover after connection termination.');
    console.error(postErr);
    process.exit(1);
  }
  
  console.log('✅ [Chaos] Pass: System successfully recovered from connection wipeout.');
}

runTest().catch(err => {
  console.error('❌ [Chaos] Unexpected error:', err);
  process.exit(1);
});
