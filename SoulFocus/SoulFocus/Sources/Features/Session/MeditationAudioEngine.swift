// MeditationAudioEngine.swift
// Synthesised ambient soundscapes — no audio files required.
// Singing Bowl only.

import AVFoundation
import Combine
import SwiftUI

// MARK: - Ambient Track

enum AmbientTrack: String, CaseIterable, Identifiable {
    case bowl = "Singing Bowl"

    var id: String { rawValue }

    var icon: String { "circle.dotted" }
}

// MARK: - Engine

@MainActor
final class MeditationAudioEngine: ObservableObject {

    @Published var activeTrack: AmbientTrack? = nil

    private let sr: Double = 44100
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var reverb = AVAudioUnitReverb()
    private var eq     = AVAudioUnitEQ(numberOfBands: 2)

    // MARK: - Public API

    /// Toggle a track — tapping the active track stops it.
    func select(_ track: AmbientTrack) {
        if activeTrack == track { stop(); return }
        tearDown()
        activeTrack = track
        do { try boot(track) } catch { activeTrack = nil }
    }

    func pause() {
        guard engine.isRunning else { return }
        player.pause()
    }

    func resume() {
        guard engine.isRunning, activeTrack != nil else { return }
        player.play()
    }

    func stop() {
        tearDown()
        activeTrack = nil
    }

    // MARK: - Engine Lifecycle

    private func tearDown() {
        guard engine.isRunning else { return }
        player.stop()
        engine.stop()
    }

    private func boot(_ track: AmbientTrack) throws {
        try AVAudioSession.sharedInstance()
            .setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)

        // Rebuild nodes so we start clean
        engine = AVAudioEngine()
        player = AVAudioPlayerNode()
        reverb = AVAudioUnitReverb()
        eq     = AVAudioUnitEQ(numberOfBands: 2)

        engine.attach(player)
        engine.attach(eq)
        engine.attach(reverb)

        reverb.loadFactoryPreset(.cathedral)
        reverb.wetDryMix = 65
        // EQ bypass — bowl needs no filtering
        eq.bands[0].bypass = true
        eq.bands[1].bypass = true

        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!
        engine.connect(player, to: eq,     format: fmt)
        engine.connect(eq,     to: reverb, format: fmt)
        engine.connect(reverb, to: engine.mainMixerNode, format: fmt)
        engine.mainMixerNode.outputVolume = 0.75

        try engine.start()

        let buf = makeBowlBuffer(fmt)
        player.scheduleBuffer(buf, at: nil, options: .loops)
        player.play()
    }

    // MARK: - Buffer Generation

    private func makeBowlBuffer(_ fmt: AVAudioFormat) -> AVAudioPCMBuffer {
        // Exact strike cycle length — loops seamlessly
        let frames = AVAudioFrameCount(sr * 4.0)
        let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: frames)!
        buf.frameLength = frames

        let L = buf.floatChannelData![0]
        let R = buf.floatChannelData![1]
        fillBowl(L, R, Int(frames))
        return buf
    }

    // ── Tibetan Singing Bowl ──────────────────────────────────────────────────
    // 432 Hz fundamental + harmonics with a 4-second strike-and-decay cycle

    private func fillBowl(_ L: UnsafeMutablePointer<Float>,
                          _ R: UnsafeMutablePointer<Float>, _ n: Int) {
        let freq: Float  = 432
        let cycle        = Float(sr) * 4.0      // 4 s per strike
        let attackLen    = Float(sr) * 0.04     // 40 ms attack
        let decayLen     = Float(sr) * 3.5      // 3.5 s decay
        for i in 0..<n {
            let pos = Float(i).truncatingRemainder(dividingBy: cycle)
            let env: Float
            if pos < attackLen {
                env = pos / attackLen
            } else if pos < attackLen + decayLen {
                env = 1.0 - (pos - attackLen) / decayLen
            } else {
                env = 0
            }
            let t = Float(i) / Float(sr)
            let s = env * (
                0.60 * sin(2 * Float.pi * freq       * t) +
                0.25 * sin(2 * Float.pi * freq * 2   * t) +
                0.10 * sin(2 * Float.pi * freq * 3   * t)
            ) * 0.55
            L[i] = s; R[i] = s
        }
    }
}
