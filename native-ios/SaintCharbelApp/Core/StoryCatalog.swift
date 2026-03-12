import Foundation

struct SaintStoryBook: Identifiable, Hashable {
    let id: String
    let saintName: String
    let title: String
    let subtitle: String
    let description: String
    let ageBand: String
    let coverPrompt: String
    let pages: [StoryBookPage]

    var narratedPageCount: Int {
        pages.compactMap(\.audioTrack).count
    }

    var narrationTracks: [AudioTrack] {
        pages.compactMap(\.audioTrack)
    }
}

struct StoryBookPage: Identifiable, Hashable {
    let number: Int
    let title: String
    let body: String
    let prayer: String
    let heart: String
    let imageURL: URL
    let audioTrack: AudioTrack?

    var id: Int {
        number
    }

    var pageLabel: String {
        "Page \(number)"
    }

    var isNarrated: Bool {
        audioTrack != nil
    }
}

enum StoryCatalog {
    static let saintCharbel = SaintStoryBook(
        id: "saint-charbel",
        saintName: "Saint Charbel",
        title: "The Story of Saint Charbel",
        subtitle: "Swipe through the same illustrated storybook used on marsharbel.com.",
        description: "A child-friendly Saint Charbel storybook built from the website's live storybook manifest, with matching illustrations, narration, and simple page-swipe reading.",
        ageBand: "Ages 5+",
        coverPrompt: "The same Saint Charbel storybook artwork used on the website.",
        pages: makeSaintCharbelPages()
    )

    static let all = [saintCharbel]

