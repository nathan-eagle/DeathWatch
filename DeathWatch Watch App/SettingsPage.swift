import SwiftUI
import WatchKit

struct SettingsPage: View {
    @EnvironmentObject private var accentStore: AccentStore
    @State private var birthDate = LifeEngine.birthDate
    @State private var deathDate = LifeEngine.deathDate

    var body: some View {
        List {
            Section {
                NavigationLink {
                    CrownDatePickerScreen(kind: .birth) { birthDate = $0 }
                } label: {
                    dateRow(title: "Birth Date", date: birthDate)
                }

                NavigationLink {
                    CrownDatePickerScreen(kind: .death) { deathDate = $0 }
                } label: {
                    dateRow(title: "Death Date", date: deathDate)
                }

                NavigationLink {
                    AccentPickerScreen()
                } label: {
                    accentRow
                }
            } footer: {
                footer
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            birthDate = LifeEngine.birthDate
            deathDate = LifeEngine.deathDate
        }
    }

    private func dateRow(title: String, date: Date) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 15))
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(.system(size: 13, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }

    private var accentRow: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Accent")
                .font(.system(size: 15))
            HStack(spacing: 6) {
                Circle()
                    .fill(accentStore.accent.linearGradient)
                    .frame(width: 12, height: 12)
                Text(accentStore.accent.name)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var footer: some View {
        VStack(spacing: 3) {
            Text("memento mori")
                .font(.system(size: 12, design: .serif).italic())
                .foregroundStyle(.secondary)
            Text("Version \(appVersion)")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(.top, 10)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

struct AccentPickerScreen: View {
    @EnvironmentObject private var accentStore: AccentStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                LazyVGrid(columns: Self.columns, spacing: 10) {
                    ForEach(Accent.presets) { accent in
                        swatch(accent)
                    }
                }
                .padding(.top, 2)

                Text(accentStore.accent.name)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.top, 10)
                    .padding(.bottom, 4)
            }
        }
        .navigationTitle("Accent")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func swatch(_ accent: Accent) -> some View {
        let isSelected = accentStore.accent.id == accent.id
        return Button {
            select(accent)
        } label: {
            ZStack {
                Circle()
                    .stroke(accent.solid, lineWidth: 3)
                    .frame(width: 37, height: 37)
                    .opacity(isSelected ? 1 : 0)
                    .scaleEffect(isSelected || reduceMotion ? 1 : 0.5)
                Circle()
                    .fill(accent.linearGradient)
                    .frame(width: 28, height: 28)
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accent.name)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func select(_ accent: Accent) {
        guard accent.id != accentStore.accent.id else { return }
        WKInterfaceDevice.current().play(.click)
        withAnimation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.3, dampingFraction: 0.6)) {
            accentStore.select(accent)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsPage()
    }
    .environmentObject(AccentStore())
}

#Preview("Accent Picker") {
    NavigationStack {
        AccentPickerScreen()
    }
    .environmentObject(AccentStore())
}
