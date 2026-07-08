# Picky Eater — Audit Findings & Implementation Plan

Written 2026-07-06 from a full security + optimization audit. Hand this file to Claude/Sonnet
to implement. Work top to bottom — phases are ordered by impact and dependency.
Check items off as they're completed.

**Decisions already made (do not re-litigate):**
- Stay a $2.99 one-time purchase (non-consumable IAP). No subscription until FeedMe ships with real API costs.
- **Remove Supabase entirely for v1.** StoreKit 2 `Transaction.currentEntitlements` becomes the sole
  source of truth for premium — it syncs across the user's devices via Apple ID and can't be forged.
  This deletes the auth flow, the RLS premium-self-grant vulnerability, and the account-deletion
  App Review risk in one move. Supabase returns later only as an Edge Function proxy for FeedMe (V2).

---

## Phase 1 — Critical bug fixes

### 1.1 Wheel reports the wrong category on ~half of spins
`pickyeater/Spinner/WheelView.swift:115` — the `+ sliceAngle / 2` turns the slice lookup into
round-to-nearest, so any spin landing in the second half of a slice reports the *next* slice,
disagreeing with what's visually under the pointer.

- [ ] Fix the math:
  ```swift
  let normalized = rotationDegrees.truncatingRemainder(dividingBy: 360)
  let adjusted   = (360 - normalized).truncatingRemainder(dividingBy: 360)
  let index      = Int(adjusted / sliceAngle) % categories.count
  ```
- [ ] Extract the landing math into a testable pure function, e.g.
  `static func category(forRotation degrees: Double) -> FoodCategory`.
- [ ] Add a Swift Testing test (`@Test`, `#expect`) spinning known angles through it:
  0° → slice 0, just under one sliceAngle → still slice 0, exactly sliceAngle → slice 1,
  359.9° → slice 11, plus a couple of multi-rotation values.

### 1.2 Mid-spin mode toggle strands the spin
`pickyeater/Spinner/SpinnerView.swift:66-80` + `pickyeater/Spinner/DiceView.swift` — toggling
wheel/dice while spinning destroys the animating view; the orphaned Task delivers a result from
a dead view.

- [ ] Disable `SpinToggleView` while `viewModel.isSpinning`.
- [ ] In `DiceView`, cancel `timerTask` in `.onDisappear`.

---

## Phase 2 — Remove Supabase, premium via StoreKit only

Goal: `StoreKitManager.isPurchased` is the single premium flag app-wide. No accounts, no backend.

- [ ] Delete the `Auth/` directory: `AuthManager`, `AuthView`, `AuthViewModel`, `AccountView`,
      `ProfileManager`, `SupabaseConfig`, `UserProfile`, `GoogleGLogo`.
- [ ] Remove SPM dependencies: `supabase-swift`, `GoogleSignIn-iOS`.
- [ ] Remove Google URL scheme from `Info.plist` (`CFBundleURLTypes`) and the
      `onOpenURL` → `GIDSignIn.handle` call in `pickyeaterApp.swift`.
- [ ] Remove Sign in with Apple from `pickyeater.entitlements` (no longer needed).
- [ ] Replace every `ProfileManager.isPremium` read (e.g. `ResultNearbySection`) with
      `storeKit.isPurchased` via `@Environment(StoreKitManager.self)`.
- [ ] Delete `PaywallAuthGate.swift` — paywall no longer requires sign-in.
- [ ] Remove auth/account rows from `SettingsView`; keep Restore Purchases, privacy policy,
      version info.
- [ ] Update/remove `SUPABASE_AUTH_SETUP.md` and the Supabase sections of `PROJECT_CONTEXT.md`
      and `TODO.md` so docs match reality.
- [ ] Build must compile clean with zero references to Supabase or GoogleSignIn.

Note: this makes the old "isPremium hardcoded true" blocker moot — the hardcode is deleted with
the file. Verify no other hardcoded premium bypass remains (`grep -ri "isPremium" pickyeater/`).

---

## Phase 3 — StoreKit hardening

`pickyeater/Premium/StoreKitManager.swift`, `pickyeater/App/pickyeaterApp.swift:44-47`

