import SwiftUI
import Combine

@main
struct AdisApp: App {
    var body: some Scene {
        WindowGroup { AdisHome() }
    }
}

private enum Palette {
    static let background = Color(red: 0.956, green: 0.925, blue: 0.867)
    static let paper = Color(red: 0.99, green: 0.974, blue: 0.945)
    static let brown = Color(red: 0.28, green: 0.19, blue: 0.14)
    static let muted = Color(red: 0.43, green: 0.32, blue: 0.24)
    static let accent = Color(red: 0.66, green: 0.41, blue: 0.26)
}

private struct Card<Content: View>: View {
    private let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Palette.paper, in: RoundedRectangle(cornerRadius: 18))
    }
}

struct AdisHome: View {
    @AppStorage("adis.language") private var language = "fi"
    @AppStorage("adis.challenge.completed") private var completedDayString = ""
    @AppStorage("adis.path.phase") private var phase = 0
    @AppStorage("adis.path.steps") private var completedStepString = ""
    @State private var selectedTab = 0
    @State private var urge: Double = 5
    @State private var situation = ""
    @State private var action = ""
    @State private var signs = ""
    @State private var pause = ""
    @State private var person = ""
    @State private var support = ""
    @State private var chosenTool = ""
    @State private var timerSeconds = 300
    @State private var timerRunning = false
    @State private var day = 1
    @State private var dailyChoice = ""
    @State private var dailyReflection = ""
    @State private var weekValue = ""
    @State private var weekAction = ""
    @State private var weekRest = ""
    @State private var weekSupport = ""
    @State private var showFaith = false
    @State private var showPrivacy = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private var english: Bool { language != "fi" }
    private func t(_ fi: String, _ en: String) -> String {
        language == "fi" ? fi : (AdisTranslations.values[language]?[en] ?? en)
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            screen(title: t("Juuri nyt", "Right now"), symbol: "heart.text.square") { nowScreen }
                .tabItem { Label(t("Juuri nyt", "Now"), systemImage: "heart.text.square") }
                .tag(0)
            screen(title: t("Oma suunnitelma", "My plan"), symbol: "square.and.pencil") { planScreen }
                .tabItem { Label(t("Suunnitelma", "Plan"), systemImage: "square.and.pencil") }
                .tag(1)
            screen(title: t("Taitopakki", "Tools"), symbol: "hand.raised") { toolsScreen }
                .tabItem { Label(t("Keinot", "Tools"), systemImage: "hand.raised") }
                .tag(2)
            screen(title: t("Oma polku", "My path"), symbol: "point.topleft.down.curvedto.point.bottomright.up") { pathScreen }
                .tabItem { Label(t("Polku", "Path"), systemImage: "point.topleft.down.curvedto.point.bottomright.up") }
                .tag(3)
            screen(title: t("Apua ja tukea", "Find support"), symbol: "person.2") { supportScreen }
                .tabItem { Label(t("Tuki", "Support"), systemImage: "person.2") }
                .tag(4)
        }
        .tint(Palette.brown)
        .onReceive(ticker) { _ in
            guard timerRunning else { return }
            if timerSeconds > 0 { timerSeconds -= 1 }
            if timerSeconds == 0 { timerRunning = false }
        }
        .sheet(isPresented: $showPrivacy) {
            NavigationStack {
                ScrollView {
                    Text(privacyText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(20)
                }
                .navigationTitle(t("Tietosuoja", "Privacy"))
                .toolbar { ToolbarItem(placement: .topBarTrailing) { Button(t("Valmis", "Done")) { showPrivacy = false } } }
            }
        }
    }

