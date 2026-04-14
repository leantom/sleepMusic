import SwiftUI
import UIKit

enum LuminousPalette {
    static let surface = Color(red: 14 / 255, green: 14 / 255, blue: 17 / 255)
    static let surfaceLow = Color(red: 19 / 255, green: 19 / 255, blue: 22 / 255)
    static let surfaceContainer = Color(red: 25 / 255, green: 25 / 255, blue: 29 / 255)
    static let surfaceHigh = Color(red: 37 / 255, green: 37 / 255, blue: 42 / 255)
    static let surfaceBright = Color(red: 48 / 255, green: 48 / 255, blue: 56 / 255)
    static let primary = Color(red: 198 / 255, green: 154 / 255, blue: 254 / 255)
    static let primaryDim = Color(red: 184 / 255, green: 140 / 255, blue: 240 / 255)
    static let secondary = Color(red: 80 / 255, green: 225 / 255, blue: 249 / 255)
    static let textPrimary = Color(red: 240 / 255, green: 237 / 255, blue: 241 / 255)
    static let textSecondary = Color(red: 172 / 255, green: 170 / 255, blue: 174 / 255)
    static let ghostBorder = Color(red: 72 / 255, green: 71 / 255, blue: 75 / 255).opacity(0.18)
    static let success = Color(red: 137 / 255, green: 225 / 255, blue: 180 / 255)

    static let primaryGradient = LinearGradient(
        colors: [primary, primaryDim],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [secondary.opacity(0.9), primary.opacity(0.85)],
        startPoint: .topTrailing,
        endPoint: .bottomLeading
    )
}

enum LuminousType {
    static func display(_ size: CGFloat, weight: UIFont.Weight = .bold) -> Font {
        font(
            preferredNames: ["PlusJakartaSans-Bold", "Plus Jakarta Sans Bold", "Plus Jakarta Sans"],
            size: size,
            fallback: .systemFont(ofSize: size, weight: weight)
        )
    }

    static func headline(_ size: CGFloat, weight: UIFont.Weight = .semibold) -> Font {
        font(
            preferredNames: ["PlusJakartaSans-SemiBold", "Plus Jakarta Sans SemiBold", "Plus Jakarta Sans"],
            size: size,
            fallback: .systemFont(ofSize: size, weight: weight)
        )
    }

    static func body(_ size: CGFloat, weight: UIFont.Weight = .medium) -> Font {
        font(
            preferredNames: ["Manrope-Medium", "Manrope-SemiBold", "Manrope"],
            size: size,
            fallback: .systemFont(ofSize: size, weight: weight)
        )
    }

    static func label(_ size: CGFloat, weight: UIFont.Weight = .semibold) -> Font {
        font(
            preferredNames: ["Manrope-SemiBold", "Manrope-Bold", "Manrope-Regular"],
            size: size,
            fallback: .systemFont(ofSize: size, weight: weight)
        )
    }

    private static func font(preferredNames: [String], size: CGFloat, fallback: UIFont) -> Font {
        if let match = preferredNames.compactMap({ UIFont(name: $0, size: size) }).first {
            return Font(match)
        }

        return Font(fallback)
    }
}

struct LuminousBackground: View {
    var body: some View {
        ZStack {
            LuminousPalette.surface
            LinearGradient(
                colors: [LuminousPalette.surface, LuminousPalette.surfaceLow, Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [LuminousPalette.primary.opacity(0.24), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 320
            )
            .offset(x: 40, y: -40)

            RadialGradient(
                colors: [LuminousPalette.secondary.opacity(0.16), .clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 260
            )
            .offset(x: -60, y: -90)

            RadialGradient(
                colors: [Color.white.opacity(0.05), .clear],
                center: .center,
                startRadius: 40,
                endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

struct LuminousGlassCardBackground: View {
    var cornerRadius: CGFloat = 28
    var fillColor: Color = LuminousPalette.surfaceContainer
    var glowColor: Color? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(fillColor.opacity(0.92))
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(LuminousPalette.ghostBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 30, x: 0, y: 18)
            .shadow(color: (glowColor ?? .clear).opacity(0.25), radius: 24, x: 0, y: 0)
    }
}

struct LuminousPrimaryButton: View {
    let title: String
    var icon: String? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(LuminousType.body(16, weight: .semibold))
            }
            .foregroundStyle(Color(red: 64 / 255, green: 18 / 255, blue: 116 / 255))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                Capsule(style: .continuous)
                    .fill(LuminousPalette.primaryGradient)
                    .shadow(color: LuminousPalette.primary.opacity(0.3), radius: 24, x: 0, y: 10)
            )
        }
        .buttonStyle(.plain)
    }
}

struct LuminousChip: View {
    let title: String
    var isSelected: Bool

    var body: some View {
        Text(title)
            .font(LuminousType.label(12, weight: .semibold))
            .textCase(.uppercase)
            .foregroundStyle(isSelected ? Color(red: 53 / 255, green: 20 / 255, blue: 79 / 255) : LuminousPalette.textSecondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(LuminousPalette.primaryGradient) : AnyShapeStyle(LuminousPalette.surfaceHigh))
            )
            .shadow(color: isSelected ? LuminousPalette.primary.opacity(0.28) : .clear, radius: 18, x: 0, y: 8)
    }
}

struct LuminousIconButton: View {
    let icon: String
    var isAccent: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isAccent ? LuminousPalette.primary : LuminousPalette.textPrimary)
                .frame(width: 42, height: 42)
                .background(
                    Circle()
                        .fill(LuminousPalette.surfaceContainer.opacity(0.92))
                        .overlay(Circle().stroke(LuminousPalette.ghostBorder, lineWidth: 1))
                        .shadow(color: isAccent ? LuminousPalette.primary.opacity(0.22) : .clear, radius: 18, x: 0, y: 0)
                )
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func luminousGlassCard(
        cornerRadius: CGFloat = 28,
        fillColor: Color = LuminousPalette.surfaceContainer,
        glowColor: Color? = nil
    ) -> some View {
        background(
            LuminousGlassCardBackground(
                cornerRadius: cornerRadius,
                fillColor: fillColor,
                glowColor: glowColor
            )
        )
    }
}
