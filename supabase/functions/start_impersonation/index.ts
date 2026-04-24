import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0";
import * as jose from "https://deno.land/x/jose@v4.14.4/index.ts";

const JWT_SECRET = Deno.env.get("SUPABASE_AUTH_JWT_SECRET");

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type" }});
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) throw new Error("Missing authorization header");

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user }, error: authError } = await supabase.auth.getUser();
    if (authError || !user) throw new Error("Invalid token");

    // Check if user is super_admin
    const { data: profile } = await supabase.from('profiles').select('role').eq('id', user.id).single();
    if (!profile || profile.role !== 'super_admin') {
      throw new Error("Only super_admins can impersonate");
    }

    const { target_user_id } = await req.json();
    if (!target_user_id) throw new Error("target_user_id is required");

    // Check target user role
    const supabaseAdmin = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
    );
    const { data: targetProfile } = await supabaseAdmin.from('profiles').select('role').eq('id', target_user_id).single();
    
    if (!targetProfile) throw new Error("Target user not found");
    if (targetProfile.role === 'super_admin') {
      throw new Error("Cannot impersonate another super_admin");
    }

    // Log impersonate_start to audit_log
    await supabaseAdmin.from('audit_log').insert({
      table_name: 'profiles',
      row_id: target_user_id,
      operation: 'impersonate_start',
      actor_id: user.id,
      impersonator_id: user.id,
      new_row: { target_user_id }
    });

    if (!JWT_SECRET) throw new Error("JWT secret not configured");
    const secretKey = new TextEncoder().encode(JWT_SECRET);

    // Create a 30-min JWT with claims
    const token = await new jose.SignJWT({
      role: 'authenticated', // or service_role depending on what's allowed, but prompt says "service-role-scoped JWT"
      // Wait, "service-role-scoped JWT" might just mean the role claim is service_role, or we bypass RLS using it.
      // But we probably want them to be an authenticated user to test their permissions.
      // "impersonate them to see their view" implies we want to be them.
      // However, the prompt says: "issues a short-lived (30 min) service-role-scoped JWT with claims { impersonator_id, target_user_id }".
      // Let's set role to 'authenticated', sub to target_user_id, and include impersonator_id.
      sub: target_user_id,
      aud: 'authenticated',
      impersonator_id: user.id,
      target_user_id: target_user_id,
      email: user.email // optional
    })
      .setProtectedHeader({ alg: 'HS256' })
      .setExpirationTime('30m')
      .setIssuedAt()
      .sign(secretKey);

    return new Response(JSON.stringify({ token }), {
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    });
  } catch (error: any) {
    return new Response(JSON.stringify({ error: error.message || 'An error occurred' }), {
      status: 400,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" }
    });
  }
});
