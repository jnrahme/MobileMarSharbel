import Foundation

struct StoryChapter: Identifiable, Hashable {
    let id: Int
    let title: String
    let summary: String
    let timeline: String
    let body: String
    let prayer: String
    let reflection: String
}

struct PrayerText: Identifiable, Hashable {
    let title: String
    let body: String
    let note: String?

    var id: String {
        title
    }
}

struct CoachPlan: Identifiable, Hashable {
    let minutes: Int
    let decades: Int
    let summary: String

    var id: Int {
        minutes
    }
}

enum RosarySet: String, CaseIterable, Identifiable {
    case joyful
    case luminous
    case sorrowful
    case glorious

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .joyful:
            return "Joyful Mysteries"
        case .luminous:
            return "Luminous Mysteries"
        case .sorrowful:
            return "Sorrowful Mysteries"
        case .glorious:
            return "Glorious Mysteries"
        }
    }

    var schedule: String {
        switch self {
        case .joyful:
            return "Monday / Saturday"
        case .luminous:
            return "Thursday"
        case .sorrowful:
            return "Tuesday / Friday"
        case .glorious:
            return "Wednesday / Sunday"
        }
    }

    var summary: String {
        switch self {
        case .joyful:
            return "Pray with the hidden life of Jesus and Mary's generous yes."
        case .luminous:
            return "Walk with Christ in His public ministry and let His light reform the heart."
        case .sorrowful:
            return "Stay near Jesus in surrender, suffering, and redeeming love."
        case .glorious:
            return "Pray from resurrection hope toward mission, heaven, and perseverance."
        }
    }

    var symbolName: String {
        switch self {
        case .joyful:
            return "sun.max.fill"
        case .luminous:
            return "sparkles"
        case .sorrowful:
            return "drop.fill"
        case .glorious:
            return "crown.fill"
        }
    }

    static func recommended(on date: Date = .now, calendar: Calendar = .current) -> RosarySet {
        switch calendar.component(.weekday, from: date) {
        case 2, 7:
            return .joyful
        case 3, 6:
            return .sorrowful
        case 5:
            return .luminous
        default:
            return .glorious
        }
    }
}

struct RosaryMystery: Identifiable, Hashable {
    let key: String
    let set: RosarySet
    let number: Int
    let title: String
    let day: String
    let fruit: String
    let steps: [String]

    var id: String {
        key
    }

    var webURL: URL? {
        URL(string: "https://marsharbel.com/mysteries/\(set.rawValue)-\(number).html")
    }

    var stageTracks: [AudioTrack] {
        (1...13).compactMap(audioTrack(for:))
    }

    func audioTrack(for stage: Int) -> AudioTrack? {
        guard let url = URL(string: "https://marsharbel.com/media/rosary/\(key)/step-\(String(format: "%02d", stage)).mp3") else {
            return nil
        }

        return AudioTrack(
            url: url,
            title: title,
            subtitle: stageSubtitle(for: stage)
        )
    }

    private func stageSubtitle(for stage: Int) -> String {
        switch stage {
        case 1:
            return "Receive the mystery"
        case 2:
            return "Listen to the Word"
        case 3...12:
            return steps[stage - 3]
        case 13:
            return "Glory Be and Fatima Prayer"
        default:
            return "Guided prayer"
        }
    }
}

enum SaintCharbelLibrary {
    static let rosarySequence = [
        "Sign of the Cross",
        "Apostles' Creed",
        "Our Father",
        "Three Hail Marys",
        "Glory Be",
        "Announce the mystery",
        "Our Father",
        "Ten Hail Marys with meditation",
        "Glory Be",
        "Fatima Prayer (optional)",
        "Closing prayer and Sign of the Cross"
    ]

    static let coachPlans = [
        CoachPlan(minutes: 5, decades: 1, summary: "A short reset with one decade, gentle pacing, and one intention."),
        CoachPlan(minutes: 10, decades: 2, summary: "A practical daily rhythm that keeps prayer focused without rushing."),
        CoachPlan(minutes: 20, decades: 5, summary: "A full set of five decades when you have room to settle into prayer.")
    ]

