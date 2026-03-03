// View+Extensions.swift
// Reusable SwiftUI view modifiers and helpers.

import SwiftUI

// MARK: - Conditional Modifier

extension View {

    /// Apply a modifier only when `condition` is true.
    ///
    /// Usage:
    ///   Text("Hello")
    ///     .if(isPremium) { $0.foregroundStyle(.gold) }
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply one of two transforms based on a condition.
    @ViewBuilder
    func if_<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Card Style

extension View {

    /// Standard SoulFocus card appearance — frosted glass background, rounded corners.
    func sfCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    /// Full-bleed card with a solid color fill.
    func sfSolidCard(color: Color = Color(.systemBackground), cornerRadius: CGFloat = 16) -> some View {
        self
            .padding()
            .background(color, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

// MARK: - Haptic Feedback

extension View {

    /// Trigger a light haptic on tap.
    func hapticOnTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
}

// MARK: - Loading Overlay

extension View {

    /// Overlays a progress indicator when `isLoading` is true.
    func loadingOverlay(_ isLoading: Bool) -> some View {
        self.overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                }
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Gradient Background

extension View {

    /// Applies the app's full-screen gradient background.
    func sfBackground(_ gradient: LinearGradient) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(gradient.ignoresSafeArea())
    }
}
