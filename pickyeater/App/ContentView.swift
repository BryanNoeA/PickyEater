import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SpinnerView()
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreKitManager())
        .environment(FilterSettings())
        .modelContainer(for: SpinResult.self, inMemory: true)
}
