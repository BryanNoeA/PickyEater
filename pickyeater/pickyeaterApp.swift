import SwiftUI
import SwiftData

@main
struct pickyeaterApp: App {
    @State private var appState = AppState()
    @State private var storeKitManager = StoreKitManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SpinResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Fallback to in-memory if persistent store can't be created
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return (try? ModelContainer(for: schema, configurations: [fallback]))
                ?? { fatalError("Could not create ModelContainer: \(error)") }()
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
                .environment(storeKitManager)
                .task {
                    await storeKitManager.loadProducts()
                    await storeKitManager.checkPurchaseStatus()
                    storeKitManager.startTransactionListener(appState: appState)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
