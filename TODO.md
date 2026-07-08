# Picky Eater — Manual To-Do Checklist

Things you need to do yourself before submitting to the App Store.
Check off as you go.

---

## 🔧 Xcode / Code (do these before re-enabling paywall)

- [ ] **Update Privacy Policy URL** — open `Settings/SettingsView.swift` and replace `https://example.com/privacy` with your real hosted URL
- [ ] **Enable In-App Purchase capability** — Xcode → your target → Signing & Capabilities → + Capability → In-App Purchase
- [ ] **Set deployment target to iOS 17.0** — Xcode → project settings → Deployment Info → iOS 17.0

---

## 🍎 Apple Developer Portal (developer.apple.com)

- [ ] **Create App ID** — Certificates, IDs & Profiles → Identifiers → + → App ID
  - Bundle ID: `com.bryanalmejo.pickyeater.pickyeater`
  - Enable: In-App Purchases
- [ ] **Create distribution certificate** — if you don't have one already
- [ ] **Create provisioning profile** — App Store distribution profile for the bundle ID above

---

## 🛒 App Store Connect (appstoreconnect.apple.com)

- [ ] **Create the app record** — My Apps → + → New App
  - Name: Picky Eater
  - Bundle ID: `com.bryanalmejo.pickyeater.pickyeater`
  - Primary language: English (U.S.)
- [ ] **Create the IAP product**
  - Your app → Monetization → In-App Purchases → +
  - Type: Non-Consumable
  - Reference Name: Picky Eater Premium
  - Product ID: `com.bryanalmejo.pickyeater.premium`
  - Price: $2.99
  - Add display name + description for App Review
- [ ] **Add app metadata**
  - Subtitle: `Spin for your next meal` (30 chars max)
  - Keywords: `restaurant, food, lunch, dinner, random, spin wheel, what to eat, picker, decision`
  - Description: write 3-line value prop for "above the fold" before the More button
- [ ] **Upload screenshots** (required minimum: iPhone 6.9")
  - [ ] Spin wheel in motion
  - [ ] Dice roll result card
  - [ ] Premium restaurant list with nearby results
  - [ ] Paywall screen
  - [ ] History view

---

## 🌐 Privacy Policy

- [ ] **Write and host a privacy policy** — covers: location data (used to find nearby restaurants, not stored); no accounts, no data leaves the device besides Apple's own StoreKit purchase records
  - Easiest option: GitHub Pages HTML page (free, takes 10 min)
  - Alternative: [privacypolicygenerator.info](https://privacypolicygenerator.info)
- [ ] **Paste the URL into `SettingsView.swift`** and App Store Connect app record

---

## 📱 Real Device Testing

- [ ] **Test full purchase flow** — use a Sandbox tester account in App Store Connect, run on real device (StoreKit doesn't work on simulator for real purchases)
- [ ] **Test restore purchase** — buy on one sandbox account, restore on same device
- [ ] **Test location on real device** — simulator GPS is fake; verify restaurant results load and the permission prompt appears at the right time (only when entering the premium result screen)
- [ ] **Test in airplane mode** — app should not crash; restaurant section should show an error state gracefully

---

## ✅ App Review Compliance Checklist

- [ ] Free tier (wheel + dice + categories) fully works without any purchase
- [ ] Paywall shows `product.displayPrice` (not hardcoded "$2.99") — already done in code
- [ ] Restore Purchase button is visible on the paywall — already done
- [ ] Location permission only requested when user enters the premium restaurant flow — already done
- [ ] No accounts — Guideline 5.1.1 account-deletion requirement does not apply

---

## 🚀 Submission

- [ ] Archive the app in Xcode (Product → Archive)
- [ ] Upload to App Store Connect via Xcode Organizer
- [ ] Fill in "What's New" text (first version: leave blank or write a launch note)
- [ ] Submit for Review
