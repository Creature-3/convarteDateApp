//
//  HomeView.swift
//  DateAPP
//
//  Created by Rahaf Alhammadi on 06/04/1447 AH.
//


import SwiftUI
//import UIKit

struct HomeView: View {
    // Slots
    @State private var day   = ""
    @State private var month = ""
    @State private var year  = ""

    // UI
    @State private var result = ""
    @State private var useHijri = false   // false = AD (Gregorian), true = Hijri (Umm Al-Qura)

    // Focus for auto-advance
    @FocusState private var focus: Field?
    enum Field { case day, month, year }

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let radius: CGFloat = max(size.width, size.height) * 0.45
            let circleCenter = CGPoint(
                x: size.width - radius * 1.2,
                y: size.height - radius * 0.0
            )

            ZStack {
                // Background
                Color(hex: "#FAF8F4").ignoresSafeArea()

                // Big navy circle
                Circle()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(circleCenter)
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 7)

                // Result inside circle
                if !result.isEmpty {
                    Text(result.uppercased())
                        .font(.system(size: 52, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(hex: "#FAF8F4"))
                        .position(x: size.width * 0.32, y: size.height * 0.82)
                        .minimumScaleFactor(0.5)
                        .transition(.opacity)
                }

                VStack(spacing: 12) {
                    // Hijri / AD toggle
                    Picker("", selection: $useHijri) {
                        Text("Hijri").tag(true)
                        Text("AD").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: size.width * 0.35)
                    // 🔁 When switching calendars, reset the slots & result
                    .onChange(of: useHijri) { _ in
                        day = ""; month = ""; year = ""
                        result = ""
                        focus = .day
                        Haptics.success()
                    }

                    // Slots: DD / MM / YYYY
                    HStack(spacing: 10) {
                        SlotField(text: $day,
                                  placeholder: "DD",
                                  maxLength: 2,
                                  width: 56,
                                  focus: $focus,
                                  me: .day,
                                  next: .month)

                        Text("/").font(.system(size: 22, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: "#0B2D4E"))

                        SlotField(text: $month,
                                  placeholder: "MM",
                                  maxLength: 2,
                                  width: 56,
                                  focus: $focus,
                                  me: .month,
                                  next: .year)

                        Text("/").font(.system(size: 22, weight: .medium, design: .monospaced))
                            .foregroundStyle(Color(hex: "#0B2D4E"))

                        SlotField(text: $year,
                                  placeholder: "YYYY",
                                  maxLength: 4,
                                  width: 90,
                                  focus: $focus,
                                  me: .year,
                                  next: nil)
                    }
                    .padding(.vertical, 24)

                    // Search
                    Button("Search") {
                        if let weekday = computeWeekday(day: day, month: month, year: year, hijri: useHijri) {
                            result = weekday
                        } else {
                            result = ""
                        }
                        Haptics.success()
                        focus = nil
                    }
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .frame(width: size.width * 0.30, height: 48)
                    .background(Color(hex: "#0B2D4E"))
                    .foregroundStyle(Color(hex: "#FAF8F4"))
                    .clipShape(RoundedRectangle(cornerRadius: 19, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 5)
                    .disabled(!(day.count == 2 && month.count == 2 && year.count == 4))
                    .opacity((day.count == 2 && month.count == 2 && year.count == 4) ? 1 : 0.6)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, size.height - radius * 1.75)
                .onAppear { focus = .day }
            }
        }
    }

    // MARK: - Weekday (supports Hijri or Gregorian input)
    private func computeWeekday(day: String, month: String, year: String, hijri: Bool) -> String? {
        guard let d = Int(day), let m = Int(month), let y = Int(year),
              (1...31).contains(d), (1...12).contains(m), (1...9999).contains(y) else { return nil }

        // Calendar for the INPUT (what user typed)
        var inputCal = hijri
            ? Calendar(identifier: .islamicUmmAlQura)
            : Calendar(identifier: .gregorian)
        inputCal.timeZone = TimeZone(secondsFromGMT: 0)!

        var comps = DateComponents()
        comps.calendar = inputCal
        comps.day = d
        comps.month = m
        comps.year = y

        // Absolute date from those components in chosen calendar
        guard let absoluteDate = inputCal.date(from: comps) else { return nil }

        // Get weekday name (English)
        var gCal = Calendar(identifier: .gregorian)
        gCal.timeZone = TimeZone(secondsFromGMT: 0)!
        let idx = gCal.component(.weekday, from: absoluteDate) // 1..7

        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        let names = df.weekdaySymbols ?? ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
        return names[(idx - 1) % names.count]
    }
}

// MARK: - Editable underline slot with auto-advance
private struct SlotField: View {
    @Binding var text: String
    let placeholder: String
    let maxLength: Int
    let width: CGFloat

    @FocusState.Binding var focus: HomeView.Field?
    let me: HomeView.Field
    let next: HomeView.Field?

    var body: some View {
        ZStack {
            // underline
            VStack(spacing: 0) {
                Spacer()
                Rectangle()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(height: 2)
                    .opacity(0.85)
            }

            TextField(placeholder, text: $text)
#if os(iOS)
                .keyboardType(UIKeyboardType.numberPad)
#endif
                .focused($focus, equals: me)
                .multilineTextAlignment(.center)
                .font(.system(size: 28,
                              weight: Font.Weight.medium,
                              design: Font.Design.monospaced))
                .foregroundStyle(Color(hex: "#0B2D4E"))
                .onChange(of: text) { newValue in
                    let digits = newValue.filter { $0.isNumber }
                    let clipped = String(digits.prefix(maxLength))
                    if clipped != text { text = clipped }
                    if clipped.count == maxLength {
                        if let next { focus = next } else { focus = nil }
                    }
                }
                .onTapGesture { focus = me }
        }
        .frame(width: width, height: 40)
        .contentShape(Rectangle())
    }
}

// MARK: - Haptics
enum Haptics {
    static func success() {
#if os(iOS)
        let gen = UINotificationFeedbackGenerator()
        gen.notificationOccurred(.success)
#endif
    }
}

// MARK: - Hex helper
private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0; Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self = Color(.sRGB,
                     red: Double(r)/255,
                     green: Double(g)/255,
                     blue: Double(b)/255,
                     opacity: Double(a)/255)
    }
}

#Preview("Home iPhone 16") {
    HomeView()
        .frame(width: 390, height: 844)
}
