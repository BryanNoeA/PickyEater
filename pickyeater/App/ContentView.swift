import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigationPath = NavigationPath()
    @Environment(StoreKitManager.self) private var storeKit

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SpinnerView()
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreKitManager())
        .modelContainer(for: SpinResult.self, inMemory: true)
}
