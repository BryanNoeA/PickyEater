# Picky Eater — Project Context

Hand this file to Claude at the start of a new session to resume with full context.

---

## What the app is

iOS app that helps users decide what to eat using a spin wheel or dice roll. Picks from 12 food categories. Free tier = spin + dice + categories. Premium ($2.99 one-time) = nearby restaurant search via Apple Maps.

**Bundle ID:** `com.bryanalmejo.pickyeater.pickyeater`  
**IAP Product ID:** `com.bryanalmejo.pickyeater.premium`  
**Minimum iOS:** 17.0 (deployed target in Xcode)  
**Auth:** None — no accounts. Premium is device-local via StoreKit 2.  
**Maps:** MapKit + MKLocalSearch (no third-party APIs)

---

## Tech stack

- SwiftUI + Swift 6, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`
- `@Observable` for all ViewModels and managers
- SwiftData for spin history (`SpinResult`)
- StoreKit 2 for IAP — `StoreKitManager.isPurchased` is the single premium source of truth
- No third-party UI frameworks, no backend, no accounts

---

## Design system

All screens use the same warm design language:

| Token | Value |
|---|---|
| `Color.peBackground` | Named asset: `#FCF9F4` light / `#13110F` dark |
| `Color.persimmon` | `#FF5A1F` light / `#FF7B45` dark (AccentColor) |
| `Color.persimmonSoft` | Persimmon at 15% opacity (toggle active bg) |
| `Color.persimmonDark` | Darker persimmon (toggle active text) |
| Wedge colors | 12 soft pastels — `.wedgePizza` through `.wedgeMediterranean` |
| Sheet style | `.presentationBackground(Color.peBackground)` + `.presentationDragIndicator(.hidden)` + `.presentationCornerRadius(28)` |
| Sheet header | `ZStack` with centred drag handle capsule + trailing action button |
| Serif title | `.font(.system(size: 28, weight: .bold, design: .serif))` |
| Cards | `.background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))` |

---

## File map

```
pickyeater/
├── App/
│   ├── pickyeaterApp.swift       — entry point, injects all environments
│   └── ContentView.swift         — thin shell presenting SpinnerView
│
├── Shared/
│   ├── FoodCategory.swift        — 12 categories: pizza, sushi, mexican, burgers,
│   │                               ramen, bbq, indian, italian, seafood, korean,
│   │                               thai, mediterranean. Each has emoji, color, searchTerm
│   ├── AppColors.swift           — Color extension: peBackground, persimmon,
│   │                               persimmonSoft, persimmonDark, 12 wedge colors
│   ├── SpinMode.swift            — enum: wheel | dice
│   └── SpinResult.swift          — @Model: category (raw), spinMode, timestamp
│
├── Spinner/
│   ├── SpinnerView.swift         — main screen: serif title, custom toolbar, wheel/dice
│   ├── SpinnerViewModel.swift    — @Observable: isSpinning, lastResult, sheet booleans
│   ├── WheelView.swift           — Canvas wheel, rotationEffect animation, pointer overlay
│   ├── DiceView.swift            — rotation3DEffect tumble animation
│   ├── SpinButton.swift          — "Pick for me" capsule button, persimmon glow
│   ├── SpinToggleView.swift      — custom warm pill toggle (wheel / dice)
│   └── ToolbarIconButton.swift   — 38pt circular button, badge support, isActive tint
│
├── Result/
│   ├── ResultView.swift          — bottom sheet: drag handle + Spin Again, no NavStack
│   ├── ResultHeroCard.swift      — emoji (88pt) + "You're having…" + category name
│   ├── ResultShareButton.swift   — ShareLink "Share Your Pick"
│   └── ResultNearbySection.swift — premium: RestaurantListView; free: upgrade prompt
│
├── History/
│   └── HistoryView.swift         — bottom sheet: warm cards, serif title, empty state
│
├── Filters/
│   ├── FilterSettings.swift      — @Observable: openNow, radiusMiles (5-30, default 10)
│   │                               UserDefaults persistence, isActive computed
│   └── FilterView.swift          — bottom sheet: Open Now card, Radius slider card, Reset
│
├── Settings/
│   └── SettingsView.swift        — NavigationStack, warm cards,
│                                   hidden native nav bar on root
│
├── Premium/
│   ├── StoreKitManager.swift     — StoreKit 2: load, purchase, restore, transaction listener,
│   │                               isPurchased (single source of truth for premium)
│   ├── PaywallView.swift         — one-time purchase sheet
│   ├── PaywallViewModel.swift    — purchase/restore logic
│   ├── PaywallHeroSection.swift  — paywall header
│   ├── PaywallFeatureList.swift  — feature bullet list
│   ├── PaywallFeatureRow.swift   — single feature row
│   └── PaywallCTASection.swift   — buy/restore buttons
│
├── Restaurants/
│   ├── LocationManager.swift     — CLLocationManager wrapper
│   ├── RestaurantSearchService.swift — MKLocalSearch, 2km radius, 10 results
│   ├── RestaurantViewModel.swift — @Observable: loads restaurants, error/loading state
│   ├── RestaurantListView.swift  — container, triggers location + search
│   ├── RestaurantListContent.swift — list of rows
│   ├── RestaurantRowView.swift   — name, distance, opens in Maps on tap
│   ├── RestaurantEmptyView.swift — "no results" state
│   ├── RestaurantErrorView.swift — error + retry
│   └── RestaurantLoadingView.swift — skeleton/loading state
│
└── FeedMe/
    └── FeedMeView.swift          — "Coming Soon" stub, warm design, V2 architecture comments
```

