import SwiftUI
import SwiftData

@main
struct pickyeaterApp: App {
    // App-wide services injected into the SwiftUI environment.
    // Any view can read them with @Environment(ServiceType.self).
    @State private var storeKit        = StoreKitManager()
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
                .environment(filterSettings)
                // ── App startup ───────────────────────────────────────────
                .task {
                    // Listens for purchases, restores, refunds, and family sharing.
                    // Started first so updates arriving during load aren't dropped.
                    storeKit.startTransactionListener()
                    await storeKit.loadProducts()
                    await storeKit.checkPurchaseStatus()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