- [ ] Start the transaction listener FIRST, before `loadProducts()` / `checkPurchaseStatus()`
      (currently started after both awaits — updates in that window are dropped).
- [ ] Use `[weak self]` in the `Transaction.updates` loop (currently retains self forever;
      the `deinit` cancel is dead code).
- [ ] Surface `.pending` distinctly: `purchase()` should return/expose a state enum
      (`success | pending | cancelled | failed`) so `PaywallViewModel` can show
      "Awaiting approval…" for ask-to-buy/SCA instead of "Purchase could not be completed."
      The transaction listener flips `isPurchased` when the pending purchase clears.

---

## Phase 4 — Restaurant search fixes

`pickyeater/Restaurants/RestaurantListView.swift`, `RestaurantViewModel.swift`

- [ ] **Race:** overlapping searches from `onChange(of: currentLocation)` and
      `onChange(of: radiusMiles)` can finish out of order; stale results win. Replace both
      `onChange`s with a single `.task(id:)` keyed on a `Hashable` pair of (location, radius) —
      cancellation comes free. Alternatively hold `searchTask: Task<Void, Never>?` in the VM,
      cancel at the top of `search()`, check `Task.isCancelled` before assigning results.
- [ ] **Premature empty state:** first render shows "no results" while GPS/permission is still
      resolving. Treat `currentLocation == nil && errorMessage == nil` as loading.
- [ ] **Duplicated error state:** render `viewModel.errorMessage ?? viewModel.locationError`
      directly; delete the `onChange` that copies one into the other.
- [ ] `RestaurantListContent.swift:10` — `ForEach` keyed by index; use the MKMapItem identifier.

---

## Phase 5 — Small fixes

- [ ] `pickyeater/History/HistoryView.swift:118` — replace row-by-row delete with
      `try? modelContext.delete(model: SpinResult.self)`.
- [ ] `pickyeater/Settings/SettingsView.swift:105` — replace `https://example.com/privacy`
      with the real hosted privacy policy URL (human must supply the URL; leave a
      `// TODO(bryan):` if not yet available).

---

## Phase 6 — Verification before ship

- [ ] Full build succeeds (use BuildProject per CLAUDE.md).
- [ ] Run all tests (RunAllTests) — wheel landing-math tests pass.
- [ ] Manual checklist: free tier fully works with no purchase; paywall shows
      `product.displayPrice`; Restore Purchases visible and functional; location permission
      only prompts on entering the restaurant flow; airplane mode shows graceful error,
      no crash.
- [ ] Update `PROJECT_CONTEXT.md` file map and `TODO.md` to reflect the removed Auth layer.

---

## Backlog (post-1.0, do NOT implement now)

Ordered by value-per-effort:
1. **Custom categories** — add/remove/edit wedges. Best premium-feature candidate.
2. **Home-screen widget + App Intents** — "Spin" widget, Siri/Shortcuts support.
3. **Group spin** — pass-the-phone veto mode (or SharePlay).
4. **History insights** — "pizza 4× this month" streaks.
5. **FeedMe (V2)** — try Apple's on-device Foundation Models first (zero API cost, no proxy);
   fall back to Claude Haiku behind a server-side proxy. This is the moment a subscription or
   consumable credits becomes justified — and the moment RevenueCat is worth adding.

Skip permanently: social features, photos, reviews (Yelp's turf).

---

## Security audit — items resolved by this plan

| Finding | Severity | Resolution |
|---|---|---|
| `isPremium` hardcoded true (`ProfileManager.swift:29`) | Critical | Deleted in Phase 2 |
| RLS lets any user self-grant premium via REST | High | Supabase removed (Phase 2) |
| Account deletion incomplete (App Review 5.1.1) | Medium | No accounts → requirement vanishes (Phase 2) |
| Nonce gen ignores `SecRandomCopyBytes` failure | Low | Auth deleted (Phase 2) |
| Sign-out doesn't clear Google session | Low | Auth deleted (Phase 2) |
| Offline purchase grants premium locally with no server record | Medium | StoreKit is sole source of truth (Phase 2) |

Verified clean and requiring no action: no secrets in repo or git history; full ATS; Keychain
session storage; lazy when-in-use location that never leaves the device; zero logging leaks;
minimal entitlements; SPM-only first-party dependencies.
