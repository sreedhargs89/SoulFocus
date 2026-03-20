// ActiveSessionView.swift
// Full-screen view while a session is active.
// Timer mode: countdown ring + pause/resume.
// Prayer mode: swipeable Hindu prayer cards with line-by-line English.

import SwiftUI

// ── Sacred Dawn palette (session screens) ────────────────────────────────────
private let sf_saffron  = Color(red: 0.96, green: 0.58, blue: 0.11)
private let sf_saffDark = Color(red: 0.88, green: 0.44, blue: 0.06)
private let sf_inkWarm  = Color(red: 0.07, green: 0.04, blue: 0.01)
private let sf_sienna   = Color(red: 0.28, green: 0.18, blue: 0.06)
private let sf_cardBg   = Color(red: 1.00, green: 0.99, blue: 0.96)
private let sf_cardBord = Color(red: 0.90, green: 0.82, blue: 0.70)
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - Prayer Data

private struct PrayerLine: Identifiable {
    let id = UUID()
    let sanskrit: String
    let transliteration: String
    let english: String
}

private struct HinduPrayer: Identifiable {
    let id = UUID()
    let name: String
    let lines: [PrayerLine]
}

// MARK: - Prayer Database (all traditions)

private let allPrayers: [PrayerTradition: [HinduPrayer]] = [

    // ── Hindu ─────────────────────────────────────────────────────────────────
    .hindu: [
        HinduPrayer(name: "Gayatri Mantra", lines: [
            PrayerLine(sanskrit: "ॐ भूर्भुवः स्वः",
                       transliteration: "Om Bhūr Bhuvaḥ Svaḥ",
                       english: "Om — the sacred syllable that pervades earth, sky, and heaven"),
            PrayerLine(sanskrit: "तत्सवितुर्वरेण्यं",
                       transliteration: "Tat Savitur Vareṇyam",
                       english: "We meditate on the radiant glory of the divine Sun"),
            PrayerLine(sanskrit: "भर्गो देवस्य धीमहि",
                       transliteration: "Bhargo Devasya Dhīmahi",
                       english: "The splendrous light of that divine Creator"),
            PrayerLine(sanskrit: "धियो यो नः प्रचोदयात्",
                       transliteration: "Dhiyo Yo Naḥ Pracodayāt",
                       english: "May He inspire and illuminate our intellect")
        ]),
        HinduPrayer(name: "Maha Mrityunjaya Mantra", lines: [
            PrayerLine(sanskrit: "ॐ त्र्यम्बकं यजामहे",
                       transliteration: "Om Tryambakam Yajāmahe",
                       english: "Om — we worship the three-eyed Lord Shiva"),
            PrayerLine(sanskrit: "सुगन्धिं पुष्टिवर्धनम्",
                       transliteration: "Sugandhim Pushtivardhanam",
                       english: "Who is fragrant and who nourishes all beings"),
            PrayerLine(sanskrit: "उर्वारुकमिव बन्धनात्",
                       transliteration: "Urvārukamiva Bandhanāt",
                       english: "As the ripe fruit is naturally freed from the vine"),
            PrayerLine(sanskrit: "मृत्योर्मुक्षीय माऽमृतात्",
                       transliteration: "Mrityor Mukshīya Māmritāt",
                       english: "May He liberate us from death and grant us immortality")
        ]),
        HinduPrayer(name: "Shanti Mantra", lines: [
            PrayerLine(sanskrit: "ॐ सर्वेशां स्वस्तिर्भवतु",
                       transliteration: "Om Sarveshāṃ Svastir Bhavatu",
                       english: "Om — may there be well-being for all"),
            PrayerLine(sanskrit: "सर्वेशां शान्तिर्भवतु",
                       transliteration: "Sarveshāṃ Shāntir Bhavatu",
                       english: "May there be peace for all"),
            PrayerLine(sanskrit: "सर्वेशां पूर्णं भवतु",
                       transliteration: "Sarveshāṃ Pūrṇam Bhavatu",
                       english: "May there be wholeness and fulfilment for all"),
            PrayerLine(sanskrit: "सर्वेशां मङ्गलं भवतु",
                       transliteration: "Sarveshāṃ Mangalam Bhavatu",
                       english: "May there be auspiciousness and joy for all")
        ])
    ],

    // ── Christian ─────────────────────────────────────────────────────────────
    .christian: [
        HinduPrayer(name: "The Lord's Prayer", lines: [
            PrayerLine(sanskrit: "Our Father, who art in heaven,",
                       transliteration: "Hallowed be Thy name.",
                       english: "We acknowledge God as our heavenly Father and honour His holiness"),
            PrayerLine(sanskrit: "Thy kingdom come, Thy will be done,",
                       transliteration: "On earth as it is in heaven.",
                       english: "We invite God's reign and surrender our will to His"),
            PrayerLine(sanskrit: "Give us this day our daily bread,",
                       transliteration: "And forgive us our trespasses, as we forgive others.",
                       english: "We ask for provision and the grace to forgive as we are forgiven"),
            PrayerLine(sanskrit: "Lead us not into temptation,",
                       transliteration: "But deliver us from evil. Amen.",
                       english: "We seek God's protection and guidance through every trial")
        ]),
        HinduPrayer(name: "Hail Mary", lines: [
            PrayerLine(sanskrit: "Hail Mary, full of grace,",
                       transliteration: "The Lord is with thee.",
                       english: "Mary is greeted as the favoured one, filled with God's presence"),
            PrayerLine(sanskrit: "Blessed art thou among women,",
                       transliteration: "And blessed is the fruit of thy womb, Jesus.",
                       english: "Mary is honoured above all; Jesus, born of her, is blessed"),
            PrayerLine(sanskrit: "Holy Mary, Mother of God,",
                       transliteration: "Pray for us sinners,",
                       english: "We ask Mary's intercession as Mother of God"),
            PrayerLine(sanskrit: "Now and at the hour of our death.",
                       transliteration: "Amen.",
                       english: "We seek her prayer through all of life, especially at its end")
        ]),
        HinduPrayer(name: "Prayer of St. Francis", lines: [
            PrayerLine(sanskrit: "Lord, make me an instrument of your peace.",
                       transliteration: "Where there is hatred, let me sow love;",
                       english: "We ask to be channels of God's peace in the world"),
            PrayerLine(sanskrit: "Where there is injury, pardon;",
                       transliteration: "Where there is doubt, faith;",
                       english: "We seek to respond to harm with healing, to doubt with trust"),
            PrayerLine(sanskrit: "Where there is darkness, light;",
                       transliteration: "And where there is sadness, joy.",
                       english: "We aspire to bring hope and gladness wherever we go"),
            PrayerLine(sanskrit: "Grant that I may not seek to be consoled",
                       transliteration: "As to console; not to be loved, as to love.",
                       english: "True peace begins in giving, not in receiving")
        ])
    ],

    // ── Buddhist ──────────────────────────────────────────────────────────────
    .buddhist: [
        HinduPrayer(name: "Metta — Loving-Kindness", lines: [
            PrayerLine(sanskrit: "May I be happy. May I be well.",
                       transliteration: "Ahaṃ sukhito homi.",
                       english: "We begin by wishing ourselves true happiness and freedom"),
            PrayerLine(sanskrit: "May all beings be happy.",
                       transliteration: "Sabbe sattā sukhitā hontu.",
                       english: "We extend loving-kindness to every living being without exception"),
            PrayerLine(sanskrit: "May all be free from suffering.",
                       transliteration: "Sabbe sattā averā hontu.",
                       english: "We wish all beings release from pain, fear, and hostility"),
            PrayerLine(sanskrit: "May all be at peace.",
                       transliteration: "Sabbe sattā sukhī attānaṃ pariharantu.",
                       english: "We hold all beings in the heart with equanimity and care")
        ]),
        HinduPrayer(name: "Om Mani Padme Hum", lines: [
            PrayerLine(sanskrit: "ॐ मणि पद्मे हूँ",
                       transliteration: "Om Maṇi Padme Hūṃ",
                       english: "The jewel in the lotus — compassion at the heart of wisdom"),
            PrayerLine(sanskrit: "OM — body, speech, and mind of the Buddha",
                       transliteration: "MANI — the jewel of compassion and method",
                       english: "The aspiration to achieve Buddhahood for the sake of all beings"),
            PrayerLine(sanskrit: "PADME — the lotus of wisdom",
                       transliteration: "Purity that blooms untouched above muddy waters",
                       english: "Wisdom that sees the true nature of all phenomena"),
            PrayerLine(sanskrit: "HUM — indivisibility of method and wisdom",
                       transliteration: "The seed syllable of the immovable mind",
                       english: "The union of compassion and emptiness — the path to liberation")
        ]),
        HinduPrayer(name: "Heart Sutra", lines: [
            PrayerLine(sanskrit: "Gate gate pāragate",
                       transliteration: "Gone, gone, gone beyond",
                       english: "Beyond the shore of suffering, beyond ordinary mind"),
            PrayerLine(sanskrit: "Pārasaṃgate",
                       transliteration: "Gone completely beyond",
                       english: "Fully awakened, liberated from all delusion"),
            PrayerLine(sanskrit: "Bodhi svāhā",
                       transliteration: "Awakening — so be it!",
                       english: "May we realise enlightenment for the benefit of all beings"),
            PrayerLine(sanskrit: "Form is emptiness. Emptiness is form.",
                       transliteration: "Rūpaṃ śūnyatā. Śūnyataiva rūpam.",
                       english: "All phenomena arise interdependently — nothing exists in isolation")
        ])
    ],

    // ── Islam ─────────────────────────────────────────────────────────────────
    .islam: [
        HinduPrayer(name: "Al-Fatiha", lines: [
            PrayerLine(sanskrit: "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
                       transliteration: "Bismillāhi r-raḥmāni r-raḥīm",
                       english: "In the name of Allah, the Most Gracious, the Most Merciful"),
            PrayerLine(sanskrit: "ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ",
                       transliteration: "Al-ḥamdu lillāhi rabbi l-ʿalamin",
                       english: "All praise is due to Allah, Lord of all the worlds"),
            PrayerLine(sanskrit: "إِيَّاكَ نَعۡبُدُ وَإِيَّاكَ نَسۡتَعِينُ",
                       transliteration: "Iyyāka naʿbudu wa iyyāka nastaʿīn",
                       english: "You alone we worship, and You alone we ask for help"),
            PrayerLine(sanskrit: "ٱهۡدِنَا ٱلصِّرَٰطَ ٱلۡمُسۡتَقِيمَ",
                       transliteration: "Ihdinā ṣ-ṣirāṭa l-mustaqīm",
                       english: "Guide us along the straight path — the way of those You have blessed")
        ]),
        HinduPrayer(name: "Ayat Al-Kursi", lines: [
            PrayerLine(sanskrit: "ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ ٱلۡحَىُّ ٱلۡقَيُّومُ",
                       transliteration: "Allāhu lā ilāha illā huwa l-ḥayyu l-qayyūm",
                       english: "Allah — there is no deity except Him, the Ever-Living, the Sustainer"),
            PrayerLine(sanskrit: "لَا تَأۡخُذُهُۥ سِنَةٌ وَلَا نَوۡمٌ",
                       transliteration: "Lā taʾkhudhuhu sinatun wa lā nawm",
                       english: "Neither drowsiness nor sleep overtakes Him — He is eternally aware"),
            PrayerLine(sanskrit: "وَسِعَ كُرۡسِيُّهُ ٱلسَّمَٰوَٰتِ وَٱلۡأَرۡضَ",
                       transliteration: "Wasiʿa kursiyyuhu s-samāwāti wa l-arḍ",
                       english: "His Throne extends over the heavens and the earth"),
            PrayerLine(sanskrit: "وَهُوَ ٱلۡعَلِىُّ ٱلۡعَظِيمُ",
                       transliteration: "Wa huwa l-ʿaliyyu l-ʿaẓīm",
                       english: "He is the Most High, the Most Great — beyond all comprehension")
        ]),
        HinduPrayer(name: "Tasbeeh — Dhikr", lines: [
            PrayerLine(sanskrit: "سُبۡحَانَ ٱللَّهِ",
                       transliteration: "SubḥānAllāh",
                       english: "Glory be to Allah — He is pure, beyond any imperfection"),
            PrayerLine(sanskrit: "ٱلۡحَمۡدُ لِلَّهِ",
                       transliteration: "Al-ḥamdulillāh",
                       english: "All praise belongs to Allah — gratitude for every breath"),
            PrayerLine(sanskrit: "ٱللَّهُ أَكۡبَرُ",
                       transliteration: "Allāhu Akbar",
                       english: "Allah is greater — greater than any worry, fear, or worldly concern"),
            PrayerLine(sanskrit: "لَآ إِلَٰهَ إِلَّا ٱللَّهُ",
                       transliteration: "Lā ilāha illAllāh",
                       english: "There is no god but Allah — the declaration of pure monotheism")
        ])
    ],

    // ── Universal ─────────────────────────────────────────────────────────────
    .other: [
        HinduPrayer(name: "Loving-Kindness", lines: [
            PrayerLine(sanskrit: "May I be happy. May I be healthy.",
                       transliteration: "May I be safe. May I live with ease.",
                       english: "We begin within — nurturing compassion for ourselves first"),
            PrayerLine(sanskrit: "May those I love be happy and healthy.",
                       transliteration: "May they be safe. May they live with ease.",
                       english: "We extend warmth outward to family and close friends"),
            PrayerLine(sanskrit: "May all people — known and unknown — be happy.",
                       transliteration: "May all beings everywhere be at peace.",
                       english: "We open our hearts without condition to every living being"),
            PrayerLine(sanskrit: "May all beings in all worlds be free from suffering.",
                       transliteration: "May all beings be joyful and whole.",
                       english: "We hold all existence in unconditional goodwill")
        ]),
        HinduPrayer(name: "Serenity Prayer", lines: [
            PrayerLine(sanskrit: "God, grant me the serenity",
                       transliteration: "To accept the things I cannot change,",
                       english: "We ask for peace in the face of what lies beyond our control"),
            PrayerLine(sanskrit: "Courage to change the things I can,",
                       transliteration: "And wisdom to know the difference.",
                       english: "We seek clarity to act where we can, and release where we cannot"),
            PrayerLine(sanskrit: "Living one day at a time;",
                       transliteration: "Enjoying one moment at a time;",
                       english: "We return fully to the present — this breath, this moment"),
            PrayerLine(sanskrit: "Accepting hardship as the pathway to peace.",
                       transliteration: "Trusting that all shall be well.",
                       english: "We surrender to life's unfolding with faith and equanimity")
        ]),
        HinduPrayer(name: "Peace in All Directions", lines: [
            PrayerLine(sanskrit: "Peace above me, peace below me.",
                       transliteration: "Peace to my left, peace to my right.",
                       english: "We call forth peace in every dimension of our being"),
            PrayerLine(sanskrit: "Peace before me, peace behind me.",
                       transliteration: "Peace within me, peace around me.",
                       english: "We release the tensions of past and future — only now remains"),
            PrayerLine(sanskrit: "I am peace. I carry peace.",
                       transliteration: "I share peace with all I meet.",
                       english: "Peace is not found — it is embodied and radiated outward"),
            PrayerLine(sanskrit: "May peace prevail on earth.",
                       transliteration: "In all hearts. In all lands.",
                       english: "We dedicate this stillness to the healing of the whole world")
        ])
    ]
]

