import SwiftUI
import SwiftData

@main
struct pickyeaterApp: App {
    @State private var storeKit = StoreKitManager()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([SpinResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            return (try? ModelContainer(for: schema, configurations: [fallback]))
                ?? { fatalError("Could not create ModelContainer: \(error)") }()
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(storeKit)
                .task {
                    await storeKit.loadProducts()
                    await storeKit.checkPurchaseStatus()
                    storeKit.startTransactionListener()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
