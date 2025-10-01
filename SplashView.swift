//
//  ContentView.swift
//  DateAPP
//
//  Created by Rahaf Alhammadi on 06/04/1447 AH.
//

import SwiftUI

struct SplashView: View {
    // Animation tuning
    private let animDuration: Double = 1.8
    private let stagger: Double = 0.12

    @State private var emerge = false
    @State private var showDay = false

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let radius: CGFloat = max(size.width, size.height) * 0.45
            let circleCenter = CGPoint(
                x: size.width - radius * 1.2,
                y: size.height - radius * 0.0
            )

            // Final positions (your layout)
            let p1 = CGPoint(x: size.width * 0.09, y: size.height * 0.45) // left 1
            let p2 = CGPoint(x: size.width * 0.32, y: size.height * 0.49) // left 2
            let p3 = CGPoint(x: size.width * 1.14, y: size.height * 0.44) // right bottom
            let p4 = CGPoint(x: size.width * 1.30, y: size.height * 0.29) // right top
            let pq = CGPoint(x: size.width * 0.72, y: size.height * 0.53) // question

            // Build TOP→BOTTOM order automatically
            let items: [(String, CGFloat)] = [("p1", p1.y), ("p2", p2.y), ("p3", p3.y), ("p4", p4.y), ("pq", pq.y)]
            let order: [String: Double] =
                Dictionary(uniqueKeysWithValues:
                    items.sorted { $0.1 < $1.1 }   // ascending y
                         .enumerated()
                         .map { (idx, pair) in (pair.0, Double(idx)) }
                )

            ZStack {
                // Background
                Color(hex: "#FAF8F4").ignoresSafeArea()

                // Big circle (origin for emergence)
                Circle()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: radius * 2, height: radius * 2)
                    .position(circleCenter)
                    .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 7)

                // --- Elements EMERGING OUT of the circle ---

                // Left 1
                Capsule()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: 36, height: 160)
                    .position(p1)
                    .rotationEffect(.degrees(2))
                    .modifier(EmergeModifier(fromCenter: circleCenter, to: p1,
                                             emerge: emerge, duration: animDuration,
                                             delay: (order["p1"] ?? 0) * stagger))

                // Left 2
                Capsule()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: 36, height: 160)
                    .position(p2)
                    .rotationEffect(.degrees(14))
                    .modifier(EmergeModifier(fromCenter: circleCenter, to: p2,
                                             emerge: emerge, duration: animDuration,
                                             delay: (order["p2"] ?? 0) * stagger))

                // Right bottom
                Capsule()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: 36, height: 150)
                    .position(p3)
                    .rotationEffect(.degrees(60))
                    .modifier(EmergeModifier(fromCenter: circleCenter, to: p3,
                                             emerge: emerge, duration: animDuration,
                                             delay: (order["p3"] ?? 0) * stagger))

                // Right top
                Capsule()
                    .fill(Color(hex: "#0B2D4E"))
                    .frame(width: 36, height: 150)
                    .position(p4)
                    .rotationEffect(.degrees(86))
                    .modifier(EmergeModifier(fromCenter: circleCenter, to: p4,
                                             emerge: emerge, duration: animDuration,
                                             delay: (order["p4"] ?? 0) * stagger))

                // Question mark
                Text("?")
                    .font(.system(size: 390, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "#0B2D4E"))
                    .position(pq)
                    .rotationEffect(.degrees(37))
                    .modifier(EmergeModifier(fromCenter: circleCenter, to: pq,
                                             emerge: emerge, duration: animDuration,
                                             delay: (order["pq"] ?? 0) * stagger))

                // "DAY" appears after everything emerges
                Text("D")
                    .font(.system(size: 100, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "#FAF8F4"))
                    .position(x: size.width * 0.16, y: size.height * 0.82)
                    .opacity(showDay ? 1 : 0)
                    .rotation3DEffect(.degrees(showDay ? 0 : 80), axis: (x: 0, y: 0, z: 0))
                    .animation(.easeOut(duration: 0.2), value: showDay)
                
                Text("A")
                    .font(.system(size: 100, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "#FAF8F4"))
                    .position(x: size.width * 0.32, y: size.height * 0.82)
                    .opacity(showDay ? 1 : 0)
                    .rotation3DEffect(.degrees(showDay ? 0 : 80), axis: (x: 0, y: 0, z: 0))
                    .animation(.easeOut(duration: 0.4), value: showDay)
                
                Text("Y")
                    .font(.system(size: 100, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(hex: "#FAF8F4"))
                    .position(x: size.width * 0.45, y: size.height * 0.82)
                    .opacity(showDay ? 1 : 0)
                    .rotation3DEffect(.degrees(showDay ? 0 : 80), axis: (x: 0, y: 0, z: 0))
                    .animation(.easeOut(duration: 0.6), value: showDay)
            }
            .onAppear {
                // trigger emergence
                withAnimation(.easeOut(duration: animDuration)) {
                    emerge = true
                }
                // show "DAY" after the last (top→bottom) item is done
                let lastDelay = (items.count - 1).double * stagger
                DispatchQueue.main.asyncAfter(deadline: .now() + lastDelay + animDuration) {
                    showDay = true
                }
            }
        }
    }
}

// MARK: - Emerge (from circle center to final spot)
private struct EmergeModifier: ViewModifier {
    let fromCenter: CGPoint
    let to: CGPoint
    let emerge: Bool
    let duration: Double
    var delay: Double = 0
    var startScale: CGFloat = 0.2

    func body(content: Content) -> some View {
        let dx = fromCenter.x - to.x
        let dy = fromCenter.y - to.y

        content
            // content is positioned at 'to'; when not emerged, draw it offset back to the circle
            .offset(x: emerge ? 0 : dx, y: emerge ? 0 : dy)
            .scaleEffect(emerge ? 1 : startScale, anchor: .center)
            .opacity(emerge ? 1 : 0)
            .animation(.easeOut(duration: duration).delay(delay), value: emerge)
    }
}

// small helper
private extension Int { var double: Double { Double(self) } }

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
        self = Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

#Preview("Splash • emerge then DAY") {
    SplashView()
        .frame(width: 390, height: 844)
}
