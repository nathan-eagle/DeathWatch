#if DEBUG
import SwiftUI

private struct ComplicationSnapshot {
    let unit: TimeUnit
    let countdownText: String
    let compactCountdownText: String
    let percentLived: Double
    let currentAge: Int
    let totalYears: Int
    let yearsLived: Int
    let daysLeft: Int
    let accent: Accent

    static func capture(asOf date: Date = .now) -> ComplicationSnapshot {
        let unit = LifeEngine.selectedUnit
        return ComplicationSnapshot(
            unit: unit,
            countdownText: LifeEngine.formattedCountdown(for: unit, asOf: date),
            compactCountdownText: LifeEngine.compactCountdown(for: unit, asOf: date),
            percentLived: LifeEngine.percentLived(asOf: date),
            currentAge: LifeEngine.currentAgeYears(asOf: date),
            totalYears: LifeEngine.totalYears,
            yearsLived: LifeEngine.currentAgeYears(asOf: date),
            daysLeft: LifeEngine.daysLeft(asOf: date),
            accent: Accent.preset(id: LifeEngine.accentID)
        )
    }

    var percentValueText: String {
        "\(Int((percentLived * 100).rounded()))"
    }

    var percentText: String {
        "\(percentValueText)%"
    }

    var ageSpanText: String {
        "\(currentAge)·\(totalYears)"
    }

    var compactDaysText: String {
        guard daysLeft >= 10_000 else { return LifeEngine.formatted(daysLeft) }
        let thousands = Double(daysLeft) / 1_000
        let text = thousands >= 100
            ? String(format: "%.0fk", thousands)
            : String(format: "%.1fk", thousands)
        return text.replacingOccurrences(of: ".0k", with: "k")
    }
}

struct ComplicationGallery: View {
    private let snapshot = ComplicationSnapshot.capture()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                section("Grid · rectangular") {
                    VStack(spacing: 8) {
                        rectangularTile(tinted: false) { gridContent }
                        rectangularTile(tinted: true) { gridContent }
                    }
                }
                section("Bar · rectangular") {
                    VStack(spacing: 8) {
                        rectangularTile(tinted: false) { barContent }
                        rectangularTile(tinted: true) { barContent }
                    }
                }
                section("Ring · circular") {
                    HStack(spacing: 14) {
                        emulateTint(false) { circularContent(tinted: false) }
                        emulateTint(true) { circularContent(tinted: true) }
                    }
                }
                section("Ring · corner") {
                    HStack(spacing: 14) {
                        emulateTint(false) { cornerContent(tinted: false) }
                        emulateTint(true) { cornerContent(tinted: true) }
                    }
                }
                section("Inline · text") {
                    VStack(alignment: .leading, spacing: 8) {
                        emulateTint(false) { inlineContent }
                        emulateTint(true) { inlineContent }
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 8)
        }
        .background(Color.black.ignoresSafeArea())
    }

    // MARK: - Lookalike contents (mirroring LifeCountdownWidget views)

    private var gridContent: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text("My Life")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .layoutPriority(1)
                Spacer(minLength: 6)
                Text(snapshot.compactCountdownText)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            LifeDotGrid(
                total: snapshot.totalYears,
                filledCount: snapshot.yearsLived,
                currentIndex: snapshot.yearsLived,
                rows: 4,
                accent: snapshot.accent,
                style: .gradient
            )
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 4)
    }

    private var barContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("☠︎")
                    .font(.system(size: 11, weight: .semibold))
                Text(snapshot.unit.morbidName)
                    .font(DW.unitLabelFont)
                    .tracking(DW.unitLabelTracking)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(.secondary)
            .lineLimit(1)

            Spacer(minLength: 1)

            Text(snapshot.countdownText)
                .font(DW.numberFont(36))
                .monospacedDigit()
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.55)

            Spacer(minLength: 4)

            HStack(spacing: 6) {
                LifeBar(progress: snapshot.percentLived, accent: snapshot.accent, height: 4.5)
                Text(snapshot.percentText)
                    .font(DW.percentFont(11))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }

    private func circularContent(tinted: Bool) -> some View {
        ZStack {
            // AccessoryWidgetBackground stand-in
            Circle()
                .fill(.white.opacity(0.12))
            LifeRing(
                progress: snapshot.percentLived,
                accent: snapshot.accent,
                gradient: !tinted
            ) {
                VStack(spacing: -1) {
                    Text(snapshot.percentValueText)
                        .font(DW.numberFont(19))
                        .monospacedDigit()
                        .minimumScaleFactor(0.8)
                    Text(snapshot.ageSpanText)
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .lineLimit(1)
            }
        }
        .frame(width: 76, height: 76)
    }

    private func cornerContent(tinted: Bool) -> some View {
        ZStack {
            Group {
                Circle()
                    .trim(from: 0.25, to: 0.5)
                    .stroke(snapshot.accent.track, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                Circle()
                    .trim(from: 0.25, to: 0.25 + 0.25 * snapshot.percentLived)
                    .stroke(cornerFill(tinted: tinted), style: StrokeStyle(lineWidth: 5, lineCap: .round))
            }
            .padding(2.5)
            Text(snapshot.compactDaysText)
                .font(DW.numberFont(15))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .padding(.horizontal, 8)
        }
        .frame(width: 60, height: 60)
    }

    private var inlineContent: some View {
        Text("☠︎ \(snapshot.compactCountdownText)")
            .font(.system(size: 13, weight: .medium))
            .monospacedDigit()
            .lineLimit(1)
    }

    private func cornerFill(tinted: Bool) -> AnyShapeStyle {
        tinted
            ? AnyShapeStyle(snapshot.accent.solid)
            : AnyShapeStyle(
                AngularGradient(
                    gradient: Gradient(colors: [snapshot.accent.gradientStart, snapshot.accent.gradientEnd]),
                    center: .center,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180)
                )
            )
    }

    // MARK: - Scaffolding

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
            content()
        }
    }

    private func rectangularTile<Content: View>(tinted: Bool, @ViewBuilder content: () -> Content) -> some View {
        emulateTint(tinted) {
            content()
                .frame(maxWidth: 191)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.black)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 1)
                )
        }
    }

    private func emulateTint<Content: View>(_ on: Bool, @ViewBuilder content: () -> Content) -> some View {
        content()
            .compositingGroup()
            .grayscale(on ? 1 : 0)
            .tint(on ? Color.white : nil)
    }
}

#Preview {
    ComplicationGallery()
}
#endif
