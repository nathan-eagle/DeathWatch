import SwiftUI

struct ContentView: View {
    @StateObject private var accentStore = AccentStore()
    @State private var selection = 0

    #if DEBUG
    init() {
        if let page = Self.launchPageOverride {
            _selection = State(initialValue: page)
        }
    }

    private static var launchPageOverride: Int? {
        let arguments = CommandLine.arguments
        guard let flagIndex = arguments.firstIndex(of: "--page"),
              arguments.indices.contains(flagIndex + 1) else { return nil }
        return Int(arguments[flagIndex + 1])
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