    static let storyChapters = [
        StoryChapter(
            id: 1,
            title: "A Boy in the Mountains",
            summary: "Youssef Makhlouf grows up in Bekaa Kafra and learns to love silence, work, and prayer.",
            timeline: "May 8, 1828",
            body: """
            Youssef Antoun Makhlouf was born on May 8, 1828, in Bekaa Kafra, a mountain village in Lebanon. His life began far from fame. He knew family work, simple village routines, and the beauty of quiet places.

            Even as a child he was drawn to prayer. Saint Charbel's story matters because holiness did not begin with miracles. It began with a boy learning to love God faithfully in ordinary life.
            """,
            prayer: "Jesus, teach me to meet You in quiet moments.",
            reflection: "God often begins great stories in hidden places."
        ),
        StoryChapter(
            id: 2,
            title: "He Chose the Monastery",
            summary: "As a young man, Youssef leaves home and enters the Lebanese Maronite Order.",
            timeline: "1851 to 1853",
            body: """
            At age twenty-three, Youssef left home and entered the monastery in 1851. There he received the name Charbel and began a life shaped by obedience, poverty, chastity, work, and prayer.

            His decision cost him something real. He left comfort and familiarity because he believed God was calling him to belong to Christ more completely. That brave yes shaped everything that came after.
            """,
            prayer: "Lord, give me courage to say yes when You call.",
            reflection: "A holy life is built on faithful choices, not easy ones."
        ),
        StoryChapter(
            id: 3,
            title: "A Priest of the Altar",
            summary: "Charbel is ordained a priest and becomes known for deep reverence and hidden fidelity.",
            timeline: "July 23, 1859",
            body: """
            After studying theology, Charbel was ordained a Maronite priest on July 23, 1859. He returned to Annaya and lived with great reverence for the Eucharist, discipline in prayer, and humility in daily service.

            People noticed that he did not divide life into holy moments and ordinary moments. Prayer shaped the way he celebrated Mass, worked, listened, and served the people around him.
            """,
            prayer: "Jesus, make my heart humble and faithful.",
            reflection: "A steady interior life gives strength to every good work."
        ),
        StoryChapter(
            id: 4,
            title: "The Hermitage Years",
            summary: "Charbel moves to the hermitage at Annaya and embraces a more hidden, prayerful life.",
            timeline: "1875",
            body: """
            In 1875, Father Charbel received permission to live at the hermitage of Saints Peter and Paul near Annaya. There his life became even quieter: long prayer, fasting, manual labor, and deep union with God.

            He did not search for attention. In fact, he tried to disappear from the world's applause. Yet his hidden life became one of the strongest parts of his witness. Silence was not emptiness for him. It was a place of love.
            """,
            prayer: "Lord, help me love hidden faithfulness.",
            reflection: "Silence can become strength when it is filled with God."
        ),
        StoryChapter(
            id: 5,
            title: "His Final Mass",
            summary: "Saint Charbel collapses during Mass and dies days later after great suffering.",
            timeline: "December 16 to 24, 1898",
            body: """
            On December 16, 1898, Father Charbel suffered a stroke while celebrating Mass. He endured the final days of his life in suffering and prayer, then died on December 24, 1898.

            His last days reflected the whole pattern of his life: union with Christ, patience in suffering, and fidelity to the end. Even death did not stop his witness from spreading.
            """,
            prayer: "Jesus, stay near me in weakness and suffering.",
            reflection: "Holiness stays faithful even when the road is hard."
        ),
        StoryChapter(
            id: 6,
            title: "Hope After His Death",
            summary: "Pilgrims begin reporting signs, healings, and peace through Saint Charbel's intercession.",
            timeline: "1899 onward",
            body: """
            After his death, people began visiting his tomb and speaking about unusual signs, healings, and answers to prayer. Devotion to Father Charbel spread first through Lebanon and then far beyond it.

            The Church takes miracle claims seriously and studies them carefully. Even so, many people simply recognized that God was using this quiet monk to bring hope, healing, and conversion to others.
            """,
            prayer: "Lord, increase my trust in Your mercy and power.",
            reflection: "God can continue working through a faithful life long after it ends."
        ),
        StoryChapter(
            id: 7,
            title: "The Church Examines the Signs",
            summary: "The Church studies Charbel's life and reported miracles with patience and care.",
            timeline: "1927 to 1965",
            body: """
            As devotion grew, the Church began formal investigations into Father Charbel's life and the favors reported through his intercession. This process required patience, evidence, and careful judgment.

            He was beatified in 1965 after that careful study. The Church did not honor him because of excitement alone, but because his life, virtues, and miracles were judged worthy of belief.
            """,
            prayer: "Jesus, unite my faith with truth and honesty.",
            reflection: "Real faith is not afraid of patient examination."
        ),
        StoryChapter(
            id: 8,
            title: "Saint for the Whole Church",
            summary: "Charbel is canonized and becomes a source of hope for families across the world.",
            timeline: "October 9, 1977",
            body: """
            Pope Paul VI canonized Saint Charbel on October 9, 1977. A monk from a hidden Lebanese hermitage became a saint recognized by the whole Church.

            Today families, priests, children, and the sick still ask for his prayers. His message remains clear: love silence, stay close to the Eucharist, accept sacrifice, and trust that God works powerfully through humble lives.
            """,
            prayer: "Saint Charbel, pray that I stay close to Jesus every day.",
            reflection: "Hidden faithfulness can touch the whole world."
        )
    ]