    private func screen<Content: View>(title: String, symbol: String, @ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) { content() }
                    .padding(16)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
            }
            .background(Palette.background)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Suomi", action: { language = "fi" })
                        Button("English", action: { language = "en" })
                        Button("Svenska", action: { language = "sv" })
                        Button("Norsk bokmål", action: { language = "nb" })
                        Button("Eesti", action: { language = "et" })
                    } label: {
                        Label(language.uppercased(), systemImage: "globe")
                    }
                    .accessibilityLabel(t("Valitse kieli", "Choose language"))
                }
            }
        }
    }

    private var nowScreen: some View {
        Group {
            Card {
                Text("Adis 333").font(.caption.bold()).textCase(.uppercase).foregroundStyle(Palette.accent)
                Text(t("Sinun ei tarvitse selvitä yksin.", "You don't have to face this alone."))
                    .font(.largeTitle).bold().foregroundStyle(Palette.brown)
                Text(t("Yksi hetki kerrallaan. Valitse lähin tilanne ja yksi pieni seuraava teko.", "One moment at a time. Choose what fits and one small next step."))
                Text(t("Sinä riität myös vaikeana päivänä.", "You are enough, even on a hard day."))
                    .font(.headline).foregroundStyle(Palette.accent)
            }
            Card {
                Text(t("Mitä tapahtuu juuri nyt?", "What's happening right now?"))
                    .font(.title2.bold())
                choice("urge", t("Mieliteko on vahva", "The urge is strong"), binding: $situation)
                choice("heavy", t("Olo on raskas", "I feel overwhelmed"), binding: $situation)
                choice("return", t("Käytin tai pelasin uudelleen", "I used or gambled again"), binding: $situation)
                choice("steady", t("Haluan vahvistaa arkea", "I want to support my routine"), binding: $situation)
                if situation == "urge" {
                    Text(t("Mieliteon voimakkuus", "How strong is the urge?") + " \(Int(urge))/10")
                        .font(.headline)
                    Slider(value: $urge, in: 0...10, step: 1).tint(Palette.accent)
                        .accessibilityLabel(t("Mieliteon voimakkuus", "Urge intensity"))
                }
                Text(nowMessage).padding(12).frame(maxWidth: .infinity, alignment: .leading)
                    .background(Palette.background, in: RoundedRectangle(cornerRadius: 10))
            }
            if situation == "return" { relapseCard }
            Card {
                Text(t("Seuraava pieni teko", "One small next step")).font(.title2.bold())
                actionButton("contact", t("Otan yhteyttä", "Reach out"))
                actionButton("move", t("Vaihdan paikkaa", "Change surroundings"))
                actionButton("eat", t("Syön tai juon", "Eat or drink"))
                actionButton("rest", t("Lepään", "Rest"))
                if !action.isEmpty { Text(actionMessage).foregroundStyle(Palette.muted) }
                Button(t("Puhu ihmiselle nyt", "Talk to someone now")) { selectedTab = 4 }
                    .buttonStyle(.borderedProminent).tint(Palette.brown)
            }
            emergencyCard
        }
    }

    private var nowMessage: String {
        let base: String
        switch situation {
        case "urge": base = t("Mieliteko tuntuu voimakkaalta. Päätöstä saa viivyttää.", "The urge feels strong. You can delay a decision.")
        case "heavy": base = t("Raskas olo ansaitsee tukea ja lepoa.", "A hard moment deserves support and rest.")
        case "return": base = t("Takaisku ei poista arvoasi eikä oikeuttasi apuun. Huolehdi ensin turvallisuudestasi.", "A return to use does not change your worth or right to help. Start with your safety.")
        case "steady": base = t("Voit vahvistaa yhtä sinulle tärkeää rutiinia.", "You can support one routine that matters to you.")
        default: base = t("Pysähdy hetkeksi ja valitse yksi seuraava teko.", "Pause and choose one next step.")
        }
        return situation == "urge" && Int(urge) >= 7 ? base + " " + t("Ota yhteyttä luotettavaan ihmiseen tai hoitotahoon, jos tarvitset apua.", "Contact someone you trust or your care team if you need help.") : base
    }

    private var relapseCard: some View {
        Card {
            Text(t("Retkahduksen jälkeen", "After a return to use")).font(.title2.bold())
            Text(t("Jos epäilet yliannostusta, hengitys on vaikeaa, olet sekava tai olet välittömässä vaarassa, soita 112. Kiireellisessä muussa terveyshuolessa soita 116117.", "If you suspect an overdose, have trouble breathing, feel confused or are in immediate danger, call local emergency services. Seek urgent medical advice for other concerning symptoms."))
                .foregroundStyle(Palette.brown)
            Text(t("Voit sanoa turvalliselle ihmiselle: ‘Minulle kävi vaikeasti. Voisitko olla kanssani ja auttaa hakemaan apua?’", "You could tell someone safe: ‘Something difficult happened. Could you stay with me and help me get support?’"))
            Button(t("Näytä apu ja yhteystiedot", "Show support and contacts")) { selectedTab = 4 }
                .buttonStyle(.borderedProminent).tint(Palette.brown)
            Text(t("Jos alkoholin tai rauhoittavien lääkkeiden käyttö on ollut runsasta tai pitkäaikaista, kysy terveydenhuollosta turvallinen tapa lopettaa. Sovellus ei anna vieroitusohjeita.", "If alcohol or sedative use has been heavy or prolonged, ask a clinician about stopping safely. This app does not provide withdrawal instructions."))
                .font(.footnote)
        }
    }

    private var actionMessage: String {
        switch action {
        case "contact": return t("Viesti voi olla: Minulla on vaikea hetki. Voitko jutella?", "A message could say: I'm having a hard moment. Can you talk?")
        case "move": return t("Siirry turvalliseen paikkaan, jos voit.", "Move somewhere safer if you can.")
        case "eat": return t("Huolehdi perustarpeesta ilman suorittamista.", "Take care of a basic need without pressure.")
        default: return t("Saat pitää tauon ja pyytää samalla tukea.", "You can take a break and still ask for help.")
        }
    }

    private var planScreen: some View {
        Group {
            Card {
                Text(t("Kirjoita seuraava turvallinen askel", "Write down one safer next step"))
                    .font(.title2.bold())
                Text(t("Täytä vain kohdat, joista on apua. Sinun ei tarvitse käsitellä traumamuistoja yksin.", "Fill in only what helps. You do not need to revisit trauma alone."))
            }
            Card {
                field(t("Mistä huomaan tilanteen vaikeutuvan?", "What tells me things are getting harder?"), value: $signs)
                field(t("Mikä pieni teko tuo tauon?", "What small action gives me a pause?"), value: $pause)
                field(t("Kenelle voin kertoa?", "Who can I tell?"), value: $person)
                field(t("Mikä on oma tuki- tai hoitokanava?", "Where can I find care or peer support?"), value: $support)
            }
            Card {
                Text(t("Oma tukikortti", "My support card")).font(.title2.bold())
                Text(planText).textSelection(.enabled).foregroundStyle(Palette.muted)
                ShareLink(item: planText) {
                    Label(t("Jaa tukikortti omasta valinnastasi", "Share the card if you choose"), systemImage: "square.and.arrow.up")
                }
                Button(t("Tyhjennä kentät", "Clear fields"), role: .destructive) {
                    signs = ""; pause = ""; person = ""; support = ""
                }
                Text(t("Teksti pysyy tällä laitteella tämän käyttökerran ajan, ellet itse jaa sitä.", "Your text stays on this device for this session unless you choose to share it."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
        }
    }

    private var planText: String {
        if english {
            let heading = t("", "MY SUPPORT CARD")
            let signLabel = t("", "Signs"), pauseLabel = t("", "Pause")
            let personLabel = t("", "Person"), supportLabel = t("", "Support")
            let signText = signs.isEmpty ? t("", "I'll add this later.") : signs
            let pauseText = pause.isEmpty ? t("", "I stop and consider my next step.") : pause
            let personText = person.isEmpty ? t("", "I choose someone I trust.") : person
            let supportText = support.isEmpty ? t("", "I contact care or peer support.") : support
            let closing = t("", "A hard day does not change my worth.")
            return "\(heading)\n\n\(signLabel): \(signText)\n\(pauseLabel): \(pauseText)\n\(personLabel): \(personText)\n\(supportLabel): \(supportText)\n\n\(closing)"
        }
        return "OMA TUKIKORTTI\n\nMerkit: \(signs.isEmpty ? "Kirjaan tämän myöhemmin." : signs)\nTauko: \(pause.isEmpty ? "Pysähdyn ja mietin seuraavaa tekoa." : pause)\nIhminen: \(person.isEmpty ? "Valitsen turvallisen ihmisen." : person)\nTuki: \(support.isEmpty ? "Otan yhteyttä hoitotahoon tai vertaistukeen." : support)\n\nVaikea päivä ei vie ihmisarvoani."
    }

    private var toolsScreen: some View {
        Group {
            Card {
                Text(t("Valitse keino tähän hetkeen", "Choose what fits this moment"))
                    .font(.title2.bold())
                Text(t("Keinoja saa kokeilla, muuttaa tai jättää pois.", "You can try, adapt or skip any tool."))
            }
            ForEach(toolIds, id: \.self) { id in
                Card {
                    Button {
                        chosenTool = chosenTool == id ? "" : id
                    } label: {
                        HStack { Text(toolTitle(id)).font(.headline); Spacer(); Image(systemName: chosenTool == id ? "chevron.up" : "chevron.down") }
                    }.foregroundStyle(Palette.brown)
                    if chosenTool == id { Text(toolDescription(id)).foregroundStyle(Palette.muted) }
                }
            }
            Card {
                Text(t("Ajastin ja lupa taukoon", "Timer and permission to pause")).font(.title2.bold())
                Text(String(format: "%02d:%02d", timerSeconds / 60, timerSeconds % 60))
                    .font(.system(size: 45, weight: .bold, design: .rounded)).monospacedDigit()
                HStack {
                    ForEach([5, 10, 15], id: \.self) { minutes in
                        Button("\(minutes) min") { timerRunning = false; timerSeconds = minutes * 60 }
                            .buttonStyle(.bordered)
                    }
                }
                HStack {
                    Button(timerRunning ? t("Tauko", "Pause") : t("Aloita", "Start")) {
                        if timerSeconds == 0 { timerSeconds = 300 }
                        timerRunning.toggle()
                    }.buttonStyle(.borderedProminent).tint(Palette.brown)
                    Button(t("Nollaa", "Reset")) { timerRunning = false; timerSeconds = 300 }
                        .buttonStyle(.bordered)
                }
                Text(t("Tauon saa aloittaa milloin tahansa.", "You can pause whenever you need."))
                    .font(.footnote)
            }
        }
    }

    private let toolIds = ["step", "feeling", "senses", "thought", "boundary", "count", "breath", "anchor", "future", "write"]
    private func toolTitle(_ id: String) -> String {
        switch id {
        case "step": return t("Pienin mahdollinen askel", "The smallest possible step")
        case "feeling": return t("Moi tunne", "Hello, feeling")
        case "senses": return t("Nykyhetki aistien kautta", "Use your senses")
        case "thought": return t("Lempeämpi oma puhe", "Kinder self-talk")
        case "boundary": return t("Omat rajat", "My boundaries")
        case "count": return t("Laske ennen päätöstä", "Count before deciding")
        case "breath": return t("Hengitä omaan tahtiin", "Breathe at your pace")
        case "anchor": return t("Sormiote ja turva", "A tactile anchor")
        case "future": return t("Tulevaisuuden minä", "My future self")
        default: return t("Tyhjennä mieli paperille", "Write it down")
        }
    }
    private func toolDescription(_ id: String) -> String {
        switch id {
        case "step": return t("Kysy: Mikä olisi tänään mahdollista? Lepokin kelpaa.", "Ask: What is possible today? Rest counts, too.")
        case "feeling": return t("Nimeä tunne. Sinun ei tarvitse pitää siitä tai muuttaa sitä heti.", "Name the feeling. You do not have to like or change it right away.")
        case "senses": return t("Nimeä yksi väri ja tunne alusta jalkojesi alla. Lopeta, jos se ei tunnu hyvältä.", "Name one color and feel the ground beneath your feet. Stop if it doesn't feel right.")
        case "thought": return t("Vastaa ankaraan ajatukseen uskottavasti: Olen vaikeassa tilanteessa ja saan pyytää apua.", "Answer a harsh thought with something believable: This is hard, and I can ask for help.")
        case "boundary": return t("Kysy: Mikä tässä kuuluu minulle? Saat huolehtia omasta tuestasi.", "Ask: Which part is mine? You can take care of your own support.")
        case "count": return t("Laske kahdeksaan ja kysy, tarvitsetko lisää aikaa ennen päätöstä.", "Count to eight and ask if you need more time before deciding.")
        case "breath": return t("Hengitä rauhallisesti. Pidennä uloshengitystä vain, jos se tuntuu mukavalta. Lopeta, jos huimaa.", "Breathe gently. Lengthen your exhale only if it feels comfortable. Stop if you feel dizzy.")
        case "anchor": return t("Kosketa peukalolla kahta sormea. Huomaa kosketus ja kysy, mikä auttaisi juuri nyt. Ote ei ole hoito eikä sen tarvitse toimia joka kerta.", "Touch two fingers with your thumb. Notice the sensation and ask what might help now. This is not a treatment and need not work every time.")
        case "future": return t("Kysy: Mistä huomisen minä kiittäisi tänään? Valitse yksi pieni ja turvallinen teko, myös lepo voi olla se.", "Ask: What might tomorrow's me appreciate today? Choose one small, safe action. Rest can be that action.")
        default: return t("Kirjoita muutama sana mieliteosta, tunteesta ja tuesta jota tarvitset. Voit lopettaa heti, jos kirjoittaminen kuormittaa.", "Write a few words about the urge, feeling and support you need. Stop whenever writing feels overwhelming.")
        }
    }

    private var pathScreen: some View {
        Group {
            Card {
                Text(t("Uusi suunta. Oma tahti.", "A new direction. Your pace."))
                    .font(.title2.bold()).foregroundStyle(Palette.brown)
                Text(t("Valitse vaihe, joka palvelee sinua tänään. Vuosi ja kolme vuotta ovat pitkän matkan näkymiä, eivät määräaikoja. Takaisku ei nollaa polkua.", "Choose the part that helps today. One and three years are long-term horizons, not deadlines. A setback never resets your path."))
                ForEach(0..<3, id: \.self) { n in
                    Button { phase = n } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(phaseTitle(n)).font(.headline)
                                Text(phaseSubtitle(n)).font(.footnote)
                            }
                            Spacer()
                            if phase == n { Image(systemName: "checkmark.circle.fill") }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered).tint(Palette.brown)
                    .accessibilityAddTraits(phase == n ? .isSelected : [])
                }
            }
            Card {
                Text(phaseTitle(phase)).font(.title2.bold())
                Text(phaseIntroduction(phase)).foregroundStyle(Palette.muted)
                ForEach(0..<4, id: \.self) { n in
                    let key = "\(phase)-\(n)"
                    Button {
                        var steps = completedSteps
                        if steps.contains(key) { steps.remove(key) } else { steps.insert(key) }
                        completedStepString = steps.sorted().joined(separator: ",")
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: completedSteps.contains(key) ? "checkmark.circle.fill" : "circle")
                            Text(phaseStep(phase, n)).multilineTextAlignment(.leading)
                            Spacer(minLength: 0)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.bordered).tint(Palette.brown)
                    .accessibilityLabel(phaseStep(phase, n) + ". " + (completedSteps.contains(key) ? t("Merkitty", "Marked") : t("Ei merkitty", "Not marked")))
                }
                Text(t("Merkintä tarkoittaa ‘kokeilin’. Voit poistaa sen milloin tahansa. Sinun ei tarvitse tehdä tehtäviä järjestyksessä.", "A mark means ‘I tried it’. Remove it whenever you wish. The steps have no required order."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button(t("Poista polun merkinnät", "Clear path marks"), role: .destructive) { completedStepString = "" }
                    .font(.footnote)
            }
            Card {
                Text(t("Oma viikko", "My week")).font(.title2.bold())
                Text(t("Kirjoita vain sen verran kuin auttaa. Viikkoa saa muuttaa ja vaikea päivä ei nollaa polkua.", "Write only what helps. You can change the plan and a hard day never resets your path."))
                field(t("Mikä on tärkeää?", "What matters?"), value: $weekValue)
                field(t("Yksi pieni teko", "One small action"), value: $weekAction)
                field(t("Lepo tai palautuminen", "Rest or recovery"), value: $weekRest)
                field(t("Keneltä voin pyytää tukea?", "Who can I ask for support?"), value: $weekSupport)
                Text(t("Viikon teksti säilyy vain tämän käyttökerran ajan. Se katoaa, kun sovellus suljetaan.", "The weekly text stays in memory for this session and disappears when the app closes."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button(t("Tyhjennä viikon tekstit", "Clear weekly text"), role: .destructive) {
                    weekValue = ""; weekAction = ""; weekRest = ""; weekSupport = ""
                }
            }
            rhythmScreen
        }
    }

    private var completedSteps: Set<String> { Set(completedStepString.split(separator: ",").map(String.init)) }

    private func phaseTitle(_ n: Int) -> String {
        switch n {
        case 0: return t("1 · Alkumetreillä", "1 · First steps")
        case 1: return t("2 · Uusi elämä", "2 · Building a new life")
        default: return t("3 · Oma uusi tavoite", "3 · My next direction")
        }
    }
    private func phaseSubtitle(_ n: Int) -> String {
        switch n {
        case 0: return t("Valitse turvallinen seuraava askel", "Choose a safer next step")
        case 1: return t("Vuoden aikana: rakenna arkea", "Over a year: build your everyday life")
        default: return t("Kolmen vuoden näkymä: löydä merkitystä", "A three-year horizon: find meaning")
        }
    }
    private func phaseIntroduction(_ n: Int) -> String {
        switch n {
        case 0: return t("Yhteys, turva ja yksi teko riittävät alkuun. Avun saa valita heti.", "Connection, safety and one action are enough to begin. Help is available now.")
        case 1: return t("Rakenna arkea, johon on hyvä palata. Lepo ja tuki kuuluvat joka viikkoon.", "Build an everyday life worth returning to. Rest and support belong in every week.")
        default: return t("Toipumisen rinnalle voi tulla uusia arvoja, ihmissuhteita ja tavoitteita. Vaikea päivä on sallittu.", "New values, relationships and goals can grow alongside recovery. Hard days remain allowed.")
        }
    }
    private func phaseStep(_ n: Int, _ step: Int) -> String {
        let fi = [
            ["Nimeä yksi turvallinen ihminen tai palvelu.", "Valitse paikka, jossa on turvallisempaa olla.", "Kirjoita yksi syy, miksi uusi suunta on sinulle tärkeä.", "Tee yksi pieni teko tai pyydä apua sen tekemiseen."],
            ["Valitse ensi viikolle yksi tukikontakti.", "Huomaa yksi arjen asia: uni, ruoka tai lepo.", "Valitse mielekästä tekemistä, joka ei vaadi suorittamista.", "Tunnista yksi tilanne, jossa tarvitset enemmän tukea."],
            ["Kirjoita yksi arvo, jota haluat vaalia.", "Valitse ihmissuhde, harrastus, opiskelu tai työ, jota haluat rakentaa.", "Päätä yksi pieni askel sitä kohti.", "Tarkista rajasi ja se, kehen voit tukeutua jatkossakin."]
        ]
        let en = [
            ["Name one safe person or service.", "Choose a place where you would feel safer.", "Write one reason this new direction matters to you.", "Take one small action or ask for help with it."],
            ["Choose one support contact for next week.", "Notice one everyday need: sleep, food or rest.", "Choose an enjoyable activity without pressure.", "Name one situation where you need more support."],
            ["Write down one value you want to live by.", "Choose a relationship, hobby, study or work goal to nurture.", "Pick one small step toward it.", "Check your limits and who can support you later, too."]
        ]
        return t(fi[n][step], en[n][step])
    }

    private var rhythmScreen: some View {
        Group {
            Card {
                Text(t("Rauhassa hyvä tulee", "Take your time")).font(.title2.bold())
                Text(t("Ruoka, uni, sopiva liike ja yhteys toisiin voivat tukea toipumista. Ne eivät ole suorituslista.", "Food, sleep, gentle movement and connection can support recovery. They are not a performance checklist."))
            }
            Card {
                Text(t("Vapaaehtoinen 21 päivän kokeilu", "An optional 21-day experiment")).font(.title2.bold())
                Picker(t("Päivä", "Day"), selection: $day) {
                    ForEach(1...21, id: \.self) { n in Text(t("Päivä ", "Day ") + String(n)).tag(n) }
                }
                .pickerStyle(.menu)
                choice("read", t("Luen hetken", "Read for a moment"), binding: $dailyChoice)
                choice("write", t("Kirjoitan yhden hyvän asian", "Write one good thing"), binding: $dailyChoice)
                choice("contact", t("Otan yhteyttä", "Reach out"), binding: $dailyChoice)
                choice("rest", t("Lepään", "Rest"), binding: $dailyChoice)
                Text(t("Väliin jäänyt päivä ei nollaa mitään.", "Missing a day resets nothing."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button(t("Merkitse tämä päivä tehdyksi", "Mark this day complete")) {
                    var days = completedDays
                    days.insert(day)
                    completedDayString = days.sorted().map { String($0) }.joined(separator: ",")
                }
                .buttonStyle(.borderedProminent).tint(Palette.brown)
                .disabled(dailyChoice.isEmpty)
                Text(t("Merkittyjä päiviä: ", "Days marked: ") + String(completedDays.count) + "/21")
                    .font(.footnote.bold())
                Button(t("Tyhjennä kokeilun merkinnät", "Clear challenge progress"), role: .destructive) {
                    completedDayString = ""
                    dailyChoice = ""
                }
                .font(.footnote)
            }
            Card {
                Text(t("Kirjoita tai vain huomaa", "Write or simply notice")).font(.title2.bold())
                Text(t("Mikä tunne tai mieliteko nousi? Mitä tarvitsen seuraavaksi? Menneisyyttä ei tarvitse käydä läpi yksin.", "What feeling or urge showed up? What do I need next? You do not need to work through the past alone."))
                TextField(t("Halutessasi muutama sana", "A few words, if you like"), text: $dailyReflection, axis: .vertical)
                    .lineLimit(3...6).textFieldStyle(.roundedBorder)
                Button(t("Tyhjennä kirjoitus", "Clear writing"), role: .destructive) { dailyReflection = "" }
                Text(t("Tätä tekstiä ei tallenneta. Se katoaa, kun sovellus suljetaan.", "This text is not saved. It disappears when the app is closed."))
                    .font(.footnote).foregroundStyle(Palette.muted)
            }
            Card {
                Text(t("Jos käytit tai pelasit uudelleen", "If you used or gambled again")).font(.title2.bold())
                Text(t("Huolehdi ensin turvallisuudesta ja ota yhteyttä tukeen. Retkahdus ei määritä arvoasi.", "First take care of your safety and reconnect with support. A return to use does not define your worth."))
            }
            Card {
                Text(t("Kun rahapelaaminen houkuttelee", "When gambling calls")).font(.title2.bold())
                Text(t("Siirrä pelaamispäätöstä, sulje pelisivu ja siirry pois maksamisen ääreltä. Pyydä apua rahojen ja pelitilien rajaamiseen.", "Delay the decision, close the gambling site and step away from payment methods. Ask for help setting limits on money and gambling accounts."))
                if english {
                    resource(t("Gamblers Anonymous meetings", "Gamblers Anonymous meetings"), "https://gamblersanonymous.org/international-meetings/")
                } else {
                    resource("Peluuri: tukea peliongelmaan", "https://www.peluuri.fi/")
                }
            }
            Card {
                Toggle(t("Näytä vapaaehtoinen uskon muistutus", "Show an optional faith reminder"), isOn: $showFaith)
                if showFaith { Text(t("Saan pyytää apua, levätä ja kulkea tämän päivän askel kerrallaan.", "I can ask for help, rest and take this day one step at a time.")) }
            }
        }
    }

    private var completedDays: Set<Int> {
        Set(completedDayString.split(separator: ",").compactMap { Int($0) }.filter { (1...21).contains($0) })
    }

    private var supportScreen: some View {
        Group {
            emergencyCard
            Card {
                Text(t("Apua riippuvuuksiin", "Support for recovery")).font(.title2.bold())
                if english {
                    resource(t("Substance-use support by country", "Substance-use support by country"), "https://findahelpline.com/topics/substance-use")
                    resource(t("Gambling support by country", "Gambling support by country"), "https://findahelpline.com/topics/gambling")
                    resource(t("NA meeting search", "NA meeting search"), "https://na.org/MeetingSearch/")
                    resource(t("Gamblers Anonymous meetings", "Gamblers Anonymous meetings"), "https://gamblersanonymous.org/international-meetings/")
                    resource(t("Find a Helpline by country", "Find a Helpline by country"), "https://findahelpline.com/")
                } else {
                    Link("EHYT Päihdeneuvonta 0800 900 45", destination: URL(string: "tel:080090045")!)
                    Link("Peluuri 0800 100 101 · ma–pe 12–18", destination: URL(string: "tel:0800100101")!)
                    resource("EHYT Päihdeneuvonta", "https://ehyt.fi/selkokieli/mista-saa-apua/")
                    resource("NA-kokoukset Suomessa", "https://www.nasuomi.org/kokoukset/")
                    resource("Päihdelinkki", "https://paihdelinkki.fi/")
                    resource("Peluuri", "https://www.peluuri.fi/")
                    resource("MIELI Kriisipuhelin", "https://mieli.fi/tukea-ja-apua/kriisipuhelin/")
                }
            }
            Card {
                Text(t("Mitä Adis tekee?", "What does Adis do?")).font(.title2.bold())
                Text(t("Adis ei diagnosoi, hoida vieroitusoireita eikä korvaa ammatillista hoitoa. Jos lopettaminen aiheuttaa voimakkaita oireita, kysy terveydenhuollosta turvallinen tapa edetä.", "Adis does not diagnose, treat withdrawal or replace professional care. If stopping a substance brings strong symptoms, ask a healthcare professional how to proceed safely."))
                Text(t("Traumamuistoja ei tarvitse käsitellä yksin. Usko, anteeksianto ja kiitollisuus ovat vapaaehtoisia.", "You do not need to revisit trauma alone. Faith, forgiveness and gratitude are optional."))
                Text(t("Sovellus on maksuton. Se ei pyydä käyttäjätiliä eikä lähetä kirjoittamaasi tukikorttia palvelimelle.", "The app is free. It needs no account and does not send your support card to a server."))
                    .font(.footnote).foregroundStyle(Palette.muted)
                Button(t("Lue tietosuojaseloste", "Read privacy policy")) { showPrivacy = true }
                Button(t("Poista kaikki omat merkinnät", "Clear all my marks"), role: .destructive) {
                    phase = 0; completedStepString = ""; completedDayString = ""
                    signs = ""; pause = ""; person = ""; support = ""; dailyReflection = ""
                    weekValue = ""; weekAction = ""; weekRest = ""; weekSupport = ""
                }
            }
        }
    }

    private var privacyText: String {
        if let text = AdisTranslations.privacy[language] { return text }
        if english {
            return "Updated 1 October 2026\n\nAdis does not require an account. Text in the support card, weekly plan and optional reflection remains in the app's memory for the current session and is not sent to an Adis server. Language preference, chosen path, path marks and completed day numbers in the optional 21-day experiment are stored locally on your device. You can clear these marks in the app. Adis uses no analytics or advertising networks. If you open the iOS share sheet, you choose where to send your support card. External support links are governed by those services' own privacy practices. Adis has no profiles, tracking or payments. Privacy inquiries: hyvinvalmennus@outlook.com."
        }
        return "Päivitetty 1.10.2026\n\nAdis ei vaadi käyttäjätiliä. Tukikortin, Oma viikon ja vapaaehtoisen kirjoituksen teksti säilyy sovelluksen muistissa käyttökerran ajan eikä sitä lähetetä Adis-palvelimelle. Kielen valinta, valittu polku, polun merkinnät ja vapaaehtoiseen 21 päivän kokeiluun merkityt päivät tallentuvat laitteen paikallisiin asetuksiin. Merkinnät voi poistaa sovelluksessa. Sovellus ei käytä analytiikkaa tai mainosverkkoja. Jos avaat iOS:n Jaa-toiminnon, päätät itse, minne tukikortti lähetetään. Ulkoiset tukilinkit toimivat kyseisten palvelujen omien tietosuojakäytäntöjen mukaan. Adiksessa ei ole profiileja, seurantaa tai maksuja. Tietosuoja-asiat: hyvinvalmennus@outlook.com."
    }

    private var emergencyCard: some View {
        Card {
            Text(t("Jos tarvitset ihmistä", "When you need a person")).font(.title2.bold())
            Text(t("Oma hoitotaho, vertainen tai luotettava ihminen voi auttaa seuraavassa päätöksessä.", "A care professional, peer or trusted person can help with the next decision."))
            if english {
                resource(t("Find a helpline near you", "Find a helpline near you"), "https://findahelpline.com/")
                Text(t("If someone is in immediate danger, contact your local emergency services.", "If someone is in immediate danger, contact your local emergency services.")).font(.footnote.bold())
            } else {
                Link("MIELI Kriisipuhelin 09 2525 0111", destination: URL(string: "tel:0925250111")!)
                Link("Päivystysapu 116117", destination: URL(string: "tel:116117")!)
                Link("Välitön vaara: 112", destination: URL(string: "tel:112")!)
                    .font(.headline)
            }
        }
    }

    private func resource(_ label: String, _ address: String) -> some View {
        Link(destination: URL(string: address)!) {
            Label(label, systemImage: "arrow.up.right.square")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    private func actionButton(_ id: String, _ label: String) -> some View {
        Button(label) { action = id }.buttonStyle(.bordered).tint(Palette.brown)
    }
    private func choice(_ id: String, _ label: String, binding: Binding<String>) -> some View {
        Button { binding.wrappedValue = id } label: {
            HStack {
                Text(label)
                Spacer()
                if binding.wrappedValue == id { Image(systemName: "checkmark.circle.fill") }
            }
        }
        .buttonStyle(.bordered)
        .tint(Palette.brown)
        .accessibilityAddTraits(binding.wrappedValue == id ? .isSelected : [])
    }
    private func field(_ title: String, value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.headline)
            TextField(title, text: value, axis: .vertical)
                .lineLimit(2...4)
                .textFieldStyle(.roundedBorder)
        }
    }
}

private enum AdisTranslations {
    static let values: [String: [String: String]] = [
        "sv": [
            "Right now": "Just nu",
            "Now": "Nu",
            "My plan": "Min plan",
            "Plan": "Plan",
            "Tools": "Verktyg",
            "My path": "Min väg",
            "Path": "Väg",
            "Find support": "Hitta stöd",
            "Support": "Stöd",
            "Privacy": "Integritet",
            "Done": "Klart",
            "Choose language": "Välj språk",
            "You don't have to face this alone.": "Du behöver inte klara det här ensam.",
            "One moment at a time. Choose what fits and one small next step.": "En stund i taget. Välj det som passar och ett litet nästa steg.",
            "You are enough, even on a hard day.": "Du duger, även en svår dag.",
            "What's happening right now?": "Vad händer just nu?",
            "The urge is strong": "Suget är starkt",
            "I feel overwhelmed": "Jag känner mig överväldigad",
            "I used or gambled again": "Jag använde eller spelade om pengar igen",
            "I want to support my routine": "Jag vill stärka min vardag",
            "How strong is the urge?": "Hur starkt är suget?",
            "Urge intensity": "Sugets styrka",
            "One small next step": "Ett litet nästa steg",
            "Reach out": "Ta kontakt",
            "Change surroundings": "Byt miljö",
            "Eat or drink": "Ät eller drick",
            "Rest": "Vila",
            "Talk to someone now": "Prata med någon nu",
            "The urge feels strong. You can delay a decision.": "Suget känns starkt. Du får skjuta upp ett beslut.",
            "A hard moment deserves support and rest.": "En svår stund förtjänar stöd och vila.",
            "A return to use does not change your worth or right to help. Start with your safety.": "Att börja använda igen förändrar inte ditt värde eller din rätt till hjälp. Börja med din säkerhet.",
            "You can support one routine that matters to you.": "Du kan stärka en rutin som är viktig för dig.",
            "Pause and choose one next step.": "Stanna upp och välj ett nästa steg.",
            "Contact someone you trust or your care team if you need help.": "Kontakta någon du litar på eller din vårdkontakt om du behöver hjälp.",
            "After a return to use": "Efter att du börjat använda igen",
            "If you suspect an overdose, have trouble breathing, feel confused or are in immediate danger, call local emergency services. Seek urgent medical advice for other concerning symptoms.": "Om du misstänker en överdos, har svårt att andas, känner dig förvirrad eller är i omedelbar fara, kontakta den lokala larmcentralen. Sök akut medicinsk rådgivning vid andra oroande symtom.",
            "You could tell someone safe: ‘Something difficult happened. Could you stay with me and help me get support?’": "Du kan säga till någon du känner dig trygg med: ”Något svårt har hänt. Kan du vara med mig och hjälpa mig att få stöd?”",
            "Show support and contacts": "Visa stöd och kontaktuppgifter",
            "If alcohol or sedative use has been heavy or prolonged, ask a clinician about stopping safely. This app does not provide withdrawal instructions.": "Om du har använt mycket alkohol eller lugnande läkemedel, eller använt dem under lång tid, fråga vårdpersonal hur du kan sluta på ett säkert sätt. Appen ger inga instruktioner för avgiftning.",
            "A message could say: I'm having a hard moment. Can you talk?": "Ett meddelande kan vara: Jag har det svårt just nu. Kan vi prata?",
            "Move somewhere safer if you can.": "Gå till en tryggare plats om du kan.",
            "Take care of a basic need without pressure.": "Ta hand om ett grundläggande behov utan press.",
            "You can take a break and still ask for help.": "Du får ta en paus och samtidigt be om stöd.",
            "Write down one safer next step": "Skriv ner ett tryggare nästa steg",
            "Fill in only what helps. You do not need to revisit trauma alone.": "Fyll bara i det som hjälper. Du behöver inte återvända till traumaminnen ensam.",
            "What tells me things are getting harder?": "Hur märker jag att det blir svårare?",
            "What small action gives me a pause?": "Vilken liten handling ger mig en paus?",
            "Who can I tell?": "Vem kan jag berätta för?",
            "Where can I find care or peer support?": "Var kan jag hitta vård eller kamratstöd?",
            "My support card": "Mitt stödkort",
            "Share the card if you choose": "Dela kortet om du vill",
            "Clear fields": "Töm fälten",
            "Your text stays on this device for this session unless you choose to share it.": "Din text finns på den här enheten under denna session, om du inte själv väljer att dela den.",
            "Choose what fits this moment": "Välj det som passar just nu",
            "You can try, adapt or skip any tool.": "Du kan prova, anpassa eller hoppa över alla övningar.",
            "Timer and permission to pause": "Timer och tillåtelse att ta en paus",
            "Pause": "Paus",
            "Start": "Starta",
            "Reset": "Återställ",
            "You can pause whenever you need.": "Du får ta en paus när du behöver.",
            "The smallest possible step": "Minsta möjliga steg",
            "Hello, feeling": "Hej, känsla",
            "Use your senses": "Använd dina sinnen",
            "Kinder self-talk": "Vänligare samtal med dig själv",
            "My boundaries": "Mina gränser",
            "Count before deciding": "Räkna innan du bestämmer dig",
            "Breathe at your pace": "Andas i din egen takt",
            "A tactile anchor": "Ett ankare genom beröring",
            "My future self": "Mitt framtida jag",
            "Write it down": "Skriv ner det",
            "Ask: What is possible today? Rest counts, too.": "Fråga: Vad är möjligt idag? Vila räknas också.",
            "Name the feeling. You do not have to like or change it right away.": "Sätt ord på känslan. Du behöver inte tycka om den eller förändra den direkt.",
            "Name one color and feel the ground beneath your feet. Stop if it doesn't feel right.": "Nämn en färg och känn marken under fötterna. Sluta om det inte känns bra.",
            "Answer a harsh thought with something believable: This is hard, and I can ask for help.": "Svara på en hård tanke med något trovärdigt: Det här är svårt, och jag kan be om hjälp.",
            "Ask: Which part is mine? You can take care of your own support.": "Fråga: Vad är mitt ansvar? Du får ta hand om ditt eget behov av stöd.",
            "Count to eight and ask if you need more time before deciding.": "Räkna till åtta och fråga om du behöver mer tid innan du bestämmer dig.",
            "Breathe gently. Lengthen your exhale only if it feels comfortable. Stop if you feel dizzy.": "Andas lugnt. Förläng utandningen bara om det känns bekvämt. Sluta om du blir yr.",
            "Touch two fingers with your thumb. Notice the sensation and ask what might help now. This is not a treatment and need not work every time.": "Rör vid två fingrar med tummen. Lägg märke till beröringen och fråga vad som kan hjälpa nu. Det här är ingen behandling och behöver inte fungera varje gång.",
            "Ask: What might tomorrow's me appreciate today? Choose one small, safe action. Rest can be that action.": "Fråga: Vad skulle mitt morgondagsjag kunna uppskatta idag? Välj en liten, trygg handling. Vila kan vara den handlingen.",
            "Write a few words about the urge, feeling and support you need. Stop whenever writing feels overwhelming.": "Skriv några ord om suget, känslan och stödet du behöver. Sluta när skrivandet känns överväldigande.",
            "A new direction. Your pace.": "En ny riktning. Din takt.",
            "Choose the part that helps today. One and three years are long-term horizons, not deadlines. A setback never resets your path.": "Välj den del som hjälper idag. Ett och tre år är långsiktiga perspektiv, inte tidsfrister. Ett bakslag nollställer aldrig din väg.",
            "Marked": "Markerat",
            "Not marked": "Inte markerat",
            "A mark means ‘I tried it’. Remove it whenever you wish. The steps have no required order.": "En markering betyder ”jag provade”. Ta bort den när du vill. Stegen har ingen bestämd ordning.",
            "Clear path marks": "Rensa markeringarna på min väg",
            "My week": "Min vecka",
            "Write only what helps. You can change the plan and a hard day never resets your path.": "Skriv bara det som hjälper. Du får ändra planen, och en svår dag nollställer aldrig din väg.",
            "What matters?": "Vad är viktigt?",
            "One small action": "En liten handling",
            "Rest or recovery": "Vila eller återhämtning",
            "Who can I ask for support?": "Vem kan jag be om stöd?",
            "The weekly text stays in memory for this session and disappears when the app closes.": "Veckans text finns bara i minnet under denna session och försvinner när appen stängs.",
            "Clear weekly text": "Rensa veckans text",
            "1 · First steps": "1 · De första stegen",
            "2 · Building a new life": "2 · Bygga ett nytt liv",
            "3 · My next direction": "3 · Min nästa riktning",
            "Choose a safer next step": "Välj ett tryggare nästa steg",
            "Over a year: build your everyday life": "Under ett år: bygg din vardag",
            "A three-year horizon: find meaning": "Ett treårsperspektiv: hitta mening",
            "Connection, safety and one action are enough to begin. Help is available now.": "Kontakt, trygghet och en handling räcker för att börja. Du får be om hjälp direkt.",
            "Build an everyday life worth returning to. Rest and support belong in every week.": "Bygg en vardag som är värd att återvända till. Vila och stöd hör till varje vecka.",
            "New values, relationships and goals can grow alongside recovery. Hard days remain allowed.": "Nya värderingar, relationer och mål kan växa fram under återhämtningen. Svåra dagar är fortfarande tillåtna.",
            "Take your time": "Ta den tid du behöver",
            "Food, sleep, gentle movement and connection can support recovery. They are not a performance checklist.": "Mat, sömn, varsam rörelse och kontakt med andra kan stödja återhämtningen. Det är ingen prestationslista.",
            "An optional 21-day experiment": "Ett frivilligt 21-dagarsförsök",
            "Day": "Dag",
            "Day ": "Dag ",
            "Read for a moment": "Läs en stund",
            "Write one good thing": "Skriv ner en bra sak",
            "Missing a day resets nothing.": "En missad dag nollställer ingenting.",
            "Mark this day complete": "Markera den här dagen som klar",
            "Days marked: ": "Markerade dagar: ",
            "Clear challenge progress": "Rensa försöksmarkeringarna",
            "Write or simply notice": "Skriv eller lägg bara märke till det",
            "What feeling or urge showed up? What do I need next? You do not need to work through the past alone.": "Vilken känsla eller vilket sug dök upp? Vad behöver jag härnäst? Du behöver inte bearbeta det förflutna ensam.",
            "A few words, if you like": "Några ord, om du vill",
            "Clear writing": "Rensa texten",
            "This text is not saved. It disappears when the app is closed.": "Den här texten sparas inte. Den försvinner när appen stängs.",
            "If you used or gambled again": "Om du använde eller spelade om pengar igen",
            "First take care of your safety and reconnect with support. A return to use does not define your worth.": "Ta först hand om din säkerhet och återknyt kontakten med stöd. Att börja använda igen avgör inte ditt värde.",
            "When gambling calls": "När spel om pengar lockar",
            "Delay the decision, close the gambling site and step away from payment methods. Ask for help setting limits on money and gambling accounts.": "Skjut upp spelbeslutet, stäng spelsidan och lämna betalningsmöjligheterna. Be om hjälp att sätta gränser för pengar och spelkonton.",
            "Show an optional faith reminder": "Visa en frivillig påminnelse om tro",
            "I can ask for help, rest and take this day one step at a time.": "Jag får be om hjälp, vila och ta en dag i taget, ett steg i sänder.",
            "Support for recovery": "Stöd för återhämtning",
            "What does Adis do?": "Vad gör Adis?",
            "Adis does not diagnose, treat withdrawal or replace professional care. If stopping a substance brings strong symptoms, ask a healthcare professional how to proceed safely.": "Adis ställer inte diagnoser, behandlar inte abstinens och ersätter inte professionell vård. Om du får kraftiga symtom när du slutar med ett ämne, fråga vårdpersonal hur du kan gå vidare på ett säkert sätt.",
            "You do not need to revisit trauma alone. Faith, forgiveness and gratitude are optional.": "Du behöver inte återvända till trauma ensam. Tro, förlåtelse och tacksamhet är frivilliga.",
            "The app is free. It needs no account and does not send your support card to a server.": "Appen är gratis. Inget konto behövs, och ditt stödkort skickas inte till en server.",
            "Read privacy policy": "Läs integritetspolicyn",
            "Clear all my marks": "Rensa alla mina markeringar",
            "When you need a person": "När du behöver en människa",
            "A care professional, peer or trusted person can help with the next decision.": "Vårdpersonal, en person med liknande erfarenheter eller någon du litar på kan hjälpa dig med nästa beslut.",
            "Name one safe person or service.": "Nämn en trygg person eller stödtjänst.",
            "Choose a place where you would feel safer.": "Välj en plats där du skulle känna dig tryggare.",
            "Write one reason this new direction matters to you.": "Skriv en anledning till att den nya riktningen är viktig för dig.",
            "Take one small action or ask for help with it.": "Ta ett litet steg eller be om hjälp med det.",
            "Choose one support contact for next week.": "Välj en stödkontakt för nästa vecka.",
            "Notice one everyday need: sleep, food or rest.": "Lägg märke till ett vardagsbehov: sömn, mat eller vila.",
            "Choose an enjoyable activity without pressure.": "Välj något du tycker om utan prestationskrav.",
            "Name one situation where you need more support.": "Nämn en situation där du behöver mer stöd.",
            "Write down one value you want to live by.": "Skriv ner ett värde du vill leva efter.",
            "Choose a relationship, hobby, study or work goal to nurture.": "Välj en relation, hobby eller ett studie- eller arbetsmål som du vill utveckla.",
            "Pick one small step toward it.": "Välj ett litet steg mot det.",
            "Check your limits and who can support you later, too.": "Se över dina gränser och vem som kan stödja dig även framöver.",
            "MY SUPPORT CARD": "MITT STÖDKORT",
            "Signs": "Tecken",
            "Person": "Person",
            "I'll add this later.": "Jag lägger till det senare.",
            "I stop and consider my next step.": "Jag stannar upp och tänker på mitt nästa steg.",
            "I choose someone I trust.": "Jag väljer någon jag litar på.",
            "I contact care or peer support.": "Jag kontaktar vården eller kamratstöd.",
            "A hard day does not change my worth.": "En svår dag förändrar inte mitt värde.",
            "Substance-use support by country": "Stöd vid substansbruk efter land",
            "Gambling support by country": "Stöd vid spelproblem efter land",
            "NA meeting search": "Sök NA-möten",
            "Gamblers Anonymous meetings": "Gamblers Anonymous-möten",
            "Find a Helpline by country": "Hitta en stödlinje efter land",
            "Find a helpline near you": "Hitta en stödlinje nära dig",
            "If someone is in immediate danger, contact your local emergency services.": "Om någon är i omedelbar fara, kontakta den lokala larmcentralen.",
        ],
        "nb": [
            "Right now": "Akkurat nå",
            "Now": "Nå",
            "My plan": "Min plan",
            "Plan": "Plan",
            "Tools": "Verktøy",
            "My path": "Min vei",
            "Path": "Vei",
            "Find support": "Finn støtte",
            "Support": "Støtte",
            "Privacy": "Personvern",
            "Done": "Ferdig",
            "Choose language": "Velg språk",
            "You don't have to face this alone.": "Du trenger ikke å klare dette alene.",
            "One moment at a time. Choose what fits and one small next step.": "Ett øyeblikk om gangen. Velg det som passer, og ett lite neste steg.",
            "You are enough, even on a hard day.": "Du er god nok, også på en vanskelig dag.",
            "What's happening right now?": "Hva skjer akkurat nå?",
            "The urge is strong": "Suget er sterkt",
            "I feel overwhelmed": "Jeg føler meg overveldet",
            "I used or gambled again": "Jeg brukte rusmidler eller spilte om penger igjen",
            "I want to support my routine": "Jeg vil styrke hverdagen min",
            "How strong is the urge?": "Hvor sterkt er suget?",
            "Urge intensity": "Styrken på suget",
            "One small next step": "Ett lite neste steg",
            "Reach out": "Ta kontakt",
            "Change surroundings": "Bytt omgivelser",
            "Eat or drink": "Spis eller drikk",
            "Rest": "Hvil",
            "Talk to someone now": "Snakk med noen nå",
            "The urge feels strong. You can delay a decision.": "Suget føles sterkt. Du kan utsette en beslutning.",
            "A hard moment deserves support and rest.": "En vanskelig stund fortjener støtte og hvile.",
            "A return to use does not change your worth or right to help. Start with your safety.": "Å begynne å bruke rusmidler igjen endrer ikke verdien din eller retten til hjelp. Begynn med sikkerheten din.",
            "You can support one routine that matters to you.": "Du kan styrke én rutine som betyr noe for deg.",
            "Pause and choose one next step.": "Stopp opp og velg ett neste steg.",
            "Contact someone you trust or your care team if you need help.": "Kontakt noen du stoler på eller behandleren din hvis du trenger hjelp.",
            "After a return to use": "Etter at du har begynt å bruke rusmidler igjen",
            "If you suspect an overdose, have trouble breathing, feel confused or are in immediate danger, call local emergency services. Seek urgent medical advice for other concerning symptoms.": "Hvis du mistenker en overdose, har problemer med å puste, føler deg forvirret eller er i umiddelbar fare, kontakt den lokale nødetaten. Søk akutt medisinsk råd ved andre bekymringsfulle symptomer.",
            "You could tell someone safe: ‘Something difficult happened. Could you stay with me and help me get support?’": "Du kan si til en trygg person: «Noe vanskelig har skjedd. Kan du være sammen med meg og hjelpe meg med å få støtte?»",
            "Show support and contacts": "Vis støtte og kontaktinformasjon",
            "If alcohol or sedative use has been heavy or prolonged, ask a clinician about stopping safely. This app does not provide withdrawal instructions.": "Hvis du har brukt mye alkohol eller beroligende legemidler, eller brukt dem over lang tid, spør helsepersonell om hvordan du kan slutte trygt. Appen gir ikke instruksjoner om avrusning.",
            "A message could say: I'm having a hard moment. Can you talk?": "En melding kan være: Jeg har det vanskelig akkurat nå. Kan vi snakke?",
            "Move somewhere safer if you can.": "Gå til et tryggere sted hvis du kan.",
            "Take care of a basic need without pressure.": "Ta vare på et grunnleggende behov uten press.",
            "You can take a break and still ask for help.": "Du kan ta en pause og samtidig be om støtte.",
            "Write down one safer next step": "Skriv ned ett tryggere neste steg",
            "Fill in only what helps. You do not need to revisit trauma alone.": "Fyll bare ut det som hjelper. Du trenger ikke å gå tilbake til traumeminner alene.",
            "What tells me things are getting harder?": "Hvordan merker jeg at det blir vanskeligere?",
            "What small action gives me a pause?": "Hvilken liten handling gir meg en pause?",
            "Who can I tell?": "Hvem kan jeg fortelle det til?",
            "Where can I find care or peer support?": "Hvor kan jeg finne behandling eller likemannsstøtte?",
            "My support card": "Mitt støttekort",
            "Share the card if you choose": "Del kortet hvis du vil",
            "Clear fields": "Tøm feltene",
            "Your text stays on this device for this session unless you choose to share it.": "Teksten din blir på denne enheten i denne økten, med mindre du velger å dele den.",
            "Choose what fits this moment": "Velg det som passer akkurat nå",
            "You can try, adapt or skip any tool.": "Du kan prøve, tilpasse eller hoppe over alle øvelser.",
            "Timer and permission to pause": "Tidtaker og lov til å ta en pause",
            "Pause": "Pause",
            "Start": "Start",
            "Reset": "Nullstill",
            "You can pause whenever you need.": "Du kan ta en pause når du trenger det.",
            "The smallest possible step": "Det minste mulige steget",
            "Hello, feeling": "Hei, følelse",
            "Use your senses": "Bruk sansene dine",
            "Kinder self-talk": "Snakk vennligere til deg selv",
            "My boundaries": "Mine grenser",
            "Count before deciding": "Tell før du bestemmer deg",
            "Breathe at your pace": "Pust i ditt eget tempo",
            "A tactile anchor": "Et anker gjennom berøring",
            "My future self": "Mitt fremtidige jeg",
            "Write it down": "Skriv det ned",
            "Ask: What is possible today? Rest counts, too.": "Spør: Hva er mulig i dag? Hvile teller også.",
            "Name the feeling. You do not have to like or change it right away.": "Sett ord på følelsen. Du trenger ikke å like den eller endre den med en gang.",
            "Name one color and feel the ground beneath your feet. Stop if it doesn't feel right.": "Nevn én farge og kjenn bakken under føttene. Stopp hvis det ikke føles bra.",
            "Answer a harsh thought with something believable: This is hard, and I can ask for help.": "Svar på en hard tanke med noe troverdig: Dette er vanskelig, og jeg kan be om hjelp.",
            "Ask: Which part is mine? You can take care of your own support.": "Spør: Hva er mitt ansvar? Du kan ta vare på ditt eget behov for støtte.",
            "Count to eight and ask if you need more time before deciding.": "Tell til åtte og spør om du trenger mer tid før du bestemmer deg.",
            "Breathe gently. Lengthen your exhale only if it feels comfortable. Stop if you feel dizzy.": "Pust rolig. Forleng utpusten bare hvis det føles behagelig. Stopp hvis du blir svimmel.",
            "Touch two fingers with your thumb. Notice the sensation and ask what might help now. This is not a treatment and need not work every time.": "Berør to fingre med tommelen. Legg merke til berøringen og spør hva som kan hjelpe nå. Dette er ikke behandling og trenger ikke å virke hver gang.",
            "Ask: What might tomorrow's me appreciate today? Choose one small, safe action. Rest can be that action.": "Spør: Hva kan morgendagens jeg sette pris på i dag? Velg én liten, trygg handling. Hvile kan være den handlingen.",
            "Write a few words about the urge, feeling and support you need. Stop whenever writing feels overwhelming.": "Skriv noen ord om suget, følelsen og støtten du trenger. Stopp når skrivingen føles overveldende.",
            "A new direction. Your pace.": "En ny retning. Ditt tempo.",
            "Choose the part that helps today. One and three years are long-term horizons, not deadlines. A setback never resets your path.": "Velg den delen som hjelper i dag. Ett og tre år er langsiktige perspektiver, ikke tidsfrister. Et tilbakeslag nullstiller aldri veien din.",
            "Marked": "Merket",
            "Not marked": "Ikke merket",
            "A mark means ‘I tried it’. Remove it whenever you wish. The steps have no required order.": "Et merke betyr «jeg prøvde». Fjern det når du vil. Stegene har ingen fast rekkefølge.",
            "Clear path marks": "Fjern merkene på min vei",
            "My week": "Min uke",
            "Write only what helps. You can change the plan and a hard day never resets your path.": "Skriv bare det som hjelper. Du kan endre planen, og en vanskelig dag nullstiller aldri veien din.",
            "What matters?": "Hva er viktig?",
            "One small action": "Én liten handling",
            "Rest or recovery": "Hvile eller restitusjon",
            "Who can I ask for support?": "Hvem kan jeg be om støtte?",
            "The weekly text stays in memory for this session and disappears when the app closes.": "Uketeksten blir i minnet i denne økten og forsvinner når appen lukkes.",
            "Clear weekly text": "Tøm uketeksten",
            "1 · First steps": "1 · De første stegene",
            "2 · Building a new life": "2 · Bygge et nytt liv",
            "3 · My next direction": "3 · Min neste retning",
            "Choose a safer next step": "Velg et tryggere neste steg",
            "Over a year: build your everyday life": "I løpet av et år: bygg hverdagen din",
            "A three-year horizon: find meaning": "Et treårsperspektiv: finn mening",
            "Connection, safety and one action are enough to begin. Help is available now.": "Kontakt, trygghet og én handling er nok til å begynne. Du kan be om hjelp med en gang.",
            "Build an everyday life worth returning to. Rest and support belong in every week.": "Bygg en hverdag det er godt å vende tilbake til. Hvile og støtte hører til hver uke.",
            "New values, relationships and goals can grow alongside recovery. Hard days remain allowed.": "Nye verdier, relasjoner og mål kan vokse frem under tilfriskningen. Vanskelige dager er fortsatt tillatt.",
            "Take your time": "Ta den tiden du trenger",
            "Food, sleep, gentle movement and connection can support recovery. They are not a performance checklist.": "Mat, søvn, rolig bevegelse og kontakt med andre kan støtte tilfriskningen. Det er ikke en prestasjonsliste.",
            "An optional 21-day experiment": "Et frivillig 21-dagers forsøk",
            "Day": "Dag",
            "Day ": "Dag ",
            "Read for a moment": "Les en stund",
            "Write one good thing": "Skriv ned én god ting",
            "Missing a day resets nothing.": "En dag du hopper over, nullstiller ingenting.",
            "Mark this day complete": "Merk denne dagen som fullført",
            "Days marked: ": "Merkede dager: ",
            "Clear challenge progress": "Fjern merkene fra forsøket",
            "Write or simply notice": "Skriv eller bare legg merke til det",
            "What feeling or urge showed up? What do I need next? You do not need to work through the past alone.": "Hvilken følelse eller hvilket sug dukket opp? Hva trenger jeg videre? Du trenger ikke å bearbeide fortiden alene.",
            "A few words, if you like": "Noen ord, hvis du vil",
            "Clear writing": "Tøm teksten",
            "This text is not saved. It disappears when the app is closed.": "Denne teksten lagres ikke. Den forsvinner når appen lukkes.",
            "If you used or gambled again": "Hvis du brukte rusmidler eller spilte om penger igjen",
            "First take care of your safety and reconnect with support. A return to use does not define your worth.": "Ta først vare på sikkerheten din og ta kontakt med støtte igjen. Å begynne å bruke rusmidler igjen definerer ikke verdien din.",
            "When gambling calls": "Når pengespill frister",
            "Delay the decision, close the gambling site and step away from payment methods. Ask for help setting limits on money and gambling accounts.": "Utsett beslutningen om å spille, lukk spillsiden og gå bort fra betalingsmulighetene. Be om hjelp til å sette grenser for penger og spillkontoer.",
            "Show an optional faith reminder": "Vis en frivillig påminnelse om tro",
            "I can ask for help, rest and take this day one step at a time.": "Jeg kan be om hjelp, hvile og ta denne dagen ett steg om gangen.",
            "Support for recovery": "Støtte til tilfriskning",
            "What does Adis do?": "Hva gjør Adis?",
            "Adis does not diagnose, treat withdrawal or replace professional care. If stopping a substance brings strong symptoms, ask a healthcare professional how to proceed safely.": "Adis stiller ikke diagnoser, behandler ikke abstinens og erstatter ikke profesjonell behandling. Hvis du får sterke symptomer når du slutter med et rusmiddel, spør helsepersonell om hvordan du kan gå videre trygt.",
            "You do not need to revisit trauma alone. Faith, forgiveness and gratitude are optional.": "Du trenger ikke å gå tilbake til traumer alene. Tro, tilgivelse og takknemlighet er frivillig.",
            "The app is free. It needs no account and does not send your support card to a server.": "Appen er gratis. Du trenger ingen konto, og støttekortet ditt sendes ikke til en server.",
            "Read privacy policy": "Les personvernerklæringen",
            "Clear all my marks": "Fjern alle mine merker",
            "When you need a person": "Når du trenger et menneske",
            "A care professional, peer or trusted person can help with the next decision.": "Helsepersonell, en likemann eller en person du stoler på kan hjelpe deg med den neste beslutningen.",
            "Name one safe person or service.": "Nevn én trygg person eller støttetjeneste.",
            "Choose a place where you would feel safer.": "Velg et sted der du ville føle deg tryggere.",
            "Write one reason this new direction matters to you.": "Skriv én grunn til at denne nye retningen betyr noe for deg.",
            "Take one small action or ask for help with it.": "Ta ett lite steg eller be om hjelp med det.",
            "Choose one support contact for next week.": "Velg én støttekontakt for neste uke.",
            "Notice one everyday need: sleep, food or rest.": "Legg merke til ett hverdagsbehov: søvn, mat eller hvile.",
            "Choose an enjoyable activity without pressure.": "Velg en hyggelig aktivitet uten press.",
            "Name one situation where you need more support.": "Nevn én situasjon der du trenger mer støtte.",
            "Write down one value you want to live by.": "Skriv ned én verdi du vil leve etter.",
            "Choose a relationship, hobby, study or work goal to nurture.": "Velg en relasjon, hobby eller et studie- eller arbeidsmål du vil utvikle.",
            "Pick one small step toward it.": "Velg ett lite steg mot det.",
            "Check your limits and who can support you later, too.": "Se på grensene dine og hvem som kan støtte deg også fremover.",
            "MY SUPPORT CARD": "MITT STØTTEKORT",
            "Signs": "Tegn",
            "Person": "Person",
            "I'll add this later.": "Jeg legger til dette senere.",
            "I stop and consider my next step.": "Jeg stopper opp og vurderer neste steg.",
            "I choose someone I trust.": "Jeg velger noen jeg stoler på.",
            "I contact care or peer support.": "Jeg tar kontakt med behandling eller likemannsstøtte.",
            "A hard day does not change my worth.": "En vanskelig dag endrer ikke verdien min.",
            "Substance-use support by country": "Støtte ved rusmiddelbruk etter land",
            "Gambling support by country": "Støtte ved pengespill etter land",
            "NA meeting search": "Søk etter NA-møter",
            "Gamblers Anonymous meetings": "Gamblers Anonymous-møter",
            "Find a Helpline by country": "Finn en hjelpetelefon etter land",
            "Find a helpline near you": "Finn en hjelpetelefon nær deg",
            "If someone is in immediate danger, contact your local emergency services.": "Hvis noen er i umiddelbar fare, kontakt den lokale nødetaten.",
        ],
        "et": [
            "Right now": "Praegu",
            "Now": "Nüüd",
            "My plan": "Minu plaan",
            "Plan": "Plaan",
            "Tools": "Abivõtted",
            "My path": "Minu teekond",
            "Path": "Teekond",
            "Find support": "Leia tuge",
            "Support": "Tugi",
            "Privacy": "Privaatsus",
            "Done": "Valmis",
            "Choose language": "Vali keel",
            "You don't have to face this alone.": "Sa ei pea sellega üksi toime tulema.",
            "One moment at a time. Choose what fits and one small next step.": "Üks hetk korraga. Vali sobiv tegevus ja üks väike järgmine samm.",
            "You are enough, even on a hard day.": "Sa oled piisav ka raskel päeval.",
            "What's happening right now?": "Mis praegu toimub?",
            "The urge is strong": "Tung on tugev",
            "I feel overwhelmed": "Tunnen, et kõik käib üle jõu",
            "I used or gambled again": "Tarvitasin aineid või mängisin jälle hasartmänge",
            "I want to support my routine": "Tahan toetada oma argirutiini",
            "How strong is the urge?": "Kui tugev tung on?",
            "Urge intensity": "Tungi tugevus",
            "One small next step": "Üks väike järgmine samm",
            "Reach out": "Võta ühendust",
            "Change surroundings": "Vaheta keskkonda",
            "Eat or drink": "Söö või joo",
            "Rest": "Puhka",
            "Talk to someone now": "Räägi kellegagi kohe",
            "The urge feels strong. You can delay a decision.": "Tung tundub tugev. Võid otsustamise edasi lükata.",
            "A hard moment deserves support and rest.": "Raskel hetkel vajad tuge ja puhkust.",
            "A return to use does not change your worth or right to help. Start with your safety.": "Uuesti tarvitamine ei muuda sinu väärtust ega õigust abile. Hoolitse kõigepealt oma turvalisuse eest.",
            "You can support one routine that matters to you.": "Võid toetada üht enda jaoks olulist rutiini.",
            "Pause and choose one next step.": "Peatu ja vali üks järgmine samm.",
            "Contact someone you trust or your care team if you need help.": "Kui vajad abi, võta ühendust usaldusväärse inimese või oma ravimeeskonnaga.",
            "After a return to use": "Pärast uuesti tarvitamist",
            "If you suspect an overdose, have trouble breathing, feel confused or are in immediate danger, call local emergency services. Seek urgent medical advice for other concerning symptoms.": "Kui kahtlustad üledoosi, sul on hingamisraskused, oled segaduses või vahetus ohus, helista kohalikule hädaabinumbrile. Muude murettekitavate sümptomite korral pöördu kiiresti tervishoiutöötaja poole.",
            "You could tell someone safe: ‘Something difficult happened. Could you stay with me and help me get support?’": "Võid öelda usaldusväärsele inimesele: „Juhtus midagi rasket. Kas sa saaksid minuga olla ja aidata mul tuge leida?”",
            "Show support and contacts": "Näita abivõimalusi ja kontakte",
            "If alcohol or sedative use has been heavy or prolonged, ask a clinician about stopping safely. This app does not provide withdrawal instructions.": "Kui oled tarvitanud palju alkoholi või rahusteid või tarvitanud neid pikemat aega, küsi tervishoiutöötajalt, kuidas ohutult lõpetada. Rakendus ei anna võõrutusravi juhiseid.",
            "A message could say: I'm having a hard moment. Can you talk?": "Võid kirjutada: Mul on praegu raske. Kas saaksime rääkida?",
            "Move somewhere safer if you can.": "Kui võimalik, mine turvalisemasse kohta.",
            "Take care of a basic need without pressure.": "Hoolitse ühe põhivajaduse eest ilma surveta.",
            "You can take a break and still ask for help.": "Võid teha pausi ja samal ajal tuge paluda.",
            "Write down one safer next step": "Pane kirja üks turvalisem järgmine samm",
            "Fill in only what helps. You do not need to revisit trauma alone.": "Täida ainult see, millest on abi. Sa ei pea traumamälestuste juurde üksi tagasi pöörduma.",
            "What tells me things are getting harder?": "Millest märkan, et olukord muutub raskemaks?",
            "What small action gives me a pause?": "Milline väike tegevus annab mulle hingetõmbeaja?",
            "Who can I tell?": "Kellele saan rääkida?",
            "Where can I find care or peer support?": "Kust saan leida ravi või kogemuskaaslaste tuge?",
            "My support card": "Minu tugikaart",
            "Share the card if you choose": "Jaga kaarti, kui soovid",
            "Clear fields": "Tühjenda väljad",
            "Your text stays on this device for this session unless you choose to share it.": "Sinu tekst jääb selle kasutuskorra ajaks sellesse seadmesse, kui sa ei otsusta seda ise jagada.",
            "Choose what fits this moment": "Vali see, mis praegu sobib",
            "You can try, adapt or skip any tool.": "Võid iga harjutust proovida, kohandada või vahele jätta.",
            "Timer and permission to pause": "Taimer ja luba pausi teha",
            "Pause": "Paus",
            "Start": "Alusta",
            "Reset": "Lähtesta",
            "You can pause whenever you need.": "Võid teha pausi alati, kui seda vajad.",
            "The smallest possible step": "Väikseim võimalik samm",
            "Hello, feeling": "Tere, tunne",
            "Use your senses": "Kasuta oma meeli",
            "Kinder self-talk": "Räägi endaga lahkemalt",
            "My boundaries": "Minu piirid",
            "Count before deciding": "Loenda enne otsustamist",
            "Breathe at your pace": "Hinga omas tempos",
            "A tactile anchor": "Puudutuse abil kohalolu",
            "My future self": "Minu tulevane mina",
            "Write it down": "Pane see kirja",
            "Ask: What is possible today? Rest counts, too.": "Küsi: Mis on täna võimalik? Ka puhkus loeb.",
            "Name the feeling. You do not have to like or change it right away.": "Nimeta tunne. Sa ei pea seda kohe meeldivaks pidama ega muutma.",
            "Name one color and feel the ground beneath your feet. Stop if it doesn't feel right.": "Nimeta üks värv ja tunne maapinda oma jalge all. Lõpeta, kui see ei tundu hea.",
            "Answer a harsh thought with something believable: This is hard, and I can ask for help.": "Vasta karmile mõttele millegi usutavaga: See on raske ja ma võin abi paluda.",
            "Ask: Which part is mine? You can take care of your own support.": "Küsi: Mille eest vastutan mina? Võid hoolitseda oma toetusvajaduse eest.",
            "Count to eight and ask if you need more time before deciding.": "Loenda kaheksani ja küsi endalt, kas vajad enne otsustamist rohkem aega.",
            "Breathe gently. Lengthen your exhale only if it feels comfortable. Stop if you feel dizzy.": "Hinga rahulikult. Pikenda väljahingamist ainult siis, kui see tundub mugav. Lõpeta, kui tekib peapööritus.",
            "Touch two fingers with your thumb. Notice the sensation and ask what might help now. This is not a treatment and need not work every time.": "Puuduta pöidlaga kahte sõrme. Märka puudutust ja küsi, mis võiks praegu aidata. See ei ole ravi ega pea iga kord toimima.",
            "Ask: What might tomorrow's me appreciate today? Choose one small, safe action. Rest can be that action.": "Küsi: Mille eest võiks mu homne mina täna tänulik olla? Vali üks väike ja turvaline tegevus. Selleks võib olla puhkus.",
            "Write a few words about the urge, feeling and support you need. Stop whenever writing feels overwhelming.": "Kirjuta mõni sõna tungi, tunde ja vajaliku toe kohta. Lõpeta, kui kirjutamine muutub liiga koormavaks.",
            "A new direction. Your pace.": "Uus suund. Sinu tempo.",
            "Choose the part that helps today. One and three years are long-term horizons, not deadlines. A setback never resets your path.": "Vali see osa, mis täna aitab. Üks ja kolm aastat on pikaajalised vaated, mitte tähtajad. Tagasilöök ei nulli sinu teekonda.",
            "Marked": "Märgitud",
            "Not marked": "Märkimata",
            "A mark means ‘I tried it’. Remove it whenever you wish. The steps have no required order.": "Märge tähendab „proovisin”. Võid selle igal ajal eemaldada. Sammudel pole kohustuslikku järjekorda.",
            "Clear path marks": "Kustuta teekonna märked",
            "My week": "Minu nädal",
            "Write only what helps. You can change the plan and a hard day never resets your path.": "Kirjuta ainult see, millest on abi. Võid plaani muuta ja raske päev ei nulli sinu teekonda.",
            "What matters?": "Mis on oluline?",
            "One small action": "Üks väike tegevus",
            "Rest or recovery": "Puhkus või taastumine",
            "Who can I ask for support?": "Kellelt saan tuge paluda?",
            "The weekly text stays in memory for this session and disappears when the app closes.": "Nädala tekst jääb ainult selle kasutuskorra ajaks mällu ja kaob rakenduse sulgemisel.",
            "Clear weekly text": "Kustuta nädala tekst",
            "1 · First steps": "1 · Esimesed sammud",
            "2 · Building a new life": "2 · Uue elu kujundamine",
            "3 · My next direction": "3 · Minu järgmine suund",
            "Choose a safer next step": "Vali turvalisem järgmine samm",
            "Over a year: build your everyday life": "Aasta jooksul: kujunda oma argielu",
            "A three-year horizon: find meaning": "Kolme aasta vaade: leia tähendus",
            "Connection, safety and one action are enough to begin. Help is available now.": "Alustamiseks piisab kontaktist, turvalisusest ja ühest tegevusest. Võid kohe abi paluda.",
            "Build an everyday life worth returning to. Rest and support belong in every week.": "Kujunda argielu, mille juurde on hea tagasi tulla. Puhkus ja tugi kuuluvad igasse nädalasse.",
            "New values, relationships and goals can grow alongside recovery. Hard days remain allowed.": "Taastumise kõrval võivad kujuneda uued väärtused, suhted ja eesmärgid. Rasked päevad on endiselt lubatud.",
            "Take your time": "Võta endale aega",
            "Food, sleep, gentle movement and connection can support recovery. They are not a performance checklist.": "Toit, uni, rahulik liikumine ja kontakt teistega võivad taastumist toetada. Need ei ole sooritusnõuete nimekiri.",
            "An optional 21-day experiment": "Vabatahtlik 21-päevane katsetus",
            "Day": "Päev",
            "Day ": "Päev ",
            "Read for a moment": "Loe veidi",
            "Write one good thing": "Pane kirja üks hea asi",
            "Missing a day resets nothing.": "Vahele jäänud päev ei nulli midagi.",
            "Mark this day complete": "Märgi see päev tehtuks",
            "Days marked: ": "Märgitud päevi: ",
            "Clear challenge progress": "Kustuta katsetuse märked",
            "Write or simply notice": "Kirjuta või lihtsalt märka",
            "What feeling or urge showed up? What do I need next? You do not need to work through the past alone.": "Milline tunne või tung tekkis? Mida ma järgmiseks vajan? Sa ei pea minevikuga üksi tegelema.",
            "A few words, if you like": "Mõni sõna, kui soovid",
            "Clear writing": "Kustuta kirjutis",
            "This text is not saved. It disappears when the app is closed.": "Seda teksti ei salvestata. See kaob rakenduse sulgemisel.",
            "If you used or gambled again": "Kui tarvitasid aineid või mängisid jälle hasartmänge",
            "First take care of your safety and reconnect with support. A return to use does not define your worth.": "Hoolitse kõigepealt turvalisuse eest ja võta taas ühendust toetajatega. Uuesti tarvitamine ei määra sinu väärtust.",
            "When gambling calls": "Kui hasartmängud ahvatlevad",
            "Delay the decision, close the gambling site and step away from payment methods. Ask for help setting limits on money and gambling accounts.": "Lükka mängimisotsus edasi, sulge hasartmänguleht ja eemaldu maksevõimalustest. Palu abi raha kasutamise ja mängukontode piiramisel.",
            "Show an optional faith reminder": "Näita vabatahtlikku usu meeldetuletust",
            "I can ask for help, rest and take this day one step at a time.": "Võin abi paluda, puhata ja liikuda täna üks samm korraga.",
            "Support for recovery": "Tugi taastumisel",
            "What does Adis do?": "Mida Adis teeb?",
            "Adis does not diagnose, treat withdrawal or replace professional care. If stopping a substance brings strong symptoms, ask a healthcare professional how to proceed safely.": "Adis ei diagnoosi, ei ravi võõrutusnähte ega asenda professionaalset ravi. Kui aine tarvitamise lõpetamisel tekivad tugevad sümptomid, küsi tervishoiutöötajalt, kuidas ohutult edasi minna.",
            "You do not need to revisit trauma alone. Faith, forgiveness and gratitude are optional.": "Sa ei pea traumaga üksi tegelema. Usk, andestamine ja tänulikkus on vabatahtlikud.",
            "The app is free. It needs no account and does not send your support card to a server.": "Rakendus on tasuta. Kontot pole vaja ja sinu tugikaarti ei saadeta serverisse.",
            "Read privacy policy": "Loe privaatsuspõhimõtteid",
            "Clear all my marks": "Kustuta kõik minu märked",
            "When you need a person": "Kui vajad teist inimest",
            "A care professional, peer or trusted person can help with the next decision.": "Tervishoiutöötaja, kogemuskaaslane või usaldusväärne inimene võib aidata järgmise otsusega.",
            "Name one safe person or service.": "Nimeta üks usaldusväärne inimene või abiteenus.",
            "Choose a place where you would feel safer.": "Vali koht, kus tunneksid end turvalisemalt.",
            "Write one reason this new direction matters to you.": "Kirjuta üks põhjus, miks see uus suund on sulle oluline.",
            "Take one small action or ask for help with it.": "Tee üks väike tegevus või palu selleks abi.",
            "Choose one support contact for next week.": "Vali järgmiseks nädalaks üks toetav kontakt.",
            "Notice one everyday need: sleep, food or rest.": "Märka üht igapäevast vajadust: uni, toit või puhkus.",
            "Choose an enjoyable activity without pressure.": "Vali meeldiv tegevus ilma surveta.",
            "Name one situation where you need more support.": "Nimeta üks olukord, kus vajad rohkem tuge.",
            "Write down one value you want to live by.": "Pane kirja üks väärtus, mille järgi tahad elada.",
            "Choose a relationship, hobby, study or work goal to nurture.": "Vali suhe, hobi, õpingud või tööeesmärk, mida tahad arendada.",
            "Pick one small step toward it.": "Vali üks väike samm selle poole.",
            "Check your limits and who can support you later, too.": "Vaata üle oma piirid ja see, kes saab sind ka edaspidi toetada.",
            "MY SUPPORT CARD": "MINU TUGIKAART",
            "Signs": "Märgid",
            "Person": "Inimene",
            "I'll add this later.": "Lisan selle hiljem.",
            "I stop and consider my next step.": "Peatun ja mõtlen oma järgmisele sammule.",
            "I choose someone I trust.": "Valin inimese, keda usaldan.",
            "I contact care or peer support.": "Võtan ühendust raviteenuse või kogemuskaaslastega.",
            "A hard day does not change my worth.": "Raske päev ei muuda minu väärtust.",
            "Substance-use support by country": "Abi ainete tarvitamise korral riigi järgi",
            "Gambling support by country": "Abi hasartmänguprobleemide korral riigi järgi",
            "NA meeting search": "Leia NA koosolekuid",
            "Gamblers Anonymous meetings": "Gamblers Anonymousi koosolekud",
            "Find a Helpline by country": "Leia abiliin riigi järgi",
            "Find a helpline near you": "Leia lähedal asuv abiliin",
            "If someone is in immediate danger, contact your local emergency services.": "Kui keegi on vahetus ohus, helista kohalikule hädaabinumbrile.",
        ],
    ]
    static let privacy: [String: String] = [
        "sv": "Uppdaterad 1 oktober 2026\n\nAdis kräver inget konto. Text i stödkortet, veckoplanen och den frivilliga reflektionen finns i appens minne under den aktuella sessionen och skickas inte till en Adis-server. Språkval, vald väg, markeringar på vägen och numren på slutförda dagar i det frivilliga 21-dagarsförsöket sparas lokalt på din enhet. Du kan rensa markeringarna i appen. Adis använder inga analysverktyg eller annonsnätverk. Om du öppnar iOS delningsmeny väljer du själv vart stödkortet skickas. Externa stödlänkar följer respektive tjänsts integritetspolicy. Adis har inga profiler, ingen spårning och inga betalningar. Integritetsfrågor: hyvinvalmennus@outlook.com.",
        "nb": "Oppdatert 1. oktober 2026\n\nAdis krever ingen konto. Tekst i støttekortet, ukeplanen og den frivillige refleksjonen blir i appens minne i den aktuelle økten og sendes ikke til en Adis-server. Språkvalg, valgt vei, merker på veien og numrene på fullførte dager i det frivillige 21-dagers forsøket lagres lokalt på enheten din. Du kan fjerne merkene i appen. Adis bruker ikke analyseverktøy eller annonsenettverk. Hvis du åpner delingsmenyen i iOS, velger du selv hvor støttekortet skal sendes. Eksterne støttelenker følger tjenestenes egne personvernregler. Adis har ingen profiler, sporing eller betalinger. Spørsmål om personvern: hyvinvalmennus@outlook.com.",
        "et": "Uuendatud 1. oktoobril 2026\n\nAdis ei nõua kontot. Tugikaardi, nädalaplaani ja vabatahtliku mõtiskluse tekst jääb käesoleva kasutuskorra ajaks rakenduse mällu ning seda ei saadeta Adise serverisse. Keelevalik, valitud teekond, teekonna märked ja vabatahtliku 21-päevase katsetuse tehtud päevade numbrid salvestatakse seadmesse kohalikult. Märked saab rakenduses kustutada. Adis ei kasuta analüütikat ega reklaamivõrgustikke. Kui avad iOS-i jagamismenüü, valid ise, kuhu tugikaart saata. Väliste tugilinkide puhul kehtivad vastavate teenuste privaatsuspõhimõtted. Adisel pole profiile, jälgimist ega makseid. Privaatsusküsimused: hyvinvalmennus@outlook.com.",
    ]
}
