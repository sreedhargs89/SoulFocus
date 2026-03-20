// BreathingEngine.swift
// Drives the meditation breathing orb: phase cycling (inhale/hold/exhale/rest)
// at 30 fps, plus a programmatic 432 Hz bell that fires at chosen intervals.
// No bundled audio files needed — the bell is synthesised on-device.

import AVFoundation
import Combine
import SwiftUI

// MARK: - Meditation Enums (used by SessionManager, PracticeHomeView, ActiveSessionView)

enum MeditationIntention: String, CaseIterable, Identifiable {
    case peace      = "Peace"
    case clarity    = "Clarity"
    case gratitude  = "Gratitude"
    case focus      = "Focus"
    case healing    = "Healing"
    case surrender  = "Surrender"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .peace:     return "🕊️"
        case .clarity:   return "✨"
        case .gratitude: return "🙏"
        case .focus:     return "🔥"
        case .healing:   return "💚"
        case .surrender: return "🤍"
        }
    }

    var subtitle: String {
        switch self {
        case .peace:     return "Find stillness"
        case .clarity:   return "See with fresh eyes"
        case .gratitude: return "Open the heart"
        case .focus:     return "One-pointed mind"
        case .healing:   return "Restore and renew"
        case .surrender: return "Let it all go"
        }
    }
}

enum BreathingStyle: String, CaseIterable, Identifiable {
    case box            = "Box"
    case fourSevenEight = "4-7-8"
    case natural        = "Natural"
    case none           = "No Guide"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .box:            return "4·4·4·4  —  focus & calm"
        case .fourSevenEight: return "4·7·8  —  anxiety relief"
        case .natural:        return "5·7  —  gentle & easy"
        case .none:           return "Free awareness"
        }
    }

    var icon: String {
        switch self {
        case .box:            return "square.fill"
        case .fourSevenEight: return "waveform.path.ecg"
        case .natural:        return "leaf.fill"
        case .none:           return "circle.fill"
        }
    }

    // Returns (phase, duration) pairs. Phases with duration 0 are skipped.
    var phases: [(BreathingEngine.Phase, Double)] {
        switch self {
        case .box:
            return [(.inhale, 4), (.holdFull, 4), (.exhale, 4), (.holdEmpty, 4)]
        case .fourSevenEight:
            return [(.inhale, 4), (.holdFull, 7), (.exhale, 8)]
        case .natural:
            return [(.inhale, 5), (.exhale, 7)]
        case .none:
            return []    // engine runs idle-glow mode
        }
    }

    var cycleDuration: Double { phases.reduce(0) { $0 + $1.1 } }
}

enum BellInterval: String, CaseIterable, Identifiable {
    case none  = "None"
    case two   = "2 min"
    case five  = "5 min"
    case ten   = "10 min"

    var id: String { rawValue }

    var seconds: TimeInterval? {
        switch self {
        case .none:  return nil
        case .two:   return 120
        case .five:  return 300
        case .ten:   return 600
        }
    }

    var icon: String { self == .none ? "bell.slash.fill" : "bell.fill" }
}

// MARK: - Breathing Engine

@MainActor
final class BreathingEngine: ObservableObject {

    enum Phase: String {
        case inhale    = "Inhale"
        case holdFull  = "Hold"
        case exhale    = "Exhale"
        case holdEmpty = "Rest"

        var instruction: String {
            switch self {
            case .inhale:    return "Breathe in slowly…"
            case .holdFull:  return "Hold gently…"
            case .exhale:    return "Release slowly…"
            case .holdEmpty: return "Rest…"
            }
        }

        var color: Color {
            switch self {
            case .inhale, .holdFull:  return Color(red: 0.96, green: 0.58, blue: 0.11) // warm saffron
            case .exhale, .holdEmpty: return Color(red: 0.28, green: 0.52, blue: 0.82) // soft blue
            }
        }
    }

    // ─── Published ────────────────────────────────────────────────────────────
    @Published var currentPhase: Phase = .inhale
    @Published var phaseProgress: Double = 0   // 0→1 within current phase
    @Published var orbScale: Double = 0.55     // drives the orb animation
    @Published var orbColor: Color = Color(red: 0.96, green: 0.58, blue: 0.11)
    @Published var phaseTimeLeft: Double = 4   // seconds left in current phase
    @Published var cycleCount: Int = 0
    @Published var isRunning: Bool = false

    // ─── Config ───────────────────────────────────────────────────────────────
    private(set) var style: BreathingStyle = .box

    // ─── Private ──────────────────────────────────────────────────────────────
    private var displayTimer: Timer?
    private var elapsed: Double = 0
    private let fps = 1.0 / 30.0  // 30 Hz updates

    // ─── Public API ───────────────────────────────────────────────────────────

