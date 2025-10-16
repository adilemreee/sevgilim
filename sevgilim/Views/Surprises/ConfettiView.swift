//
//  ConfettiView.swift
//  sevgilim
//

import SwiftUI

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, size: geometry.size)
                }
            }
        }
        .onAppear {
            generateConfetti()
        }
        .allowsHitTesting(false)
    }
    
    private func generateConfetti() {
        let colors: [Color] = [.pink, .purple, .red, .orange, .yellow, .mint, .cyan, .blue]
        let shapes: [ConfettiShape] = [.circle, .square, .triangle]
        
        for _ in 0..<80 {
            let piece = ConfettiPiece(
                color: colors.randomElement()!,
                shape: shapes.randomElement()!,
                startX: CGFloat.random(in: 0...1),
                delay: Double.random(in: 0...0.3),
                duration: Double.random(in: 1.5...2.5),
                rotation: Double.random(in: 0...360),
                xOffset: CGFloat.random(in: -50...50)
            )
            confettiPieces.append(piece)
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let shape: ConfettiShape
    let startX: CGFloat
    let delay: Double
    let duration: Double
    let rotation: Double
    let xOffset: CGFloat
}

enum ConfettiShape {
    case circle, square, triangle
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let size: CGSize
    
    @State private var offsetY: CGFloat = -20
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        shapeView
            .foregroundColor(piece.color)
            .frame(width: 10, height: 10)
            .offset(x: piece.startX * size.width + offsetX, y: offsetY)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .easeOut(duration: piece.duration)
                    .delay(piece.delay)
                ) {
                    offsetY = size.height + 20
                    offsetX = piece.xOffset
                    opacity = 0
                    rotation = piece.rotation
                }
            }
    }
    
    @ViewBuilder
    private var shapeView: some View {
        switch piece.shape {
        case .circle:
            Circle()
        case .square:
            Rectangle()
        case .triangle:
            Triangle()
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Kullanım kolaylığı için modifier
struct ConfettiModifier: ViewModifier {
    let trigger: Bool
    @State private var isShowing = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if isShowing {
                        ConfettiView()
                    }
                }
            )
            .onChange(of: trigger) { _, newValue in
                if newValue && !isShowing {
                    isShowing = true
                    
                    // 3 saniye sonra konfettiyi kaldır
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        isShowing = false
                    }
                }
            }
    }
}

extension View {
    func confetti(isActive: Bool) -> some View {
        modifier(ConfettiModifier(trigger: isActive))
    }
}