    nonisolated private static func makeSaintCharbelPages() -> [StoryBookPage] {
        [
            page(1, "A Child in the Mountains", "Youssef Antoun Makhlouf was born on May 8, 1828, in Bekaa Kafra, Lebanon, and was baptized a few days later according to Maronite custom. He grew up in a mountain village where faith, work, and prayer shaped daily life.", "Little prayer: Jesus, thank You for my home and my family.", "Heart Moment: God begins great stories in humble places.", "event-01.png"),
            page(2, "He Lost His Father Young", "As Pope Paul VI recalled at beatification, he lost his father very early in life. This sorrow did not harden him; it helped form a deep dependence on God.", "Little prayer: Lord, stay close when life feels heavy.", "Heart Moment: Pain can become a doorway to deeper faith.", "event-02.png"),
            page(3, "He Chose Silence and Prayer", "As a boy, he loved silent prayer and often withdrew to quiet places to be with God. From childhood, he learned that listening is part of loving.", "Little prayer: Jesus, teach me to listen in silence.", "Heart Moment: A quiet heart can hear God clearly.", "event-03.png"),
            page(4, "Witnesses Who Formed Him", "His mother taught him to pray with trust, and local monastic witnesses helped shape his imagination for holiness. From early years, he saw that a life close to God was possible.", "Little prayer: Lord, place good examples in my life.", "Heart Moment: Holy examples can change a child forever.", "birth.png"),
            page(5, "Entering Monastic Life (1851)", "At age 23, he left home in 1851 to enter the Lebanese Maronite Order. Following the pattern recalled by Pope Paul VI, his formation began at Our Lady of Mayfouk and continued at Saint Maron of Annaya.", "Little prayer: Lord, give me courage to follow You.", "Heart Moment: Holiness begins with a brave yes.", "event-04.png"),
            page(6, "Name, Vows, and a Costly Yes", "He took the name Charbel and made solemn monastic vows in 1853: obedience, poverty, and chastity. Maronite biographies recount the pain of family separation, including his mother's visit and her blessing that God would make him a saint.", "Little prayer: Jesus, make my heart faithful and pure.", "Heart Moment: True love sometimes asks for tears and sacrifice.", "vocation.png"),
            page(7, "Studies at Kfifan", "After profession, he studied theology at Saint Cyprian of Kfifan. These years formed his mind and heart in Scripture, liturgy, and monastic discipline.", "Little prayer: Lord, guide my mind and my heart.", "Heart Moment: Truth studied with humility becomes wisdom.", "event-06.png"),
            page(8, "Ordained Priest in 1859", "He was ordained a Maronite priest on July 23, 1859, and returned to Annaya. From then on, the Eucharist and adoration stood at the center of his life.", "Little prayer: Lord, help me honor You in prayer.", "Heart Moment: At the altar, his whole heart belonged to God.", "priest.png"),
            page(9, "Sixteen Years of Community Life", "From 1859 to 1875, he lived 16 years of community monastic life at Annaya. He combined contemplation and manual labor, showing that ordinary duties can be holy.", "Little prayer: Jesus, bless the work of my hands.", "Heart Moment: Ordinary work can become extraordinary love.", "event-07.png"),
            page(10, "He Ordered His Whole Day Around God", "Saint Charbel did not pray only when he felt like it. He prayed faithfully at fixed times, day after day, because love needs commitment. He let prayer guide his work, his speech, and his choices.", "Little prayer: Lord, help me be faithful, not just emotional.", "Heart Moment: Steady faithfulness makes a strong heart.", "event-09.png"),
            page(11, "Traditional Account: The Water Lamp", "According to cherished monastic tradition, when Father Charbel was an adult monk and his hermitage request was being discerned, a brother gave him a lamp filled with water instead of oil. He lit it and it burned; this was remembered as an early sign in his lifetime.", "Little prayer: Lord, increase my trust in You.", "Heart Moment: God honors humble faith, even when others mock it.", "hermit.png"),
            page(12, "Hermitage Life (From 1875)", "In 1875, he received permission to live at the hermitage of Saints Peter and Paul near Annaya. He spent about 23 years there in solitude, prayer, penance, and manual labor until his death.", "Little prayer: Lord, teach me to love a simple life.", "Heart Moment: Hidden faithfulness shines in God's eyes.", "event-08.png"),
            page(13, "He Worked the Land in Silence", "At the hermitage, he lived very simply and worked with his hands. In that hidden life, labor and prayer stayed together. Even growing food became an offering to God.", "Little prayer: Jesus, make my work an act of love.", "Heart Moment: Holiness can grow in fields, kitchens, and classrooms.", "event-20.png"),
            page(14, "Prayer, Penance, and Simplicity", "His life was marked by long prayer, silence, fasting, and self-denial. He was very serious about staying away from sin: he guarded his eyes, words, and choices, and avoided anything that pulled his heart away from God. He practiced asceticism not to be admired, but to remain pure and faithful.", "Little prayer: Jesus, keep my heart clean and close to You.", "Heart Moment: Holiness grows when we say no to sin and yes to love.", "event-09.png"),
            page(15, "He Fled Sin with Determination", "Saint Charbel knew that sin harms the heart. He guarded his senses, avoided empty talk, and examined his conscience seriously so his love for God would stay undivided.", "Little prayer: Lord, guard my eyes, words, and choices.", "Heart Moment: Purity is love that protects what is holy.", "event-09.png"),
            page(16, "A Holy Death (December 24, 1898)", "In December 1898, he became gravely ill during the Divine Liturgy and died on Christmas Eve, December 24, 1898. He finished life as he lived it: near the Eucharist, faithful to the end.", "Little prayer: Lord, keep me faithful every day.", "Heart Moment: True love for God perseveres to the end.", "event-10.png"),
            page(17, "Pilgrims and Hope", "After his death, many people came to pray at his tomb in Annaya, asking his intercession. People from different backgrounds found hope, peace, and healing.", "Little prayer: Jesus, comfort all who suffer.", "Heart Moment: One hidden life can touch the whole world.", "event-13.png"),
            page(18, "Lights Reported at His Tomb", "In the years after his burial, people in Annaya reported unusual lights around his tomb. These reports stirred many hearts to return to prayer.", "Little prayer: Jesus, shine Your light in our darkness.", "Heart Moment: God can use small signs to wake up sleeping hearts.", "event-14.png"),
            page(19, "Remarkable Signs at the Tomb", "When his tomb was opened, witnesses reported unusual signs, including notable preservation and fluid at the body. Monastery and church authorities documented these reports carefully over time.", "Little prayer: Lord, lead me to truth and deeper faith.", "Heart Moment: Signs are invitations to return to God.", "event-15.png"),
            page(20, "His Cause Was Studied Carefully", "The Church did not rush. Witnesses, records, and medical facts were examined carefully over time before declaring anything miraculous.", "Little prayer: Lord, teach me faith with honesty.", "Heart Moment: Truth and faith walk together.", "healing.png"),
            page(21, "Miracles for Beatification", "For beatification, healings attributed to his intercession were investigated and recognized by the Church after strict medical and theological review.", "Little prayer: Jesus, visit the sick with mercy.", "Heart Moment: The Lord hears cries from hospital rooms and homes.", "event-16.png"),
            page(22, "Miracle for Canonization", "For canonization, the Church recognized an additional miracle in his cause after strict review. Only then was his sainthood proclaimed for the universal Church.", "Little prayer: Lord, increase our trust in Your power.", "Heart Moment: Miracles point us to God, not to ourselves.", "event-17.png"),
            page(23, "The Healing of Nohad El Shami (1993)", "One of the most famous post-canonization testimonies is the healing of Nohad El Shami in 1993 after severe paralysis. Her testimony spread widely and moved many people to repentance and prayer.", "Little prayer: Jesus, heal body, mind, and soul.", "Heart Moment: The biggest miracle is returning to God with a changed heart.", "event-18.png"),
            page(24, "A Saint for Many Nations", "Today, people from many countries and backgrounds come to Annaya. Saint Charbel's life of prayer, sacrifice, and purity still calls people toward mercy.", "Little prayer: Jesus, unite all hearts in peace.", "Heart Moment: Holiness gathers people who would never meet otherwise.", "event-19.png"),
            page(25, "His Holiness Was Simple and Real", "He did not become a saint by one dramatic event. He became a saint by daily fidelity: prayer, work, sacrifice, humility, and love, repeated for many years.", "Little prayer: Jesus, help me be faithful in little things.", "Heart Moment: Repeated small yeses become a holy life.", "event-20.png"),
            page(26, "Beatified and Canonized", "Pope Paul VI beatified him on December 5, 1965, and canonized him on October 9, 1977. Saint Charbel's message remains clear for children and adults: pray deeply, live simply, work honestly, and trust Jesus.", "Little prayer: Saint Charbel, pray for us.", "Heart Moment: Saints are made by faithful love, one day at a time.", "event-21.png"),
            page(27, "How We Can Live Like Him Today", "You can begin now: pray each day, tell the truth, help at home, forgive quickly, and turn away from sin. Saint Charbel shows that holiness is possible for ordinary people who love God sincerely.", "Little prayer: Jesus, teach me to live with a faithful heart.", "Heart Moment: Your everyday choices can become a path to sainthood.", "event-22.png")
        ]
    }

    nonisolated private static func page(
        _ number: Int,
        _ title: String,
        _ body: String,
        _ prayer: String,
        _ heart: String,
        _ illustration: String
    ) -> StoryBookPage {
        StoryBookPage(
            number: number,
            title: title,
            body: body,
            prayer: prayer,
            heart: heart,
            imageURL: URL(string: "https://marsharbel.com/media/storybook/images/\(illustration)")!,
            audioTrack: AudioTrack(
                url: URL(string: "https://marsharbel.com/media/storybook/en-elevenlabs/page-\(padded(number)).mp3")!,
                title: "Saint Charbel Story",
                subtitle: "Narration for page \(number)"
            )
        )
    }

    nonisolated private static func padded(_ number: Int) -> String {
        String(format: "%02d", number)
    }
}
