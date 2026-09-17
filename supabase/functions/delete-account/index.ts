// delete-account — permanently deletes the calling user's Show Up account.
//
// Called from the app's Settings > Account > Delete Account flow
// (lib/src/features/settings/settings_screen.dart) via
// `Supabase.instance.client.functions.invoke('delete-account')`.
//
// The caller's identity is derived from their own session JWT (passed
// automatically as the Authorization header by supabase-flutter) — never
// from a client-supplied user id — so this can only ever delete the
// account making the request.
//
// Show Up's tables aren't foreign-keyed to auth.users (no ON DELETE
// CASCADE), so each table is cleared explicitly before the auth user
// itself is removed. This project's Supabase instance also hosts an
// unrelated trading app's tables (trades, watched_tickers, etc.) — this
// list is scoped to only Show Up's own tables.
//
// issue_reports is deliberately NOT cleared here — support-ticket history
// is kept even after the reporting account is gone (standard practice; the
// admin dashboard falls back to "Unknown user" for an issue whose reporter
// no longer has a profile row).
//
// Deployed with: supabase functions deploy delete-account --project-ref <ref>

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

const SHOW_UP_USER_TABLES = [
  'habit_completions',
  'habit_skips',
  'habits',
  'food_entries',
  'meals',
  'water_logs',
  'daily_nutrition_goals',
  'pantry_foods',
  'user_roles',
] as const

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }
  if (req.method !== 'POST') {
    return jsonResponse({ error: 'Method not allowed' }, 405)
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return jsonResponse({ error: 'Missing Authorization header' }, 401)
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

  // Resolve the caller from their own JWT — this is the only source of
  // truth for which account gets deleted.
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  })
  const {
    data: { user },
    error: userError,
  } = await callerClient.auth.getUser()

  if (userError || !user) {
    return jsonResponse({ error: 'Invalid session' }, 401)
  }

  const admin = createClient(supabaseUrl, serviceRoleKey)

  // Clear this user's rows first. If the auth user were deleted first and
  // one of these deletes then failed, the data would be orphaned under a
  // user id that no longer exists; clearing data first means a failure
  // leaves an intact (if empty) account instead.
  for (const table of SHOW_UP_USER_TABLES) {
    const { error } = await admin.from(table).delete().eq('user_id', user.id)
    if (error) {
      return jsonResponse({ error: `Failed clearing ${table}: ${error.message}` }, 500)
    }
  }

  const { error: profileError } = await admin.from('profiles').delete().eq('id', user.id)
  if (profileError) {
    return jsonResponse({ error: `Failed clearing profile: ${profileError.message}` }, 500)
  }

  const { error: deleteUserError } = await admin.auth.admin.deleteUser(user.id)
  if (deleteUserError) {
    return jsonResponse({ error: deleteUserError.message }, 500)
  }

  return jsonResponse({ success: true }, 200)
})