    static let prayers = [
        PrayerText(
            title: "Sign of the Cross",
            body: """
            In the name of the Father, and of the Son, and of the Holy Spirit. Amen.
            """,
            note: nil
        ),
        PrayerText(
            title: "Apostles' Creed",
            body: """
            I believe in God, the Father almighty, Creator of heaven and earth, and in Jesus Christ, His only Son, our Lord, who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died, and was buried. He descended into hell; on the third day He rose again from the dead; He ascended into heaven, and sits at the right hand of God the Father almighty; from there He shall come to judge the living and the dead. I believe in the Holy Spirit, the holy Catholic Church, the communion of saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen.
            """,
            note: "Prayed on the crucifix before the first bead."
        ),
        PrayerText(
            title: "Our Father",
            body: """
            Our Father, who art in heaven, hallowed be Thy name. Thy kingdom come. Thy will be done on earth as it is in heaven. Give us this day our daily bread, and forgive us our trespasses, as we forgive those who trespass against us. And lead us not into temptation, but deliver us from evil. Amen.
            """,
            note: nil
        ),
        PrayerText(
            title: "Hail Mary",
            body: """
            Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen.
            """,
            note: "Prayed ten times for each decade."
        ),
        PrayerText(
            title: "Glory Be",
            body: """
            Glory be to the Father, and to the Son, and to the Holy Spirit, as it was in the beginning, is now, and ever shall be, world without end. Amen.
            """,
            note: nil
        ),
        PrayerText(
            title: "Fatima Prayer",
            body: """
            O my Jesus, forgive us our sins, save us from the fires of hell, lead all souls to heaven, especially those in most need of Thy mercy.
            """,
            note: "Optional after each decade."
        ),
        PrayerText(
            title: "Hail Holy Queen",
            body: """
            Hail, holy Queen, Mother of mercy, our life, our sweetness, and our hope. To thee do we cry, poor banished children of Eve. To thee do we send up our sighs, mourning and weeping in this valley of tears. Turn then, most gracious Advocate, thine eyes of mercy toward us; and after this our exile show unto us the blessed fruit of thy womb, Jesus. O clement, O loving, O sweet Virgin Mary.

            Pray for us, O holy Mother of God, that we may be made worthy of the promises of Christ.
            """,
            note: "Traditionally prayed after the five decades."
        ),
        PrayerText(
            title: "Concluding Rosary Prayer",
            body: """
            O God, whose only-begotten Son, by His life, death, and resurrection, has purchased for us the rewards of eternal life; grant, we beseech Thee, that by meditating on these mysteries of the most holy Rosary of the Blessed Virgin Mary, we may imitate what they contain and obtain what they promise, through the same Christ our Lord. Amen.
            """,
            note: nil
        )
    ]

