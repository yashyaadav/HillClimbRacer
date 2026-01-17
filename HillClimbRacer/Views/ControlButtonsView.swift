//
//  ControlButtonsView.swift
//  HillClimbRacer
//
//  Interactive gas and brake pedal buttons with visual feedback.
//

import SwiftUI

/// Interactive control buttons for gas and brake pedals
struct ControlButtonsView: View {

    @ObservedObject var inputManager = InputManager.shared

    var body: some View {
        HStack(spacing: 0) {
            // Brake button (left side)
            PedalButton(
                label: "BRAKE",
                icon: "arrow.backward.circle.fill",
                color: .red,
                isPressed: inputManager.isBraking
            ) { isPressed in
                inputManager.isBraking = isPressed
            }

            Spacer()

            // Gas button (right side)
            PedalButton(
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

// MARK: - Pedal Button

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

// MARK: - Compact Pedal Button (for smaller screens)

struct CompactPedalButton: View {

    let label: String
    let icon: String
    let color: Color
    let isPressed: Bool
    let onPressChange: (Bool) -> Void

    @State private var isBeingTouched = false

    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(color.opacity(isBeingTouched ? 0.5 : 0.2))
                .overlay(
                    Circle()
                        .strokeBorder(color.opacity(isBeingTouched ? 1.0 : 0.4), lineWidth: 3)
                )

            // Icon
            Image(systemName: icon)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(color)
        }
        .frame(width: 70, height: 70)
        .scaleEffect(isBeingTouched ? 0.9 : 1.0)
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
    }
}

#Preview {
    ZStack {
        Color.blue.ignoresSafeArea()

        VStack {
            Spacer()
            ControlButtonsView()
        }
    }
}
