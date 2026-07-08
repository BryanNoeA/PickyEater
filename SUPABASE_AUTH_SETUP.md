# Supabase Auth — Removed

Accounts and Supabase were removed (Phase 2 of the security audit). Premium is
now gated solely by `StoreKitManager.isPurchased` — no accounts, no backend,
no server-side premium record to spoof. See `AUDIT_PLAN.md` for details.