// MARK: - Active Session View

struct ActiveSessionView: View {

    @ObservedObject var manager: SessionManager
    @Environment(\.sfTheme) private var theme
    @StateObject private var audio        = MeditationAudioEngine()
    @StateObject private var breather     = BreathingEngine()
    private let bellEngine                = BellEngine()

    @State private var showEndAlert = false

    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()

            if manager.selectedMode == .prayer {
                prayerView
            } else if manager.selectedMode == .chanting {
                chantView
            } else {
                timerView
            }

            if manager.selectedMode == .prayer || manager.selectedMode == .chanting {
                VStack {
                    HStack {
                        Spacer()
                        Text(manager.timeRemaining.timerString)
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                            .foregroundStyle(sf_sienna)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(sf_cardBg.opacity(0.8), in: Capsule())
                            .overlay(Capsule().stroke(sf_cardBord.opacity(0.6), lineWidth: 1))
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            // Start meditation engines
            if manager.selectedMode == .meditation {
                breather.start(style: manager.breathingStyle)
                bellEngine.start(interval: manager.bellInterval)
            }
        }
        .onDisappear {
            audio.stop()
            breather.stop()
            bellEngine.stop()
        }
        .alert("End Session?", isPresented: $showEndAlert) {
            Button("Keep Going", role: .cancel) {}
            Button("End Session", role: .destructive) {
                audio.stop()
                breather.stop()
                bellEngine.stop()
                manager.end(completed: false)
            }
        } message: {
            Text("Your progress will be saved as an incomplete session.")
        }
    }

    // MARK: - Prayer View

    private var prayerView: some View {
        let tradition = manager.selectedTradition
        let prayers   = allPrayers[tradition] ?? []
        let tint      = Color(hex: tradition.accentHex) ?? sf_saffron

        return VStack(spacing: 0) {

            // ── Tradition header ─────────────────────────────────────────────
            VStack(spacing: 4) {
                Text(tradition.emoji)
                    .font(.system(size: 32))
                Text(tradition.displayName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint)
                Text("Prayer Session")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(sf_sienna.opacity(0.65))
                    .tracking(0.8)
            }
            .padding(.top, 56)
            .padding(.bottom, 16)

            // Each page independently scrollable so tall content never clips
            TabView {
                ForEach(prayers) { prayer in
                    ScrollView(showsIndicators: false) {
                        PrayerCard(
                            prayer: prayer,
                            theme: theme,
                            accentColor: tint
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 32)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: .infinity)

            Button {
                manager.end(completed: true)
            } label: {
                Label("End Prayer", systemImage: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(colors: [tint, tint.opacity(0.75)],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .foregroundStyle(.white)
                    .shadow(color: tint.opacity(0.30), radius: 12, y: 5)
            }
            .hapticOnTap(style: .medium)
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }


    // MARK: - Chant View

    private var chantView: some View {
        let tradition = manager.selectedTradition
        let chants    = allChants[tradition] ?? []
        let tint      = Color(hex: tradition.accentHex) ?? sf_saffron

        return VStack(spacing: 0) {

            // ── Tradition header ─────────────────────────────────────────────
            VStack(spacing: 4) {
                Text(tradition.emoji)
                    .font(.system(size: 32))
                Text(tradition.displayName)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(tint)
                Text("Chanting Session")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(sf_sienna.opacity(0.65))
                    .tracking(0.8)
            }
            .padding(.top, 56)
            .padding(.bottom, 16)

            // ── Chant cards ──────────────────────────────────────────────────
            TabView {
                ForEach(chants) { chant in
                    ScrollView(showsIndicators: false) {
                        ChantCard(
                            chant: chant,
                            theme: theme,
                            accentColor: tint
                        )
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    .padding(.bottom, 32)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: .infinity)

            // ── End button ───────────────────────────────────────────────────
            Button {
                manager.end(completed: true)
            } label: {
                Label("End Chanting", systemImage: "checkmark.circle.fill")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(colors: [tint, tint.opacity(0.75)],
                                       startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                    .foregroundStyle(.white)
                    .shadow(color: tint.opacity(0.30), radius: 12, y: 5)
            }
            .hapticOnTap(style: .medium)
            .padding(.horizontal, 24)
            .padding(.bottom, 52)
        }
    }

    // MARK: - Timer View

    private var timerView: some View {
        VStack(spacing: 28) {
            Spacer()

            Label(manager.selectedMode.displayName, systemImage: manager.selectedMode.systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(sf_sienna)

            breathingOrb
                .padding(.vertical, 20)

            if manager.selectedMode == .meditation {
                soundPicker
            } else {
                Text(manager.phase.isPaused ? "Paused" : "In Session")
                    .font(.subheadline)
                    .foregroundStyle(sf_sienna.opacity(0.75))
            }

            Spacer()

            timerControls
                .padding(.bottom, 48)
        }
    }

    // MARK: - Sound / Chant Pickers

    private var soundPicker: some View {
        VStack(spacing: 8) {
            Text("AMBIENT SOUND")
                .font(.caption.weight(.semibold))
                .tracking(1.2)
                .foregroundStyle(sf_sienna.opacity(0.55))
            HStack(spacing: 8) {
                ForEach(AmbientTrack.allCases) { track in
                    MusicChip(icon: track.icon, label: track.rawValue,
                              isActive: audio.activeTrack == track) {
                        audio.select(track)
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }

    // Removed chantPicker

    // MARK: - Breathing Orb

    private var breathingOrb: some View {
        ZStack {
            // Very dim outer track for time progress
            Circle()
                .stroke(theme.timerRingColor.opacity(0.12), lineWidth: 4)

            // Inner orbit: session progress
            Circle()
                .trim(from: 0, to: manager.progress)
                .stroke(
                    theme.timerRingColor.opacity(0.8),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: manager.progress)

            // The Orb
            Circle()
                .fill(breather.orbColor.opacity(0.85))
                .blur(radius: breather.orbScale > 0.6 ? 8 : 4) // soft edges
                .scaleEffect(breather.orbScale)
                .animation(.easeInOut(duration: 0.1), value: breather.orbScale)

            // Content inside orb
            VStack(spacing: 6) {
                if breather.style != .none {
                    Text(breather.currentPhase.instruction)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white)
                        .animation(.easeInOut, value: breather.currentPhase)
                }

                Text(manager.timeRemaining.timerString)
                    .font(.system(size: 48, weight: .thin, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
        .frame(width: 280, height: 280)
    }

    // MARK: - Timer Controls

    private var timerControls: some View {
        Group {
            if manager.selectedMode == .meditation {
                // Meditation: cancel only — no pause. Sound is toggled via the bowl chip above.
                Button { showEndAlert = true } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(theme.secondaryText.opacity(0.7))
                }
            } else {
                HStack(spacing: 32) {
                    Button { showEndAlert = true } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(theme.secondaryText.opacity(0.7))
                    }

                    Button {
                        if manager.phase.isActive {
                            manager.pause(); audio.pause()
                            breather.pause()
                            bellEngine.stop()
                        } else {
                            manager.resume(); audio.resume()
                            breather.resume()
                            bellEngine.start(interval: manager.bellInterval)
                        }
                    } label: {
                        Image(systemName: manager.phase.isActive ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 72))
                            .foregroundStyle(theme.accentColor)
                    }
                    .hapticOnTap(style: .medium)

                    Color.clear.frame(width: 48, height: 48)
                }
            }
        }
    }
}

// MARK: - Chant Card

private struct ChantCard: View {
    let chant       : ChantInfo
    let theme       : any AppTheme
    var accentColor : Color = Color(red: 0.96, green: 0.58, blue: 0.11)

    @State private var pulse = false

    var body: some View {
        VStack(spacing: 0) {

            // ── Name ─────────────────────────────────────────────────────────
            Text(chant.name)
                .font(.title3.weight(.bold))
                .foregroundStyle(sf_inkWarm)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            // ── Native script ─────────────────────────────────────────────────
            if let script = chant.script {
                Text(script)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(accentColor)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)
            }

            // ── Accent divider ────────────────────────────────────────────────
            Rectangle()
                .fill(accentColor.opacity(0.30))
                .frame(height: 0.5)
                .padding(.bottom, 14)

            // ── Pronunciation ─────────────────────────────────────────────────
            VStack(spacing: 4) {
                Text("PRONUNCIATION")
                    .font(.caption2.weight(.semibold))
                    .tracking(1.0)
                    .foregroundStyle(sf_sienna.opacity(0.50))
                Text(chant.pronunciation)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(sf_inkWarm)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 14)

            // ── Meaning ───────────────────────────────────────────────────────
            Rectangle()
                .fill(Color(red: 0.90, green: 0.82, blue: 0.70).opacity(0.35))
                .frame(height: 0.5)
                .padding(.vertical, 14)

            Text(chant.meaning)
                .font(.callout)
                .foregroundStyle(sf_sienna)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, 16)

            // ── Tempo badge ───────────────────────────────────────────────────
            HStack(spacing: 5) {
                Image(systemName: chant.tempo.icon)
                Text("Tempo: \(chant.tempo.rawValue)  ·  \(chant.tempo.bpm) BPM")
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(accentColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(accentColor.opacity(0.10), in: Capsule())
            .padding(.bottom, 16)

            // ── Self-chant rhythm guide ──────────────────────────────────────
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(pulse ? 0.18 : 0.07))
                        .frame(width: 64, height: 64)
                        .scaleEffect(pulse ? 1.12 : 1.0)
                        .animation(
                            .easeInOut(duration: 60.0 / Double(chant.tempo.bpm))
                            .repeatForever(autoreverses: true),
                            value: pulse
                        )
                    Image(systemName: "mouth.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(accentColor)
                }
                Text("Chant along with the rhythm")
                    .font(.caption)
                    .foregroundStyle(sf_sienna.opacity(0.65))
            }
            .onAppear  { pulse = true  }
            .onDisappear { pulse = false }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(sf_cardBg, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(sf_cardBord.opacity(0.50), lineWidth: 1))
        .shadow(color: accentColor.opacity(0.09), radius: 8, y: 3)
    }
}

// MARK: - Prayer Card

private struct PrayerCard: View {
    let prayer: HinduPrayer
    let theme: any AppTheme
    var accentColor: Color = Color(red: 0.96, green: 0.58, blue: 0.11) // saffron default

    var body: some View {
        VStack(spacing: 0) {

            // ── Title ────────────────────────────────────────────────────────
            Text(prayer.name)
                .font(.title3.weight(.bold))
                .foregroundStyle(sf_inkWarm)
                .multilineTextAlignment(.center)
                .padding(.bottom, 14)

            accentRule

            // ── Verse lines ──────────────────────────────────────────────────
            VStack(spacing: 0) {
                ForEach(Array(prayer.lines.enumerated()), id: \.element.id) { index, line in
                    PrayerLineView(line: line, theme: theme)

                    if index < prayer.lines.count - 1 {
                        subtleRule
                    }
                }
            }
            .padding(.top, 14)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(sf_cardBg, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(sf_cardBord.opacity(0.50), lineWidth: 1))
        .shadow(color: accentColor.opacity(0.09), radius: 8, y: 3)
    }

    private var accentRule: some View {
        Rectangle()
            .fill(accentColor.opacity(0.35))
            .frame(height: 0.5)
    }

    private var subtleRule: some View {
        Rectangle()
            .fill(Color(red: 0.90, green: 0.82, blue: 0.70).opacity(0.35))
            .frame(height: 0.5)
            .padding(.vertical, 14)
    }
}

// MARK: - Prayer Line View

private struct PrayerLineView: View {
    let line: PrayerLine
    let theme: any AppTheme

    var body: some View {
        VStack(spacing: 5) {
            // Sanskrit
            Text(line.sanskrit)
                .font(.title3.weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(sf_inkWarm)
                .lineSpacing(4)

            // Transliteration
            Text(line.transliteration)
                .font(.subheadline.italic())
                .multilineTextAlignment(.center)
                .foregroundStyle(sf_sienna.opacity(0.75))

            // English
            Text(line.english)
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(sf_sienna)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Music Chip (shared by ambient + chant pickers)

private struct MusicChip: View {
    let icon: String
    let label: String
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(isActive ? sf_inkWarm : sf_sienna)
            .background(
                isActive
                    ? AnyShapeStyle(LinearGradient(colors: [sf_saffron, sf_saffDark],
                                                   startPoint: .leading, endPoint: .trailing))
                    : AnyShapeStyle(sf_cardBg),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isActive ? .clear : sf_cardBord.opacity(0.55), lineWidth: 1)
            )
            .shadow(color: isActive ? sf_saffron.opacity(0.22) : .clear, radius: 6, y: 3)
        }
        .hapticOnTap()
    }
}

// MARK: - Previews

#Preview("Timer Mode") {
    ActiveSessionView(manager: {
        let m = SessionManager(persistence: PersistenceController.preview)
        m.begin(mode: .meditation, duration: 600, moodBefore: 3)
        return m
    }())
    .environment(\.sfTheme, CalmTheme())
}

#Preview("Prayer Mode") {
    ActiveSessionView(manager: {
        let m = SessionManager(persistence: PersistenceController.preview)
        m.begin(mode: .prayer, duration: 0, moodBefore: 3)
        return m
    }())
    .environment(\.sfTheme, SaffronTheme())
}
