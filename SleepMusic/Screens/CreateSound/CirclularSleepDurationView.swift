import SwiftUI

struct CircularSleepDurationView: View {
    @Binding var bedtime: Date
    @Binding var wakeupTime: Date

    private let calendar = Calendar.current

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let lineWidth = size * 0.1

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                LuminousPalette.surfaceContainer.opacity(0.98),
                                LuminousPalette.surfaceLow.opacity(0.96),
                                Color.black.opacity(0.92)
                            ],
                            center: .center,
                            startRadius: 12,
                            endRadius: size * 0.55
                        )
                    )

                Circle()
                    .stroke(LuminousPalette.surfaceHigh.opacity(0.65), lineWidth: lineWidth)

                SleepDurationArc(
                    startFraction: bedtimeFraction,
                    endFraction: wakeupFraction
                )
                .stroke(
                    AngularGradient(
                        colors: [LuminousPalette.primary, LuminousPalette.secondary],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .shadow(color: LuminousPalette.primary.opacity(0.26), radius: 24, x: 0, y: 0)

                handle(for: bedtimeFraction, size: size, glow: LuminousPalette.primary)
                    .gesture(handleDrag(isBedtime: true, size: size))

                handle(for: wakeupFraction, size: size, glow: LuminousPalette.secondary)
                    .gesture(handleDrag(isBedtime: false, size: size))

                VStack(spacing: 10) {
                    Text(durationString)
                        .font(LuminousType.display(size * 0.19, weight: .bold))
                        .foregroundStyle(LuminousPalette.textPrimary)

                    Text("HOURS SLEEP")
                        .font(LuminousType.label(size * 0.04, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(LuminousPalette.textSecondary)

                    Text("\(formattedTime(bedtime)) - \(formattedTime(wakeupTime))")
                        .font(LuminousType.body(size * 0.05))
                        .foregroundStyle(LuminousPalette.textSecondary)
                }
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var bedtimeFraction: Double {
        dateToFraction(bedtime)
    }

    private var wakeupFraction: Double {
        dateToFraction(wakeupTime)
    }

    private var sleepDuration: TimeInterval {
        let start = bedtime
        let end = wakeupTime >= bedtime ? wakeupTime : wakeupTime.addingTimeInterval(24 * 60 * 60)
        return end.timeIntervalSince(start)
    }

    private var durationString: String {
        let totalMinutes = Int(round(sleepDuration / 60))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return String(format: "%02d:%02d", hours, minutes)
    }

    private func handle(for fraction: Double, size: CGFloat, glow: Color) -> some View {
        let point = point(for: fraction, size: size)

        return Circle()
            .fill(Color.white)
            .frame(width: size * 0.09, height: size * 0.09)
            .shadow(color: glow.opacity(0.34), radius: 24, x: 0, y: 0)
            .position(point)
    }

    private func handleDrag(isBedtime: Bool, size: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let fraction = angleFraction(for: value.location, size: size)
                let updatedDate = fractionToDate(fraction, reference: isBedtime ? bedtime : wakeupTime)

                if isBedtime {
                    bedtime = updatedDate
                } else {
                    wakeupTime = updatedDate
                }
            }
    }

    private func point(for fraction: Double, size: CGFloat) -> CGPoint {
        let angle = (fraction * 360 - 90) * .pi / 180
        let radius = size / 2 - size * 0.05
        let center = CGPoint(x: size / 2, y: size / 2)
        return CGPoint(
            x: center.x + radius * cos(angle),
            y: center.y + radius * sin(angle)
        )
    }

    private func angleFraction(for point: CGPoint, size: CGFloat) -> Double {
        let center = CGPoint(x: size / 2, y: size / 2)
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle += 90

        if angle < 0 {
            angle += 360
        }

        return angle / 360
    }

    private func dateToFraction(_ date: Date) -> Double {
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = Double(components.hour ?? 0)
        let minute = Double(components.minute ?? 0) / 60
        return (hour + minute) / 24
    }

    private func fractionToDate(_ fraction: Double, reference: Date) -> Date {
        let totalMinutes = Int(round(fraction * 24 * 60)) % (24 * 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return calendar.date(
            bySettingHour: hours,
            minute: minutes,
            second: 0,
            of: reference
        ) ?? reference
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

private struct SleepDurationArc: Shape {
    var startFraction: Double
    var endFraction: Double

    func path(in rect: CGRect) -> Path {
        let startDegrees = startFraction * 360 - 90
        var endDegrees = endFraction * 360 - 90

        if endDegrees <= startDegrees {
            endDegrees += 360
        }

        let radius = min(rect.width, rect.height) / 2 - min(rect.width, rect.height) * 0.05
        let center = CGPoint(x: rect.midX, y: rect.midY)

        var path = Path()
        path.addArc(
            center: center,
            radius: radius,
            startAngle: .degrees(startDegrees),
            endAngle: .degrees(endDegrees),
            clockwise: false
        )
        return path
    }
}

struct WrapperCircularSleepDurationView: View {
    @State var bedtime = Calendar.current.date(bySettingHour: 23, minute: 0, second: 0, of: Date()) ?? Date()
    @State var wakeupTime = Calendar.current.date(bySettingHour: 7, minute: 45, second: 0, of: Date()) ?? Date()

    var body: some View {
        CircularSleepDurationView(bedtime: $bedtime, wakeupTime: $wakeupTime)
            .padding()
            .background(LuminousBackground())
    }
}

#Preview {
    WrapperCircularSleepDurationView()
}
