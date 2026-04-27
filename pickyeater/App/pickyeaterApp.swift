import SwiftUI
import SwiftData
import GoogleSignIn

@main
struct pickyeaterApp: App {
    // Three app-wide services injected into the SwiftUI environment.
    // Any view can read them with @Environment(ServiceType.self).
    @State private var storeKit        = StoreKitManager()
    @State private var authManager     = AuthManager()
    @State private var profileManager  = ProfileManager()
    @State private var filterSettings  = FilterSettings()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SpinResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fall back to in-memory storage so the app still launches
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return (try? ModelContainer(for: schema, configurations: [fallback]))
                ?? { fatalError("Could not create ModelContainer: \(error)") }()
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storeKit)
                .environment(authManager)
                .environment(profileManager)
                .environment(filterSettings)
                // ── App startup ───────────────────────────────────────────
                .task {
                    // Configure Google Sign-In with the full client ID.
                    // Must happen before any GIDSignIn call — doing it here
                    // in .task guarantees it runs before the user can tap anything.
                    GIDSignIn.sharedInstance.configuration = GIDConfiguration(
                        clientID: SupabaseConfig.googleClientID
                    )

                    await storeKit.loadProducts()
                    await storeKit.checkPurchaseStatus()
                    // Listens for purchases, restores, refunds, and family sharing
                    storeKit.startTransactionListener()
                }
                // ── Google Sign-In: handle the OAuth redirect URL ──────────
                // After the user completes Google sign-in in Safari, iOS opens
                // the app via the reversed-client-ID URL scheme. GIDSignIn
                // needs to intercept that URL to finish the auth flow.
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
