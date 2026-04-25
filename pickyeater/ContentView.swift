import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(StoreKitManager.self) private var storeKit

    var body: some View {
        MainView()
            .sheet(isPresented: Bindable(appState).showPaywall) {
                PaywallView()
                    .environment(appState)
                    .environment(storeKit)
            }
    }
}
