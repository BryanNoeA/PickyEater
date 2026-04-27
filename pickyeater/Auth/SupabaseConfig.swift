import Foundation
import Supabase

// ─────────────────────────────────────────────────────────────────────────────
// SETUP — fill in these three values before building:
//
// 1. Go to supabase.com → your project → Settings → API
//    Copy "Project URL" → SupabaseConfig.url
//    Copy "anon public" key → SupabaseConfig.anonKey
//
// 2. Go to Google Cloud Console → your OAuth client → copy the iOS client ID
//    → SupabaseConfig.googleClientID
//    Also add your reversed client ID as a URL scheme in Info.plist:
//    Key: CFBundleURLTypes → Item 0 → CFBundleURLSchemes → YOUR_REVERSED_CLIENT_ID
//    e.g. com.googleusercontent.apps.123456-abcdef
//
// 3. In Xcode → Signing & Capabilities → "+" → Sign in with Apple
// ─────────────────────────────────────────────────────────────────────────────

enum SupabaseConfig {
    static let url     = URL(string: "https://tlklqyusyxbrhexkqbme.supabase.co")!
    static let anonKey = "sb_publishable_YDHndFJl1WH-XpY7JIK0KQ_xOKeGveO"

    // Google uses TWO different formats for the same credential:
    //
    // googleClientID        → full format, passed to GIDConfiguration in code
    //                         looks like: 74039435310-abc123.apps.googleusercontent.com
    //
    // googleReversedClientID → reversed format, used as a URL scheme in Info.plist
    //                          so iOS can redirect back to the app after Google sign-in
    //                          looks like: com.googleusercontent.apps.74039435310-abc123
    //
    // Both values come from the same OAuth client in Google Cloud Console.
    static let googleClientID         = "74039435310-tpt8gfj019oblbn2oerkgc537k9ialuc.apps.googleusercontent.com"
    static let googleReversedClientID = "com.googleusercontent.apps.74039435310-tpt8gfj019oblbn2oerkgc537k9ialuc"

    /// Single shared client used by AuthManager and ProfileManager.
    /// SupabaseClient is thread-safe and designed to be a singleton.
    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey,
        options: SupabaseClientOptions(
            auth: SupabaseClientOptions.AuthOptions(
                // Opt into the new session-emission behavior now so the
                // deprecation warning doesn't appear in the console.
                // This will become the default in the next major SDK release.
                emitLocalSessionAsInitialSession: true
            )
        )
    )
}

// ─────────────────────────────────────────────────────────────────────────────
// SUPABASE SQL SETUP — run this in the Supabase SQL Editor once:
//
// -- 1. Create the profiles table
// CREATE TABLE public.profiles (
//   id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
//   is_premium            BOOLEAN NOT NULL DEFAULT FALSE,
//   premium_purchased_at  TIMESTAMPTZ,
//   apple_user_identifier TEXT UNIQUE,   -- deduplication for Sign in with Apple
//   preferences           JSONB,         -- V2 AI mode preferences live here
//   created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
//   updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
// );
//
// -- 2. Auto-create a profile row when a user signs up (any provider)
// CREATE OR REPLACE FUNCTION public.handle_new_user()
// RETURNS trigger AS $$
// BEGIN
//   INSERT INTO public.profiles (id) VALUES (NEW.id)
//   ON CONFLICT (id) DO NOTHING;
//   RETURN NEW;
// END;
// $$ LANGUAGE plpgsql SECURITY DEFINER;
//
// CREATE TRIGGER on_auth_user_created
//   AFTER INSERT ON auth.users
//   FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
//
// -- 3. Row Level Security — users can only touch their own row
// ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
//
// CREATE POLICY "select own profile" ON public.profiles
//   FOR SELECT USING (auth.uid() = id);
// CREATE POLICY "update own profile" ON public.profiles
//   FOR UPDATE USING (auth.uid() = id);
// CREATE POLICY "delete own profile" ON public.profiles
//   FOR DELETE USING (auth.uid() = id);
// CREATE POLICY "insert own profile" ON public.profiles
//   FOR INSERT WITH CHECK (auth.uid() = id);
//
// -- 4. Enable automatic account linking in Supabase dashboard:
//    Auth → Settings → "Allow automatic linking of accounts with same email"
//    This merges Google + email accounts that share the same verified email.
// ─────────────────────────────────────────────────────────────────────────────
