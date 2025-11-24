//
//  PrimaryCapsule.swift
//  Aurtsy
//
//  Created by dgoud on 9/19/25.
//

import SwiftUI

struct PrimaryCapsule: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Capsule().fill(
                    LinearGradient(colors: [.primary, .primary.opacity(0.8)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryCapsule: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(
                Capsule().fill(Color.primary.opacity(0.05))
                    .overlay(Capsule().stroke(Color.primary.opacity(0.15), lineWidth: 1))
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
