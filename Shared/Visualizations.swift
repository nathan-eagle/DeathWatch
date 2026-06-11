import SwiftUI
import WidgetKit

// MARK: - Dot grid

struct LifeDotGrid: View {
    enum Style {
        case solid
        case gradient
    }

    let total: Int
    let filledCount: Int
    let currentIndex: Int?
    let rows: Int
    let accent: Accent
    let style: Style
    let animateIn: Bool

    @State private var revealed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(
        total: Int,
        filledCount: Int,
        currentIndex: Int? = nil,
        rows: Int,
        accent: Accent,
        style: Style = .solid,
        animateIn: Bool = false
    ) {
        let clampedTotal = max(0, total)
        self.total = clampedTotal
        self.filledCount = min(max(0, filledCount), clampedTotal)
        if let currentIndex, (0..<clampedTotal).contains(currentIndex) {
            self.currentIndex = currentIndex
        } else {
            self.currentIndex = nil
        }
        self.rows = max(1, rows)
        self.accent = accent
        self.style = style
        self.animateIn = animateIn
        _revealed = State(initialValue: !animateIn)
    }

    private static let markerDotThreshold: CGFloat = 8

    var body: some View {
        GeometryReader { proxy in
            let layout = GridLayout(total: total, rows: rows, size: proxy.size)
            ZStack(alignment: .topLeading) {
                emptyLayer(layout)
                filledLayer(layout)
                currentMarkerLayer(layout)
            }
        }
        .onAppear {
            guard animateIn, !revealed else { return }
            revealed = true
        }
    }

    @ViewBuilder
    private func currentMarkerLayer(_ layout: GridLayout) -> some View {
        if let currentIndex, layout.dot < Self.markerDotThreshold {
            Circle()
                .fill(.white)
                .frame(width: layout.dot, height: layout.dot)
                .scaleEffect(revealed || reduceMotion ? 1 : 0.6)
                .opacity(revealed ? 1 : 0)
                .animation(revealAnimation(for: currentIndex), value: revealed)
                .position(layout.center(of: currentIndex))
        }
    }

    private func emptyLayer(_ layout: GridLayout) -> some View {
        ForEach(0..<total, id: \.self) { index in
            if index >= filledCount, index != currentIndex {
                Circle()
                    .strokeBorder(accent.solid.opacity(DW.emptyDotOpacity), lineWidth: layout.stroke)
                    .frame(width: layout.dot, height: layout.dot)
                    .position(layout.center(of: index))
            }
        }
    }

    @ViewBuilder
    private func filledLayer(_ layout: GridLayout) -> some View {
        Group {
            if style == .gradient {
                Rectangle()
                    .fill(accent.linearGradient)
                    .mask { filledDots(layout) }
            } else {
                filledDots(layout)
                    .foregroundStyle(accent.solid)
            }
        }
        .widgetAccentable()
    }

    private func filledDots(_ layout: GridLayout) -> some View {
        let bullseyeCurrent = layout.dot >= Self.markerDotThreshold
        return ZStack(alignment: .topLeading) {
            ForEach(0..<total, id: \.self) { index in
                if index < filledCount || (index == currentIndex && bullseyeCurrent) {
                    dot(at: index, layout: layout)
                }
            }
        }
    }

    private func dot(at index: Int, layout: GridLayout) -> some View {
        Group {
            if index == currentIndex {
                ZStack {
                    Circle()
                        .strokeBorder(lineWidth: layout.stroke)
                    Circle()
                        .frame(
                            width: layout.dot * DW.currentDotCoreScale,
                            height: layout.dot * DW.currentDotCoreScale
                        )
                }
            } else {
                Circle()
            }
        }
        .frame(width: layout.dot, height: layout.dot)
        .scaleEffect(revealed || reduceMotion ? 1 : 0.6)
        .opacity(revealed ? 1 : 0)
        .animation(revealAnimation(for: index), value: revealed)
        .position(layout.center(of: index))
    }

    private func revealAnimation(for index: Int) -> Animation? {
        guard animateIn else { return nil }
        if reduceMotion { return .easeOut(duration: 0.2) }
        let perCell = min(0.008, 0.6 / Double(max(total, 1)))
        return .spring(response: 0.7, dampingFraction: 0.85).delay(Double(index) * perCell)
    }
}

private struct GridLayout {
    let columns: Int
    let dot: CGFloat
    let gap: CGFloat
    let origin: CGPoint

    init(total: Int, rows: Int, size: CGSize) {
        let rowCount = max(1, rows)
        let columnCount = max(1, Int((Double(max(total, 1)) / Double(rowCount)).rounded(.up)))
        columns = columnCount

        let ratio = DW.dotGapRatio
        let fitWidth = size.width / (CGFloat(columnCount) + ratio * CGFloat(columnCount - 1))
        let fitHeight = size.height / (CGFloat(rowCount) + ratio * CGFloat(rowCount - 1))
        dot = max(1, min(fitWidth, fitHeight))
        gap = dot * ratio

        let gridWidth = CGFloat(columnCount) * dot + CGFloat(columnCount - 1) * gap
        let gridHeight = CGFloat(rowCount) * dot + CGFloat(rowCount - 1) * gap
        origin = CGPoint(
            x: (size.width - gridWidth) / 2 + dot / 2,
            y: (size.height - gridHeight) / 2 + dot / 2
        )
    }

    var stroke: CGFloat {
        min(max(0.9, dot * 0.18), 2.0)
    }

    func center(of index: Int) -> CGPoint {
        let row = index / columns
        let column = index % columns
        return CGPoint(
            x: origin.x + CGFloat(column) * (dot + gap),
            y: origin.y + CGFloat(row) * (dot + gap)
        )
    }
}

// MARK: - Ring

struct LifeRing<Content: View>: View {
    let progress: Double
    let accent: Accent
    let lineWidthRatio: CGFloat
    let gradient: Bool
    private let content: Content

    init(
        progress: Double,
        accent: Accent,
        lineWidthRatio: CGFloat = DW.ringLineWidthRatio,
        gradient: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.progress = min(1, max(0, progress))
        self.accent = accent
        self.lineWidthRatio = lineWidthRatio
        self.gradient = gradient
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let side = min(proxy.size.width, proxy.size.height)
            let lineWidth = max(1.5, side * lineWidthRatio)
            ZStack {
                Circle()
                    .stroke(accent.track, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(fillStyle, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .widgetAccentable()
                content
            }
            .padding(lineWidth / 2)
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var fillStyle: AnyShapeStyle {
        gradient ? AnyShapeStyle(accent.angularGradient) : AnyShapeStyle(accent.solid)
    }
}

extension LifeRing where Content == EmptyView {
    init(
        progress: Double,
        accent: Accent,
        lineWidthRatio: CGFloat = DW.ringLineWidthRatio,
        gradient: Bool = false
    ) {
        self.init(
            progress: progress,
            accent: accent,
            lineWidthRatio: lineWidthRatio,
            gradient: gradient
        ) {
            EmptyView()
        }
    }
}

// MARK: - Bar

struct LifeBar: View {
    let progress: Double
    let accent: Accent
    let height: CGFloat

    init(progress: Double, accent: Accent, height: CGFloat = 6) {
        self.progress = min(1, max(0, progress))
        self.accent = accent
        self.height = height
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(accent.track)
                Capsule()
                    .fill(accent.barGradient)
                    .frame(width: max(height, proxy.size.width * progress))
                    .widgetAccentable()
            }
        }
        .frame(height: height)
    }
}
