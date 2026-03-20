// ChantAudioEngine.swift
// Chant library — text-only, users chant themselves.

import Foundation

// MARK: - Chant Info

struct ChantInfo: Identifiable {
    let id         = UUID()
    let tradition  : PrayerTradition
    let name       : String
    let script     : String?
    let pronunciation: String
    let meaning    : String
    let tempo      : ChantTempo
}

enum ChantTempo: String {
    case slow   = "Slow"
    case medium = "Medium"
    case fast   = "Fast"

    var bpm: Int {
        switch self { case .slow: return 40; case .medium: return 60; case .fast: return 90 }
    }

    var icon: String {
        switch self { case .slow: return "tortoise.fill"; case .medium: return "figure.walk"; case .fast: return "hare.fill" }
    }
}

// MARK: - Global Chant Library

let allChants: [PrayerTradition: [ChantInfo]] = [

    // ── Hindu ─────────────────────────────────────────────────────────────────
    .hindu: [
        ChantInfo(tradition: .hindu,
                  name: "Om",
                  script: "ॐ",
                  pronunciation: "Ohm",
                  meaning: "The primordial sound of the universe — the vibration that underlies all of creation.",
                  tempo: .slow),
        ChantInfo(tradition: .hindu,
                  name: "Hare Krishna",
                  script: "हरे कृष्ण हरे कृष्ण · कृष्ण कृष्ण हरे हरे · हरे राम हरे राम · राम राम हरे हरे",
                  pronunciation: "Hah-ray Krish-na · Hah-ray Raa-ma",
                  meaning: "A call to the divine energy of Krishna and Rama — the Maha Mantra removes all obstacles and fills the heart with divine love.",
                  tempo: .medium),
        ChantInfo(tradition: .hindu,
                  name: "Om Namah Shivaya",
                  script: "ॐ नमः शिवाय",
                  pronunciation: "Om Na-mah Shi-vaa-ya",
                  meaning: "I bow to Shiva — the five syllables represent the five elements: earth, water, fire, air, and ether.",
                  tempo: .medium),
    ],

    // ── Christian ─────────────────────────────────────────────────────────────
    .christian: [
        ChantInfo(tradition: .christian,
                  name: "Kyrie Eleison",
                  script: "Κύριε, ἐλέησον",
                  pronunciation: "Kee-ree-eh · Eh-leh-ee-son",
                  meaning: "\"Lord, have mercy\" — the oldest Christian chant, used in Catholic, Orthodox, and Lutheran liturgy for 2,000 years.",
                  tempo: .slow),
        ChantInfo(tradition: .christian,
                  name: "Alleluia",
                  script: "הַלְלוּיָהּ",
                  pronunciation: "Al-leh-LOO-ya",
                  meaning: "\"Praise the Lord\" — a Hebrew word embraced by all Christian traditions as the highest expression of joyful praise.",
                  tempo: .medium),
        ChantInfo(tradition: .christian,
                  name: "Maranatha",
                  script: "מָרַנָּא תָּא",
                  pronunciation: "Ma-ra-NA-tha",
                  meaning: "\"Come, Lord\" — one of the earliest Christian prayers, found in 1 Corinthians. A two-syllable mantra of longing and invitation.",
                  tempo: .slow),
    ],

    // ── Buddhist ──────────────────────────────────────────────────────────────
    .buddhist: [
        ChantInfo(tradition: .buddhist,
                  name: "Om Mani Padme Hum",
                  script: "ॐ मणि पद्मे हूँ",
                  pronunciation: "Om · Mah-nee · Pahd-may · Hoom",
                  meaning: "\"The jewel in the lotus\" — the mantra of Avalokiteśvara, the bodhisattva of compassion. Chanted by billions across Tibet, China, and beyond.",
                  tempo: .slow),
        ChantInfo(tradition: .buddhist,
                  name: "Nam Myoho Renge Kyo",
                  script: "南無妙法蓮華経",
                  pronunciation: "Nam · Myo-ho · Ren-gay · Kyo",
                  meaning: "\"Devotion to the Mystic Law of the Lotus Sutra\" — the core chant of Nichiren Buddhism, practised by over 10 million people worldwide.",
                  tempo: .medium),
        ChantInfo(tradition: .buddhist,
                  name: "Namo Amituofo",
                  script: "南無阿彌陀佛",
                  pronunciation: "Na-mo · Ah-mee-tuo · Fwo",
                  meaning: "\"Homage to Amitabha Buddha\" — the central chant of Pure Land Buddhism, the most widely practised Buddhist school in East Asia.",
                  tempo: .medium),
    ],

    // ── Islam ─────────────────────────────────────────────────────────────────
    .islam: [
        ChantInfo(tradition: .islam,
                  name: "Subhanallah",
                  script: "سُبْحَانَ اللّٰه",
                  pronunciation: "Sub-haa-nal-laah",
                  meaning: "\"Glory be to Allah\" — said 33 times after each prayer as part of the Tasbeeh. Purifies the heart and redirects attention to divine perfection.",
                  tempo: .slow),
        ChantInfo(tradition: .islam,
                  name: "Allahu Akbar",
                  script: "اللّٰهُ أَكْبَر",
                  pronunciation: "Al-laa-hu · Ak-bar",
                  meaning: "\"Allah is Greater\" — greater than any problem, any fear, any worldly concern. The most uttered phrase in Islam, anchoring the believer in present awareness.",
                  tempo: .medium),
        ChantInfo(tradition: .islam,
                  name: "La ilaha illallah",
                  script: "لَا إِلَٰهَ إِلَّا اللّٰه",
                  pronunciation: "La ee-laa-ha · il-lal-laah",
                  meaning: "\"There is no god but Allah\" — the Shahada at the heart of Islam. Sufi masters chant this for hours as the deepest form of dhikr (remembrance).",
                  tempo: .slow),
    ],

    // ── Universal ─────────────────────────────────────────────────────────────
    .other: [
        ChantInfo(tradition: .other,
                  name: "Waheguru",
                  script: "ਵਾਹੇਗੁਰੂ",
                  pronunciation: "Waa-hey-Goo-roo",
                  meaning: "\"Wondrous Enlightener\" — the name of God in Sikhism. Chanted as a mantra (Naam Simran), it brings the mind to a state of pure wonder and gratitude.",
                  tempo: .slow),
        ChantInfo(tradition: .other,
                  name: "Hallelujah",
                  script: "הַלְלוּיָהּ · Ἀλληλούϊα · هَلِّلُويَا",
                  pronunciation: "Hal-leh-LOO-ya",
                  meaning: "\"Praise the Lord\" — a Hebrew word that crossed into Judaism, Christianity, and Islam. Perhaps the most universal sacred word on earth.",
                  tempo: .medium),
        ChantInfo(tradition: .other,
                  name: "So Hum",
                  script: "सो ऽहम्",
                  pronunciation: "So (inhale) · Hum (exhale)",
                  meaning: "\"I am that\" — a breath-synchronised mantra from the Upanishads. Every breath you take already chants it: So on the inhale, Hum on the exhale.",
                  tempo: .slow),
    ]
]
