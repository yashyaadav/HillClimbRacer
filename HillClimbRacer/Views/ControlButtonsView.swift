//
//  ControlButtonsView.swift
//  HillClimbRacer
//
//  Interactive gas and brake pedal buttons with metal-style visual feedback.
//

import SwiftUI

/// Interactive control buttons for gas and brake pedals
struct ControlButtonsView: View {

    @ObservedObject var inputManager = InputManager.shared

    var body: some View {
        HStack(spacing: 0) {
            // Brake button (left side)
            MetalPedalButton(
                label: "BRAKE",
                icon: "arrow.backward.circle.fill",
                color: .red,
                isPressed: inputManager.isBraking
            ) { isPressed in
                inputManager.isBraking = isPressed
            }

            Spacer()

            // Gas button (right side)
            MetalPedalButton(
                label: "GAS",
                icon: "arrow.forward.circle.fill",
                color: .green,
                isPressed: inputManager.isThrottling
            ) { isPressed in
                inputManager.isThrottling = isPressed
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - Metal Pedal Button

struct MetalPedalButton: View {

    let label: String
    let icon: String
    let color: Color
    let isPressed: Bool
    let onPressChange: (Bool) -> Void

    @State private var isBeingTouched = false

    // Metal appearance colors
    private var bezelColor: Color {
        Color(white: 0.15)
    }

    private var innerBezelColor: Color {
        Color(white: isBeingTouched ? 0.2 : 0.25)
    }

    private var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [
                color.opacity(0.9),
                color.opacity(0.7),
                color.opacity(0.4)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var highlightGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(isBeingTouched ? 0.2 : 0.4),
                Color.white.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .center
        )
    }

    var body: some View {
        VStack(spacing: 6) {
            // Pedal icon
            Image(systemName: icon)
                .font(.system(size: 44, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.white,
                            color.opacity(0.9)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: color.opacity(0.8), radius: isBeingTouched ? 2 : 6)

            // Label
            Text(label)
                .font(.system(size: 12, weight: .heavy))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.5), radius: 1, x: 0, y: 1)
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 18)
        .background(
            // Outer dark bezel
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(bezelColor)
                    .shadow(color: .black.opacity(0.6), radius: isBeingTouched ? 2 : 6, x: 0, y: isBeingTouched ? 2 : 4)

                // Inner bezel
                RoundedRectangle(cornerRadius: 14)
                    .fill(innerBezelColor)
                    .padding(3)

                // Main button surface with gradient
                RoundedRectangle(cornerRadius: 12)
                    .fill(buttonGradient)
                    .padding(5)

                // Top highlight reflection
                RoundedRectangle(cornerRadius: 12)
                    .fill(highlightGradient)
                    .padding(5)

                // Inner shadow for depth
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.clear,
                                Color.black.opacity(0.4)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 2
                    )
                    .padding(5)

                // Outer ring glow when pressed
                if isBeingTouched {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.6), lineWidth: 2)
                }
            }
        )
        .scaleEffect(isBeingTouched ? 0.96 : 1.0)
        .offset(y: isBeingTouched ? 2 : 0)  // Press down effect
        .animation(.easeInOut(duration: 0.08), value: isBeingTouched)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isBeingTouched {
                        isBeingTouched = true
                        onPressChange(true)
                    }
                }
                .onEnded { _ in
                    isBeingTouched = false
                    onPressChange(false)
                }
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onChanged { _ in
                    if !isBeingTouched {
                        isBeingTouched = true
                        onPressChange(true)
                    }
                }
        )
    }
}

// MARK: - Legacy Pedal Button (kept for compatibility)

struct PedalButton: View {

    let label: String
    let icon: String
    let color: Color
    let isPressed: Bool
    let onPressChange: (Bool) -> Void

    @State private var isBeingTouched = false

    var body: some View {
        VStack(spacing: 8) {
            // Pedal icon
            Image(systemName: icon)
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(color)

            // Label
            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(isBeingTouched ? 0.5 : 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(color.opacity(isBeingTouched ? 1.0 : 0.4), lineWidth: 3)
                )
        )
        .scaleEffect(isBeingTouched ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isBeingTouched)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isBeingTouched {
                        isBeingTouched = true
                        onPressChange(true)
                    }
                }
                .onEnded { _ in
                    isBeingTouched = false
                    onPressChange(false)
                }
        )
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.01)
                .onChanged { _ in
                    if !isBeingTouched {
                        isBeingTouched = true
                        onPressChange(true)
                    }
                }
        )
    }
}

// MARK: - Compact Metal Pedal Button (for smaller screens)

struct CompactPedalButton: View {

    let label: String
    let icon: String
    let color: Color
    let isPressed: Bool
    let onPressChange: (Bool) -> Void

    @State private var isBeingTouched = false

    var body: some View {
        ZStack {
            // Outer bezel
            Circle()
                .fill(Color(white: 0.15))
                .shadow(color: .black.opacity(0.5), radius: isBeingTouched ? 2 : 4, x: 0, y: isBeingTouched ? 1 : 2)

            // Inner bezel
            Circle()
                .fill(Color(white: 0.25))
                .padding(3)

            // Main button surface
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            color.opacity(0.9),
                            color.opacity(0.6),
                            color.opacity(0.35)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(5)

            // Top highlight
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isBeingTouched ? 0.15 : 0.35),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(5)

            // Icon
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, color.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: color.opacity(0.6), radius: isBeingTouched ? 1 : 3)
        }
        .frame(width: 70, height: 70)
        .scaleEffect(isBeingTouched ? 0.94 : 1.0)
        .offset(y: isBeingTouched ? 1 : 0)
        .animation(.easeInOut(duration: 0.08), value: isBeingTouched)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isBeingTouched {
                        isBeingTouched = true
                        onPressChange(true)
                    }
                }
                .onEnded { _ in
                    isBeingTouched = false
                    onPressChange(false)
                }
        )
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.3)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            ControlButtonsView()
        }
    }
}
