//
//  ModernHeader.swift
//  Aurtsy
//

import SwiftUI

struct ModernHeader: View {
    @EnvironmentObject var network: NetworkManager

    // MARK: - Derived display
    private var displayName: String {
        if let user = network.currentUser {
            return user.email // Or add a name property to User if available
        }
        return "Guest"
    }

    private var initials: String {
        let parts = displayName.split(separator: "@")
        if let first = parts.first?.first {
            return String(first).uppercased()
        }
        return "U"
    }

    private var compactDate: String {
        // Short, one-line date to avoid wrapping on narrower devices
        Date().formatted(.dateTime.month(.abbreviated).day().year())
    }

    var body: some View {
        HStack(spacing: 12) {

            // LEFT CLUSTER: avatar + name/location
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.primary.opacity(0.10),
                                    Color.primary.opacity(0.20)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle().stroke(Color.primary.opacity(0.12), lineWidth: 2)
                        )
                        .frame(width: 48, height: 48)

                    Text(initials)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(displayName)
                        .font(.headline.weight(.medium))
                        .lineLimit(1)                   // 🔑 don’t wrap
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.85)

                    HStack(spacing: 6) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .frame(width: 12, height: 12)

                        Text("Home")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .minimumScaleFactor(0.9)

                        Circle()
                            .fill(network.currentUser != nil ? Color.green : Color.secondary.opacity(0.5))
                            .frame(width: 4, height: 4)

                        Text(network.currentUser != nil ? "Active" : "Signed out")
                            .font(.subheadline)
                            .foregroundColor(network.currentUser != nil ? .green : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                    }
                }
            }
            // Give the left cluster priority so it resists compression on smaller widths
            .layoutPriority(1)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Spacer ensures breathing room between clusters
            Spacer(minLength: 8)

            // RIGHT CLUSTER: date + icon buttons (fixed sizes, non-compressing)
            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 1) {
                    Text("Today")
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Text(compactDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                .fixedSize(horizontal: true, vertical: false)

                HeaderIconButton(systemName: "bell") { /* notifications */ }
                HeaderIconButton(systemName: "gearshape") { /* settings */ }

                // Optional: a small logout button (kept as icon to preserve width)
                HeaderIconButton(systemName: "rectangle.portrait.and.arrow.right") {
                    network.currentUser = nil
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(.primary.opacity(0.1)),
                    alignment: .bottom
                )
        )
        // Help the header honor safe areas and not slide under the Dynamic Island
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

// MARK: - Small, fixed-size icon button used on the right cluster
private struct HeaderIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .frame(width: 40, height: 40) // 🔒 fixed hit target
                .background(Circle().fill(Color.primary.opacity(0.06)))
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .fixedSize() // don’t let the button compress smaller than intended
    }
}
