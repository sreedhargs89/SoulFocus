// QuickStartView.swift
// Sheet: pick a mode + duration and begin immediately.

import SwiftUI

private let sheetBg    = Color(red: 0.07, green: 0.05, blue: 0.18)
private let accentGold = Color(red: 0.92, green: 0.75, blue: 0.30)
private let accentDark = Color(red: 0.95, green: 0.60, blue: 0.20)

struct QuickStartView: View {

    @ObservedObject var manager: SessionManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: SessionMode = .prayer
    @State private var selectedTradition: PrayerTradition = .hindu

    private let modes     = [SessionMode.prayer, .chanting]

    var body: some View {
        ZStack {
            sheetBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(.white.opacity(0.18))
                    .frame(width: 36, height: 4)
                    .padding(.top, 14)

                Text("Begin your practice")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)

                // Mode cards
                HStack(spacing: 12) {
                    ForEach(modes, id: \.self) { mode in
                        ModeCard(mode: mode, isSelected: selectedMode == mode) {
                            withAnimation(.spring(duration: 0.25)) { selectedMode = mode }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)

                // Duration pills / tradition chips
                // Tradition chips — 2 per row
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        ForEach([PrayerTradition.hindu, .christian]) { t in
                            quickTraditionChip(t)
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach([PrayerTradition.buddhist, .islam]) { t in
                            quickTraditionChip(t)
                        }
                    }
                    quickTraditionChip(.other)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                Spacer()

                // Begin button
                Button {
                    manager.begin(mode: selectedMode,
                                  duration: 0,
                                  moodBefore: 3,
                                  tradition: selectedTradition)
                    dismiss()
                } label: {
                    Text("Begin")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color(red: 0.10, green: 0.05, blue: 0.20))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(colors: [accentGold, accentDark],
                                           startPoint: .leading, endPoint: .trailing),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                }
                .hapticOnTap()
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .presentationBackground(sheetBg)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
    }

    // Compact chip used in the tradition picker inside this sheet
    @ViewBuilder
    private func quickTraditionChip(_ t: PrayerTradition) -> some View {
        let tint = Color(hex: t.accentHex) ?? accentGold
        let selected = selectedTradition == t
        Button {
            withAnimation(.spring(response: 0.25)) { selectedTradition = t }
        } label: {
            HStack(spacing: 6) {
                Text(t.emoji).font(.system(size: 16))
                Text(t.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(selected ? Color(red: 0.10, green: 0.05, blue: 0.20) : .white)
                Spacer()
                if selected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color(red: 0.10, green: 0.05, blue: 0.20))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(
                selected ? AnyShapeStyle(tint) : AnyShapeStyle(Color.white.opacity(0.10)),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selected ? .clear : Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .hapticOnTap()
    }
}

// MARK: - Mode Card

private struct ModeCard: View {
    let mode: SessionMode
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 30))
                    .foregroundStyle(isSelected
                                     ? Color(red: 0.10, green: 0.05, blue: 0.20)
                                     : accentGold)

                Text(mode.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isSelected
                                     ? Color(red: 0.10, green: 0.05, blue: 0.20)
                                     : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                isSelected ? accentGold : Color.white.opacity(0.10),
                in: RoundedRectangle(cornerRadius: 16)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .clear : Color.white.opacity(0.15), lineWidth: 1)
            )
        }
        .hapticOnTap()
    }
}