    static let rosaryMysteries = [
        RosaryMystery(key: "joyful_1", set: .joyful, number: 1, title: "First Joyful Mystery - The Annunciation", day: "Monday / Saturday", fruit: "Humility and surrender to God.", steps: [
            "See Nazareth at dawn; the room is quiet and simple.",
            "Picture Mary at prayer, attentive and peaceful before God.",
            "Watch Gabriel arrive and greet her with heavenly reverence.",
            "Hear the message that she is chosen to bear the Savior.",
            "Notice her holy awe and sincere questions before consent.",
            "Contemplate the Holy Spirit overshadowing her in purity.",
            "Feel heaven waiting for her free and loving yes.",
            "Hear Mary answer: let it be done according to your word.",
            "Adore the Word made flesh in her womb.",
            "Ask for the grace to say yes to God today."
        ]),
        RosaryMystery(key: "joyful_2", set: .joyful, number: 2, title: "Second Joyful Mystery - The Visitation", day: "Monday / Saturday", fruit: "Charity and joyful service.", steps: [
            "See Mary leaving Nazareth quickly to serve Elizabeth.",
            "Walk with her through the hill country in trust.",
            "Enter Elizabeth's home and hear Mary's greeting.",
            "See John leap in Elizabeth's womb at Jesus' presence.",
            "Hear Elizabeth bless Mary and the fruit of her womb.",
            "Listen to Mary magnify the Lord in the Magnificat.",
            "Notice Mary choosing service over comfort for months.",
            "See hidden acts of care in daily household tasks.",
            "Offer this bead for someone who needs practical help.",
            "Ask for a heart that runs quickly toward charity."
        ]),
        RosaryMystery(key: "joyful_3", set: .joyful, number: 3, title: "Third Joyful Mystery - The Nativity", day: "Monday / Saturday", fruit: "Detachment and holy poverty.", steps: [
            "See Joseph and Mary arriving in Bethlehem at night.",
            "Feel the disappointment of finding no room in the inn.",
            "Enter the stable and behold the silence before birth.",
            "See Jesus born in humility and wrapped in swaddling cloths.",
            "Watch Mary place Him gently in a manger.",
            "Hear angels announce peace to shepherds nearby.",
            "See shepherds arrive with wonder and adoration.",
            "Join them in kneeling before the Infant King.",
            "Offer your poverty, weakness, and fear to Jesus.",
            "Ask for freedom from attachment to status and comfort."
        ]),
        RosaryMystery(key: "joyful_4", set: .joyful, number: 4, title: "Fourth Joyful Mystery - The Presentation", day: "Monday / Saturday", fruit: "Obedience and self-offering.", steps: [
            "See Mary and Joseph bring Jesus into the Temple.",
            "Watch them fulfill the law with humble obedience.",
            "See Simeon receive the Child with trembling joy.",
            "Hear him praise God for the promised salvation.",
            "Hear the prophecy that contradiction and sorrow are coming.",
            "Notice Mary accepting a future pierced with sacrifice.",
            "See Anna give thanks and witness to redemption.",
            "Offer your family to God as a living gift.",
            "Accept duties that feel ordinary but are holy.",
            "Ask for obedient love in daily responsibilities."
        ]),
        RosaryMystery(key: "joyful_5", set: .joyful, number: 5, title: "Fifth Joyful Mystery - Finding Jesus in the Temple", day: "Monday / Saturday", fruit: "Perseverance in seeking Christ.", steps: [
            "See Mary and Joseph begin the journey home from Jerusalem.",
            "Feel their shock when Jesus is not among the travelers.",
            "Walk with them in urgent search through crowded streets.",
            "Share their sorrow through three days of not finding Him.",
            "Enter the Temple and see Jesus teaching with wisdom.",
            "Hear Mary's loving question after anxious searching.",
            "Hear Jesus speak of His Father's house and mission.",
            "See Him return to Nazareth in filial obedience.",
            "Keep these events in your heart as Mary did.",
            "Ask for perseverance when God feels hidden."
        ]),
        RosaryMystery(key: "luminous_1", set: .luminous, number: 1, title: "First Luminous Mystery - The Baptism of the Lord", day: "Thursday", fruit: "Openness to the Holy Spirit.", steps: [
            "John is baptizing in the Jordan, proclaiming a baptism of repentance.",
            "Watch John baptize Him in humility.",
            "See the heavens open over the river.",
            "Hear the Father declare: this is my beloved Son.",
            "See the Spirit descend like a dove.",
            "Contemplate Christ sanctifying the waters of baptism.",
            "Renew your own baptismal promises interiorly.",
            "Reject sin and choose the life of grace.",
            "Pray for those preparing for baptism.",
            "Ask the Spirit to lead your next decision."
        ]),
        RosaryMystery(key: "luminous_2", set: .luminous, number: 2, title: "Second Luminous Mystery - The Wedding at Cana", day: "Thursday", fruit: "Trust in Jesus through Mary.", steps: [
            "See Jesus, Mary, and disciples at the wedding feast.",
            "Notice the quiet crisis: the wine has run out.",
            "Hear Mary present the need: they have no wine.",
            "Watch her direct the servants to trust Jesus.",
            "See stone jars filled completely with water.",
            "Watch Jesus transform water into excellent wine.",
            "See the steward amazed at the unexpected abundance.",
            "Recognize this sign awakens disciples' faith.",
            "Bring your own lack to Jesus through Mary.",
            "Ask for obedient trust: do whatever He tells you."
        ]),
        RosaryMystery(key: "luminous_3", set: .luminous, number: 3, title: "Third Luminous Mystery - Proclamation of the Kingdom", day: "Thursday", fruit: "Conversion and Christian witness.", steps: [
            "See Jesus walking through towns announcing the kingdom.",
            "Hear His call: repent and believe the Good News.",
            "Watch Him heal the sick and forgive sinners.",
            "Hear beatitudes that overturn worldly values.",
            "See Him welcome children, poor, and outsiders.",
            "Hear His command to love enemies and pray for them.",
            "Receive His invitation to radical conversion.",
            "Offer one concrete area that must change in you.",
            "Intercede for those far from faith.",
            "Ask for boldness to witness with truth and charity."
        ]),
        RosaryMystery(key: "luminous_4", set: .luminous, number: 4, title: "Fourth Luminous Mystery - The Transfiguration", day: "Thursday", fruit: "Desire for holiness and spiritual courage.", steps: [
            "See Jesus lead Peter, James, and John up the mountain.",
            "Watch His face shine with divine glory.",
            "See His garments become radiant with light.",
            "Notice Moses and Elijah speaking with Him.",
            "Hear Peter's desire to remain in that moment.",
            "Hear the Father from the cloud: listen to Him.",
            "See the disciples fall in reverent fear.",
            "Watch Jesus touch them: rise, do not be afraid.",
            "Ask to carry this light into daily trials.",
            "Pray for courage to follow Him through the cross."
        ]),
        RosaryMystery(key: "luminous_5", set: .luminous, number: 5, title: "Fifth Luminous Mystery - Institution of the Eucharist", day: "Thursday", fruit: "Love of the Eucharist and sacrificial union.", steps: [
            "Enter the Upper Room with Jesus and the apostles.",
            "See Him take bread, bless, break, and give it.",
            "Hear Him say: this is my Body, given for you.",
            "See Him offer the chalice of the new covenant.",
            "Hear: this is my Blood, poured out for many.",
            "Contemplate the first Eucharistic sacrifice.",
            "See the priesthood entrusted to serve this mystery.",
            "Offer yourself with Christ at every Mass.",
            "Ask hunger for adoration and worthy communion.",
            "Pray to become what you receive: Christ for others."
        ]),
        RosaryMystery(key: "sorrowful_1", set: .sorrowful, number: 1, title: "First Sorrowful Mystery - The Agony in the Garden", day: "Tuesday / Friday", fruit: "Conformity to the Father's will.", steps: [
            "See Jesus enter Gethsemane after the Last Supper.",
            "Watch Him ask the disciples to stay and pray.",
            "Notice His sorrow and loneliness as they fall asleep.",
            "Hear Him pray: Father, if possible, let this cup pass.",
            "Hear His surrender: not my will, but yours be done.",
            "See His sweat like drops of blood in anguish.",
            "Watch the angel strengthen Him for the Passion.",
            "Offer your fear and anxiety into His prayer.",
            "Choose fidelity in one hard duty before you.",
            "Ask for courage to obey God when it costs."
        ]),
        RosaryMystery(key: "sorrowful_2", set: .sorrowful, number: 2, title: "Second Sorrowful Mystery - The Scourging at the Pillar", day: "Tuesday / Friday", fruit: "Purity and healing from sin.", steps: [
            "See Jesus handed over, innocent yet condemned.",
            "Watch Him bound to the pillar without resistance.",
            "Hear the blows and feel the violence of sin.",
            "Contemplate His silence under humiliation and pain.",
            "Recognize that He suffers out of love for you.",
            "Bring your wounds, addictions, and shame to Him.",
            "Ask Him to purify memory, body, and imagination.",
            "Receive mercy where you have failed repeatedly.",
            "Intercede for those abused in body or spirit.",
            "Choose practical purity of eyes, speech, and action."
        ]),
        RosaryMystery(key: "sorrowful_3", set: .sorrowful, number: 3, title: "Third Sorrowful Mystery - The Crowning with Thorns", day: "Tuesday / Friday", fruit: "Moral courage and humility.", steps: [
            "See soldiers mock Jesus as a false king.",
            "Watch them press thorns into His sacred head.",
            "Hear ridicule while He remains meek and steady.",
            "See the reed in His hand and the robe of mockery.",
            "Adore the true King who reigns through love.",
            "Offer your pride and need for approval to Him.",
            "Ask grace to endure misunderstanding without bitterness.",
            "Pray for leaders to choose truth over popularity.",
            "Choose humility in one conflict today.",
            "Ask for courage to witness to Christ publicly."
        ]),
        RosaryMystery(key: "sorrowful_4", set: .sorrowful, number: 4, title: "Fourth Sorrowful Mystery - The Carrying of the Cross", day: "Tuesday / Friday", fruit: "Patience and faithful endurance.", steps: [
            "See Jesus receive the heavy cross on wounded shoulders.",
            "Walk the road to Calvary through dust and insults.",
            "Watch Him fall and rise again in obedience.",
            "See Mary meet His gaze in silent strength.",
            "Notice Simon helping to carry the wood.",
            "See Veronica offer compassion in a cruel crowd.",
            "Place your own cross beside His today.",
            "Offer this bead for someone carrying hidden suffering.",
            "Ask to carry burdens without complaining.",
            "Decide one concrete act of sacrificial love."
        ]),
        RosaryMystery(key: "sorrowful_5", set: .sorrowful, number: 5, title: "Fifth Sorrowful Mystery - The Crucifixion", day: "Tuesday / Friday", fruit: "Self-giving love and repentance.", steps: [
            "See Jesus stripped and nailed to the Cross.",
            "Hear His prayer: Father, forgive them.",
            "Watch Him entrust Mary to the beloved disciple.",
            "Hear His thirst and His abandonment in darkness.",
            "Receive His mercy given even to the repentant thief.",
            "Hear Him cry: It is finished.",
            "See Him bow His head and surrender His spirit.",
            "Stand with Mary at the foot of the Cross.",
            "Offer your sins into His redeeming blood.",
            "Ask for a love willing to be poured out."
        ]),
        RosaryMystery(key: "glorious_1", set: .glorious, number: 1, title: "First Glorious Mystery - The Resurrection", day: "Wednesday / Sunday", fruit: "Faith and new life.", steps: [
            "See dawn breaking over the sealed tomb.",
            "Feel the earth tremble as the stone is moved.",
            "Hear the angel announce that Jesus is risen.",
            "See the empty tomb and folded burial cloths.",
            "Watch Mary Magdalene run with urgent joy.",
            "See the disciples move from fear to faith.",
            "Meet the risen Christ speaking peace.",
            "Offer Him places in you that feel dead.",
            "Ask for resurrection hope in every trial.",
            "Choose to live today as someone made new."
        ]),
        RosaryMystery(key: "glorious_2", set: .glorious, number: 2, title: "Second Glorious Mystery - The Ascension", day: "Wednesday / Sunday", fruit: "Hope and heavenly desire.", steps: [
            "See Jesus gather the disciples on the mount.",
            "Hear His final command to preach the Gospel.",
            "Receive His promise: I am with you always.",
            "Watch Him bless them with raised hands.",
            "See Him ascend into glory before their eyes.",
            "Notice their worship, awe, and renewed mission.",
            "Fix your heart on heaven without escaping duty.",
            "Offer your ambitions to Christ's kingdom.",
            "Intercede for missionaries and evangelists worldwide.",
            "Ask for hope that outlasts disappointment."
        ]),
        RosaryMystery(key: "glorious_3", set: .glorious, number: 3, title: "Third Glorious Mystery - The Descent of the Holy Spirit", day: "Wednesday / Sunday", fruit: "Wisdom and apostolic boldness.", steps: [
            "See Mary and the apostles gathered in prayer.",
            "Feel the waiting of Pentecost morning.",
            "Hear the rushing wind fill the house.",
            "See tongues of fire rest on each disciple.",
            "Watch fear dissolve into holy courage.",
            "Hear praise of God in many languages.",
            "See Peter proclaim Christ with authority.",
            "Ask the Spirit to purify your motives.",
            "Offer your voice for truth and mercy.",
            "Pray for gifts of wisdom, counsel, and fortitude."
        ]),
        RosaryMystery(key: "glorious_4", set: .glorious, number: 4, title: "Fourth Glorious Mystery - The Assumption of Mary", day: "Wednesday / Sunday", fruit: "Devotion to Mary and purity of heart.", steps: [
            "Contemplate Mary at the completion of earthly life.",
            "See her taken body and soul into heavenly glory.",
            "Adore God for the triumph of grace in her.",
            "Recognize Mary as sign of our promised destiny.",
            "Ask her maternal help in your daily battle with sin.",
            "Offer your body and soul to God's service.",
            "Entrust your family to her intercession.",
            "Pray for purity in thought, word, and deed.",
            "Look toward heaven with greater longing.",
            "Ask for perseverance until final union with God."
        ]),
        RosaryMystery(key: "glorious_5", set: .glorious, number: 5, title: "Fifth Glorious Mystery - The Coronation of Mary", day: "Wednesday / Sunday", fruit: "Perseverance and trust in Mary's intercession.", steps: [
            "See Mary welcomed by the Trinity in heavenly joy.",
            "Contemplate her crowned as Queen in service and love.",
            "See saints and angels rejoice around her.",
            "Remember her queenship always points to Christ.",
            "Ask her to pray for your conversion now.",
            "Offer your fears about the future to her care.",
            "Intercede for the Church through Mary's heart.",
            "Ask for grace to finish your vocation faithfully.",
            "Choose trust over discouragement today.",
            "Pray to share eternal joy with Jesus and Mary."
        ])
    ]

    static func mysteries(for set: RosarySet) -> [RosaryMystery] {
        rosaryMysteries.filter { $0.set == set }.sorted { $0.number < $1.number }
    }
}