    func start(style: BreathingStyle) {
        self.style = style
        elapsed = 0
        cycleCount = 0
        isRunning = true
        currentPhase = .inhale
        phaseProgress = 0

        if style == .none {
            // Idle glow: orb just breathes gently without phase labels
            startIdleGlow()
            return
        }
        startTimer()
    }

    func pause() {
        displayTimer?.invalidate()
        displayTimer = nil
        isRunning = false
    }

    func resume() {
        isRunning = true
        if style == .none { startIdleGlow(); return }
        startTimer()
    }

    func stop() {
        displayTimer?.invalidate()
        displayTimer = nil
        isRunning = false
    }

    // ─── Private ──────────────────────────────────────────────────────────────

    private func startTimer() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: fps, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    private func tick() {
        elapsed += fps
        let cycleDur = style.cycleDuration
        guard cycleDur > 0 else { return }

        let cycleElapsed = elapsed.truncatingRemainder(dividingBy: cycleDur)
        cycleCount = Int(elapsed / cycleDur)

        var cumulative = 0.0
        for (phase, dur) in style.phases {
            if cycleElapsed < cumulative + dur {
                let withinPhase = cycleElapsed - cumulative
                currentPhase   = phase
                phaseProgress  = withinPhase / dur
                phaseTimeLeft  = dur - withinPhase

                // Orb scale: 0.55 (empty) ↔ 1.0 (full)
                switch phase {
                case .inhale:
                    orbScale = 0.55 + 0.45 * easeInOut(phaseProgress)
                case .holdFull:
                    orbScale = 1.0
                case .exhale:
                    orbScale = 1.0 - 0.45 * easeInOut(phaseProgress)
                case .holdEmpty:
                    orbScale = 0.55
                }
                orbColor = phase.color
                return
            }
            cumulative += dur
        }
    }

    /// Idle glow: slow sine-based breathe with no phase labels (for .none style)
    private func startIdleGlow() {
        displayTimer?.invalidate()
        displayTimer = Timer.scheduledTimer(withTimeInterval: fps, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.elapsed += self.fps
                // 8-second gentle cycle
                let t = (self.elapsed / 8.0) * 2 * .pi
                self.orbScale = 0.65 + 0.35 * (0.5 + 0.5 * sin(t - .pi / 2))
            }
        }
        RunLoop.main.add(displayTimer!, forMode: .common)
    }

    private func easeInOut(_ t: Double) -> Double {
        t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    }
}

// MARK: - Bell Engine
// Synthesises a 432 Hz sine wave with exponential decay — no audio file needed.

@MainActor
final class BellEngine {

    private var bellTimer: Timer?
    private var bellEngine: AVAudioEngine?
    private var bellPlayer: AVAudioPlayerNode?

    func start(interval: BellInterval) {
        stop()
        guard let seconds = interval.seconds else { return }
        // Fire the first bell immediately, then on each interval
        ring()
        bellTimer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.ring() }
        }
        RunLoop.main.add(bellTimer!, forMode: .common)
    }

    func stop() {
        bellTimer?.invalidate()
        bellTimer = nil
        bellEngine?.stop()
        bellEngine = nil
        bellPlayer = nil
    }

    func ring() {
        // 432 Hz — "healing frequency" A note
        synthesiseBell(frequency: 432, duration: 3.0, decay: 2.2, volume: 0.65)
        // Haptic accent
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // ─── Synthesis ────────────────────────────────────────────────────────────

    private func synthesiseBell(
        frequency: Double,
        duration: Double,
        decay: Double,
        volume: Float
    ) {
        let sampleRate: Double = 44100
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        ),
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)
        else { return }

        buffer.frameLength = frameCount

        // Fundamental + 2nd harmonic (softens the tone, like a real bowl)
        for i in 0 ..< Int(frameCount) {
            let t = Double(i) / sampleRate
            let env = Float(exp(-t * decay))
            let wave = Float(
                0.70 * sin(2 * .pi * frequency * t) +
                0.20 * sin(2 * .pi * frequency * 2 * t) +
                0.10 * sin(2 * .pi * frequency * 3 * t)
            )
            buffer.floatChannelData?[0][i] = wave * env * volume
        }

        // Build a fresh engine pair each time (simplest lifetime management)
        let eng = AVAudioEngine()
        let player = AVAudioPlayerNode()
        eng.attach(player)
        eng.connect(player, to: eng.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance()
                .setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            try eng.start()
        } catch { return }

        player.scheduleBuffer(buffer, completionHandler: { [weak self] in
            // Teardown on a background thread after playback ends
            eng.stop()
            if self?.bellEngine === eng { Task { @MainActor in self?.bellEngine = nil } }
        })
        player.play()

        // Store so we can stop early if needed
        bellEngine = eng
        bellPlayer = player
    }
}