---

## Screens completed (design system)

| Screen | Status |
|---|---|
| SpinnerView (main) | ✅ Done |
| WheelView | ✅ Done — animation fix, wedge colors, pointer overlay |
| DiceView | ✅ Done |
| ResultView sheet | ✅ Done |
| HistoryView sheet | ✅ Done |
| FilterView sheet | ✅ Done |
| FeedMeView sheet | ✅ Done |
| SettingsView sheet | ✅ Done |
| PaywallView | ✅ Built |

---

## Key technical decisions

**Wheel animation fix:**  
Canvas draw closure values don't animate via `withAnimation`. Fix: draw Canvas at fixed angles, apply `.rotationEffect(.degrees(rotationDegrees))` as a view modifier. SwiftUI interpolates the modifier, not the draw closure.

**Pointer position fix:**  
Removed ZStack+VStack pointer approach (drifts when parent frame is tall). Now uses `.overlay(alignment: .top)` directly on the Canvas with `.offset(y: 12)`. Math: 36pt top padding − 24pt icon height = 12pt so tip lands exactly at wheel rim.

**`Color.peBackground` (not `appBackground`):**  
iOS 26 added `Color.appBackground` as a system semantic color. Renamed our custom color to `peBackground` to avoid the redeclaration error.

**SettingsView keeps NavigationStack:**  
All other sheets drop NavigationStack; Settings keeps it for a consistent native nav bar treatment (hidden on root via `.toolbarVisibility(.hidden, for: .navigationBar)`).

**Premium gating uses `StoreKitManager.isPurchased` (device-only):**  
No accounts, no backend — premium does not follow the user across devices. This is the sole source of truth app-wide; there is no server-side premium record to spoof.

---

## Last git commit

`b31d69b` — "Apply warm design system across all app screens"  
Covers everything through FeedMeView + SettingsView redesign.

---

## What's left before shipping

See `TODO.md` for the full manual checklist.

**Code changes still needed before ship:**
1. `SettingsView.swift` — replace `https://example.com/privacy` with real privacy policy URL

---

## V2 (not started)

FeedMe AI feature — conversational UI, Claude API (haiku model), step-by-step: mood → dietary → budget → group size → structured JSON result. API key must go through a server-side proxy (e.g. Cloudflare Worker) — never embed client-side.
