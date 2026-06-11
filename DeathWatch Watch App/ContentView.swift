import SwiftUI

struct ContentView: View {
    @StateObject private var accentStore = AccentStore()
    @State private var selection = 0

    #if DEBUG
    init() {
        if let accentID = Self.launchArgumentValue(for: "--accent") {
            LifeEngine.accentID = accentID
        }
        if let unit = Self.launchArgumentValue(for: "--unit").flatMap(TimeUnit.init) {
            LifeEngine.selectedUnit = unit
        }
        if let page = Self.launchArgumentValue(for: "--page").flatMap(Int.init) {
            _selection = State(initialValue: page)
        }
    }

    private static func launchArgumentValue(for flag: String) -> String? {
        let arguments = CommandLine.arguments
        guard let flagIndex = arguments.firstIndex(of: flag),
              arguments.indices.contains(flagIndex + 1) else { return nil }
        return arguments[flagIndex + 1]
    }
    #endif

    var body: some View {
        NavigationStack {
            TabView(selection: $selection) {
                GridHeroPage()
                    .tag(0)
                RingPage()
                    .tag(1)
                SettingsPage()
                    .tag(2)
                #if DEBUG
                ComplicationGallery()
                    .tag(3)
                #endif
            }
            .tabViewStyle(.verticalPage)
        }
        .environmentObject(accentStore)
    }
}

#Preview {
    ContentView()
}
