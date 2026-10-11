import SwiftUI
import UIKit
import UniformTypeIdentifiers

// ============================================================
// STRUCTURES DE DONNÉES
// ============================================================

struct PostureEntry {
    let category: String
    let text: String
    let tags: Set<String>
}

struct TaggedEntry {
    let text: String
    let tags: Set<String>
}

struct TenueEntry {
    let text: String
    let style: String
    let tags: Set<String>
}

// ============================================================
// GESTION DES FICHIERS
// ============================================================

class FileManagerHelper {
    static let shared = FileManagerHelper()

    let posturesFile = "postures.txt"
    let expressionsFile = "expressions.txt"
    let cadragesFile = "cadrages.txt"
    let decorsFile = "decors.txt"
    let tenuesFile = "tenues.txt"

    // ✅ Utilise Documents/ directement (pas de sous-dossier)
    var dataFolderURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func ensureFolderExists() {
        try? FileManager.default.createDirectory(at: dataFolderURL, withIntermediateDirectories: true)
    }

    /// Crée les 5 fichiers .txt dans Documents/ s'ils n'existent pas encore,
    /// pour que le dossier soit visible (non vide) dans l'app Fichiers.
    func createDefaultFilesIfNeeded() {
        ensureFolderExists()
        _ = loadFile(named: posturesFile, defaultContent: DEFAULT_POSTURES)
        _ = loadFile(named: expressionsFile, defaultContent: DEFAULT_EXPRESSIONS)
        _ = loadFile(named: cadragesFile, defaultContent: DEFAULT_CADRAGES)
        _ = loadFile(named: decorsFile, defaultContent: DEFAULT_DECORS)
        _ = loadFile(named: tenuesFile, defaultContent: DEFAULT_TENUES)
    }

    func loadFile(named name: String, defaultContent: String) -> String {
        let url = dataFolderURL.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? defaultContent.write(to: url, atomically: true, encoding: .utf8)
            return defaultContent
        }
        // Lecture UTF-8, avec repli si le fichier a été réenregistré dans un autre encodage
        if let text = try? String(contentsOf: url, encoding: .utf8) { return text }
        if let text = try? String(contentsOf: url, encoding: .utf16) { return text }
        if let text = try? String(contentsOf: url, encoding: .isoLatin1) { return text }
        return defaultContent
    }

    /// Copie les fichiers choisis dans Documents/ (écrase ceux du même nom).
    /// Retourne le nombre de fichiers importés.
    func importFiles(from urls: [URL]) -> Int {
        ensureFolderExists()
        var count = 0
        for url in urls {
            let accessed = url.startAccessingSecurityScopedResource()
            defer { if accessed { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else { continue }
            let dest = dataFolderURL.appendingPathComponent(url.lastPathComponent)
            do {
                try data.write(to: dest, options: .atomic)
                count += 1
            } catch {
                continue
            }
        }
        return count
    }

    func fileURL(for name: String) -> URL {
        return dataFolderURL.appendingPathComponent(name)
    }
}

// ============================================================
// CONTENU PAR DÉFAUT
// ============================================================

let DEFAULT_POSTURES = """
# Format : [Catégorie] puis postures avec balises C/M/D/S

[Debout]
standing naturally with weight shifted to one hip, one hand in pocket | C,M,D,S
standing by a window looking outside, arms loosely crossed | C,M,D
standing with one hand on hip and the other touching hair | C,M,S
standing straight with both arms at sides, shoulders relaxed | C,M,D

[Assise]
sitting on the edge of a bed with legs crossed, hands on knees | C,D
sitting cross-legged on a couch, hands resting on thighs | C,D
sitting on a chair leaning back slightly, one arm on the backrest | C,D
sitting on a stool with legs crossed at ankles, hands on lap | C,D

[Allongée]
lying flat on a bed on her back, arms relaxed at sides | C,D
lying on her side with one arm under her head, knees slightly bent | C,D
lying on her stomach propped up on elbows, looking forward | C,D
lying diagonally across a bed with arms stretched above head | C,D

[Mur]
leaning against a wall with one shoulder, hands in pockets | C,M,D
leaning against a wall with one foot flat on it behind her | C,M,D
back flat against a wall, arms crossed, looking straight ahead | C,M,D
leaning against a doorway frame, one hand on the frame | C,M,D

[Miroir Actif]
taking a quick mirror selfie holding phone at chest height | M
full-length mirror selfie showing the whole outfit | M
half-body mirror selfie with one hand on hip, phone in the other | M
side mirror selfie, head turned slightly, phone raised to eye level | M

[Selfie Bras Tendu]
holding phone at arm's length with one arm extended, front camera | S
taking a quick selfie with the phone raised at eye level | S
selfie with the phone held slightly above eye level | S
selfie with the phone held at chest level, looking down slightly | S
"""

let DEFAULT_EXPRESSIONS = """
looking directly at the lens with a calm and collected demeanor | ALL
looking sideways with a subtle moody aesthetic | ALL
gazing softly into the distance with a dreamy expression | ALL
looking at the camera with a natural slight smile | C,S
looking at the mirror reflection with a playful expression | M
caught in a candid moment, looking away from the camera | D
expressing quiet confidence with a relaxed gaze | ALL
giving a soft half-smile with a hint of shyness | M,C,S
with a neutral calm expression, lips slightly parted | ALL
with a warm friendly expression, eyes slightly narrowed | M,C,S
"""

let DEFAULT_CADRAGES = """
front camera selfie at 30cm from face, 24mm equivalent lens, f/2.2, ISO 400, natural indoor window light coming from the left, soft diffused shadows | C
front camera selfie at 40cm from face, 26mm lens, f/2.0, ISO 320, soft daylight from a window behind the camera, even lighting | C
mirror selfie at 50cm from the mirror, 26mm lens, f/2.2, ISO 400, natural daylight from a window on the left, soft shadows | M
mirror selfie at 1 meter from mirror, 24mm lens, f/2.0, ISO 500, warm ambient bedroom light, soft diffused shadows | M
rear camera photo at 6 meters from subject, 100mm telephoto equivalent lens, f/2.8, ISO 200, natural daylight from a large window | D
rear camera photo at 4 meters from subject, 50mm lens, f/2.0, ISO 320, soft afternoon daylight, even lighting | D
selfie with arm fully extended at 60cm from face, 24mm lens, f/2.2, ISO 400, natural daylight from window | S
selfie with phone raised above eye level at 50cm, 26mm lens, f/2.0, ISO 320, soft indoor lighting | S
"""

let DEFAULT_DECORS = """
a cozy bedroom with an unmade bed, warm ambient light, clothes on a chair | ALL
a sunlit modern apartment bedroom with soft white linens and wooden furniture | ALL
a bohemian style bedroom with macrame, plants, and fairy lights | ALL
a minimalist bedroom with plain walls and a large floor mirror | ALL
a modern living room with a sofa, a plant, and framed art | ALL
a cozy café terrace with a coffee cup on the table, natural daylight | C,S
a city street with blurred passersby, daylight, candid moment | D
a park bench surrounded by trees, golden hour lighting | D
a bathroom with a large mirror, warm light, plants on shelves | M
a cozy living room with a book on a coffee table and a warm lamp | ALL
"""

let DEFAULT_TENUES = """
a soft white cotton t-shirt with a slightly loose fit | SIMPLE | ALL
a plain black cotton t-shirt with a relaxed fit | SIMPLE | ALL
a black satin slip dress with thin straps | SEXY | M,D
a deep red velvet camisole top with lace trim | SEXY | M,D
a beige oversized wool blazer over a white silk camisole | CHIC | M,D
a black tailored midi dress with a square neckline | CHIC | M,D
a black oversized hoodie with a small chest logo | STREETWEAR | C,S
a white oversized graphic t-shirt with a large back print | STREETWEAR | C,S
a two-piece bikini set in a soft pastel blue | PLAGE | ALL
a white crochet mini dress worn over a bikini | PLAGE | ALL
a black micro mini dress with thin straps | TRESCOURT | M,D
a white bodycon mini dress with a square neckline | TRESCOURT | M,D
"""

// ============================================================
// PARSEURS
// ============================================================

func parsePostures(_ content: String) -> [PostureEntry] {
    var result: [PostureEntry] = []
    var currentCategory: String? = nil

    for rawLine in content.components(separatedBy: .newlines) {
        let line = rawLine.trimmingCharacters(in: .whitespaces)
        if line.isEmpty || line.hasPrefix("#") { continue }

        if line.hasPrefix("[") && line.hasSuffix("]") {
            currentCategory = String(line.dropFirst().dropLast())
            continue
        }

        if let cat = currentCategory, line.contains("|") {
            let parts = line.components(separatedBy: "|")
            if parts.count >= 2 {
                let text = parts[0].trimmingCharacters(in: .whitespaces)
                let tagsStr = parts[1].trimmingCharacters(in: .whitespaces).uppercased()
                let tags = Set(tagsStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) })
                result.append(PostureEntry(category: cat, text: text, tags: tags))
            }
        }
    }
    return result
}

func parseTaggedEntries(_ content: String) -> [TaggedEntry] {
    var result: [TaggedEntry] = []

    for rawLine in content.components(separatedBy: .newlines) {
        let line = rawLine.trimmingCharacters(in: .whitespaces)
        if line.isEmpty || line.hasPrefix("#") { continue }

        if line.contains("|") {
            let parts = line.components(separatedBy: "|")
            if parts.count >= 2 {
                let text = parts[0].trimmingCharacters(in: .whitespaces)
                let tagsStr = parts[1].trimmingCharacters(in: .whitespaces).uppercased()
                let tags = Set(tagsStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) })
                result.append(TaggedEntry(text: text, tags: tags))
            }
        }
    }
    return result
}

func parseTenues(_ content: String) -> [TenueEntry] {
    var result: [TenueEntry] = []

    for rawLine in content.components(separatedBy: .newlines) {
        let line = rawLine.trimmingCharacters(in: .whitespaces)
        if line.isEmpty || line.hasPrefix("#") { continue }

        let parts = line.components(separatedBy: "|")
        if parts.count >= 3 {
            let text = parts[0].trimmingCharacters(in: .whitespaces)
            let style = parts[1].trimmingCharacters(in: .whitespaces).uppercased()
            let tagsStr = parts[2].trimmingCharacters(in: .whitespaces).uppercased()
            let tags = Set(tagsStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) })
            result.append(TenueEntry(text: text, style: style, tags: tags))
        }
    }
    return result
}

// ============================================================
// CONSIGNES FIXES DU PROMPT
// ============================================================

let IDENTITY_LOCK = """
MANDATORY IDENTITY PRESERVATION — HIGHEST PRIORITY:

The woman in the generated image MUST be the EXACT SAME PERSON as the reference image uploaded by the user. This is a hard requirement, not a suggestion.

Copy EVERYTHING from the reference image EXACTLY:
- Same exact face shape and bone structure
- Same exact eye shape, eye color, iris pattern, and eyelid shape
- Same exact eyebrow shape, thickness, and color
- Same exact nose shape, nostril shape, and nose tip
- Same exact lip shape, lip thickness, and mouth width
- Same exact chin shape and jawline
- Same exact freckle pattern, placement, and density on the cheeks and nose
- Same exact skin tone and undertone
- Same exact hair color, hair texture, and hairline
- Same exact makeup state (if she wears makeup, keep it IDENTICAL. If she has no makeup, keep her bare face.)
- Same exact expression style and facial features

DO NOT invent a new face. DO NOT beautify. DO NOT enhance. DO NOT symmetrize. DO NOT change the age. DO NOT change the ethnicity. DO NOT change any feature even slightly.

If you cannot preserve her exact identity, do not generate the image.
"""

let COMPOSITION_RULE = """
CRITICAL COMPOSITION RULE:
Leave a large empty space above the subject's head. The top of the hair must be positioned at approximately 60-70% from the bottom of the frame, leaving 30-40% of empty space above. This empty space is intentional and must NOT be filled with anything. The subject's head must never touch the top edge of the frame.
"""

let MAKEUP_RULE = """
MAKEUP RULE — COPY EXACTLY WHAT YOU SEE:

Look at the reference image carefully:
- If she wears makeup (eyeliner, mascara, lipstick, foundation, blush), reproduce it EXACTLY as it is.
- If she has NO makeup, keep her completely bare face with zero makeup.

DO NOT add makeup if there is none. DO NOT remove makeup if there is some. Copy the reference EXACTLY as it is.
"""

let PHOTO_STYLE = """
The photo must look like a real unedited photo taken with an iPhone and pulled directly from a phone's camera roll. Slight ISO noise in shadow areas, subtle JPEG compression artifacts, natural indoor white balance. No beauty filter, no skin smoothing, no professional photography look, no studio lighting, no ring light.
"""

// ============================================================
// INTERFACE
// ============================================================

struct ContentView: View {
    @State private var formatSortie: String = "3:4"
    @State private var cadrage: String = "Miroir"
    @State private var modeDecors: String = "4 différents"
    @State private var modeTenues: String = "4 différents"

    @State private var styleSimple: Bool = true
    @State private var styleSexy: Bool = true
    @State private var styleChic: Bool = true
    @State private var styleStreetwear: Bool = true
    @State private var stylePlage: Bool = true
    @State private var styleTrescourt: Bool = true

    @State private var posturesActives: Set<String> = ["Debout", "Assise", "Allongée", "Mur", "Miroir Actif", "Selfie Bras Tendu"]
    @State private var prompts: [String] = []
    @State private var promptCategories: [String] = []
    @State private var showCopiedAlert = false
    @State private var copiedIndex = 0
    @State private var loadedCounts: String = ""
    @State private var showImporter = false
    @State private var importMessage: String = ""

    let formats = ["9:16", "3:4", "1:1", "4:5", "16:9", "2:3"]
    let cadragesUI = ["Miroir", "CamAvant", "Distance", "BrasTendu", "Aléatoire"]
    let modesRepartition = ["4 différents", "2 par 2", "Tous identiques"]

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.08, green: 0.05, blue: 0.15),
                    Color(red: 0.02, green: 0.02, blue: 0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.purple.opacity(0.15))
                .blur(radius: 80)
                .offset(x: -100, y: -200)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {

                    VStack(spacing: 6) {
                        Text("🎯 PromptGen")
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                            )
                        Text("Générateur de prompts photo")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.8))

                        if !loadedCounts.isEmpty {
                            Text(loadedCounts)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.green.opacity(0.8))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.top, 15)

                    cardSection(title: "📐 FORMAT DE SORTIE") {
                        Picker("Format", selection: $formatSortie) {
                            ForEach(formats, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.purple)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    cardSection(title: "📸 CADRAGE CAMÉRA") {
                        Picker("Cadrage", selection: $cadrage) {
                            ForEach(cadragesUI, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.purple)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    cardSection(title: "👗 STYLE DE TENUE (cocher)") {
                        VStack(alignment: .leading, spacing: 8) {
                            checkboxRow(label: "Simple", isOn: $styleSimple)
                            checkboxRow(label: "Sexy", isOn: $styleSexy)
                            checkboxRow(label: "Chic", isOn: $styleChic)
                            checkboxRow(label: "Streetwear", isOn: $styleStreetwear)
                            checkboxRow(label: "Plage", isOn: $stylePlage)
                            checkboxRow(label: "Très court", isOn: $styleTrescourt)
                        }
                    }

                    cardSection(title: "👗 RÉPARTITION TENUES") {
                        Picker("Tenues", selection: $modeTenues) {
                            ForEach(modesRepartition, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .tint(.purple)
                    }

                    cardSection(title: "🏠 DÉCORS") {
                        Picker("Décors", selection: $modeDecors) {
                            ForEach(modesRepartition, id: \.self) { Text($0).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        .tint(.purple)
                    }

                    cardSection(title: "🧍 POSTURES") {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(["Debout", "Assise", "Allongée", "Mur", "Miroir Actif", "Selfie Bras Tendu"], id: \.self) { p in
                                HStack {
                                    Image(systemName: posturesActives.contains(p) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(posturesActives.contains(p) ? .purple : .gray)
                                    Text(p)
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if posturesActives.contains(p) {
                                        posturesActives.remove(p)
                                    } else {
                                        posturesActives.insert(p)
                                    }
                                }
                            }
                        }
                    }

                    Button(action: generer) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("GÉNÉRER 4 PROMPTS")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)

                    Button(action: rechargerFichiers) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Recharger les fichiers")
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    Button(action: { showImporter = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("📥 Importer des fichiers .txt")
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    if !importMessage.isEmpty {
                        Text(importMessage)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.green.opacity(0.8))
                    }

                    Button(action: ouvrirDossier) {
                        HStack {
                            Image(systemName: "folder")
                            Text("📂 Ouvrir le dossier")
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)

                    if !prompts.isEmpty {
                        ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("=== PROMPT \(index + 1) — \(index < promptCategories.count ? promptCategories[index].uppercased() : "?") ===")
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(.purple)

                                Text(prompt)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)

                                Button(action: {
                                    UIPasteboard.general.string = prompt
                                    copiedIndex = index + 1
                                    showCopiedAlert = true
                                }) {
                                    HStack {
                                        Image(systemName: "doc.on.doc.fill")
                                        Text("Copier")
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.purple.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                            .padding(14)
                            .background(Color.black.opacity(0.4))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 40)
                }
            }
        }
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.plainText, .text],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                let n = FileManagerHelper.shared.importFiles(from: urls)
                importMessage = "✅ \(n) fichier(s) importé(s)"
                chargerFichiers()
            case .failure(let error):
                importMessage = "❌ \(error.localizedDescription)"
            }
        }
        .alert(isPresented: $showCopiedAlert) {
            Alert(
                title: Text("Copié ! 📋"),
                message: Text("Prompt \(copiedIndex) copié dans le presse-papiers."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            FileManagerHelper.shared.createDefaultFilesIfNeeded()
            chargerFichiers()
        }
    }

    func checkboxRow(label: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                .foregroundColor(isOn.wrappedValue ? .purple : .gray)
            Text(label)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isOn.wrappedValue.toggle()
        }
    }

    func cardSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.purple)
                .padding(.leading, 4)
            content()
        }
        .padding(14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    func chargerFichiers() {
        let fm = FileManagerHelper.shared
        let posturesContent = fm.loadFile(named: fm.posturesFile, defaultContent: DEFAULT_POSTURES)
        let expressionsContent = fm.loadFile(named: fm.expressionsFile, defaultContent: DEFAULT_EXPRESSIONS)
        let cadragesContent = fm.loadFile(named: fm.cadragesFile, defaultContent: DEFAULT_CADRAGES)
        let decorsContent = fm.loadFile(named: fm.decorsFile, defaultContent: DEFAULT_DECORS)
        let tenuesContent = fm.loadFile(named: fm.tenuesFile, defaultContent: DEFAULT_TENUES)

        let p = parsePostures(posturesContent).count
        let e = parseTaggedEntries(expressionsContent).count
        let c = parseTaggedEntries(cadragesContent).count
        let d = parseTaggedEntries(decorsContent).count
        let t = parseTenues(tenuesContent).count

        loadedCounts = "📁 P:\(p) E:\(e) C:\(c) D:\(d) T:\(t)"
    }

    func rechargerFichiers() {
        chargerFichiers()
    }

    func ouvrirDossier() {
        let fm = FileManagerHelper.shared
        fm.createDefaultFilesIfNeeded()

        // Ouvre l'app Fichiers directement dans le dossier Documents de l'app
        let path = fm.dataFolderURL.path
        if let url = URL(string: "shareddocuments://" + path) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func lettreCadrage(_ c: String) -> [String] {
        switch c {
        case "Miroir": return ["M"]
        case "CamAvant": return ["C"]
        case "Distance": return ["D"]
        case "BrasTendu": return ["S"]
        case "Aléatoire": return ["C", "M", "D", "S"]
        default: return ["M"]
        }
    }

    func filtrerParBalise(_ liste: [TaggedEntry], lettre: String) -> [String] {
        return liste.filter { $0.tags.contains(lettre) || $0.tags.contains("ALL") }.map { $0.text }
    }

    func filtrerTenuesParStyleEtBalise(_ liste: [TenueEntry], stylesChoisis: Set<String>, lettre: String) -> [String] {
        return liste.filter { tenue in
            stylesChoisis.contains(tenue.style) &&
            (tenue.tags.contains(lettre) || tenue.tags.contains("ALL"))
        }.map { $0.text }
    }

    func formatTexte(_ f: String) -> String {
        switch f {
        case "9:16": return "9:16 vertical portrait orientation"
        case "3:4": return "3:4 portrait orientation"
        case "1:1": return "1:1 square format"
        case "4:5": return "4:5 vertical portrait format"
        case "16:9": return "16:9 horizontal landscape format"
        case "2:3": return "2:3 traditional portrait format"
        default: return "3:4 portrait orientation"
        }
    }

    func tirerSansRepetition(_ liste: [String], n: Int) -> [String] {
        if liste.isEmpty { return [] }
        var pool = liste
        var resultats: [String] = []
        for _ in 0..<n {
            if pool.isEmpty { pool = liste }
            let idx = Int.random(in: 0..<pool.count)
            resultats.append(pool.remove(at: idx))
        }
        return resultats
    }

    func repartir(_ liste: [String], mode: String) -> [String] {
        if liste.isEmpty { return ["simple outfit"] }
        switch mode {
        case "4 différents":
            return tirerSansRepetition(liste, n: 4)
        case "2 par 2":
            let deux = tirerSansRepetition(liste, n: 2)
            if deux.count >= 2 {
                return [deux[0], deux[0], deux[1], deux[1]]
            } else {
                return [deux[0], deux[0], deux[0], deux[0]]
            }
        default:
            let un = liste.randomElement() ?? liste[0]
            return [un, un, un, un]
        }
    }

    func generer() {
        let fm = FileManagerHelper.shared
        let posturesContent = fm.loadFile(named: fm.posturesFile, defaultContent: DEFAULT_POSTURES)
        let expressionsContent = fm.loadFile(named: fm.expressionsFile, defaultContent: DEFAULT_EXPRESSIONS)
        let cadragesContent = fm.loadFile(named: fm.cadragesFile, defaultContent: DEFAULT_CADRAGES)
        let decorsContent = fm.loadFile(named: fm.decorsFile, defaultContent: DEFAULT_DECORS)
        let tenuesContent = fm.loadFile(named: fm.tenuesFile, defaultContent: DEFAULT_TENUES)

        let allPostures = parsePostures(posturesContent)
        let allExpressions = parseTaggedEntries(expressionsContent)
        let allCadrages = parseTaggedEntries(cadragesContent)
        let allDecors = parseTaggedEntries(decorsContent)
        let allTenues = parseTenues(tenuesContent)

        var stylesChoisis: Set<String> = []
        if styleSimple { stylesChoisis.insert("SIMPLE") }
        if styleSexy { stylesChoisis.insert("SEXY") }
        if styleChic { stylesChoisis.insert("CHIC") }
        if styleStreetwear { stylesChoisis.insert("STREETWEAR") }
        if stylePlage { stylesChoisis.insert("PLAGE") }
        if styleTrescourt { stylesChoisis.insert("TRESCOURT") }

        if stylesChoisis.isEmpty {
            stylesChoisis = ["SIMPLE"]
        }

        let lettres = lettreCadrage(cadrage)

        var categoriesDisponibles: [String] = []
        for cat in posturesActives {
            if allPostures.contains(where: { $0.category == cat }) {
                categoriesDisponibles.append(cat)
            }
        }
        if categoriesDisponibles.isEmpty { categoriesDisponibles = ["Debout"] }
        var categoriesChoisies: [String] = []
        var poolCats = categoriesDisponibles
        for _ in 0..<4 {
            if poolCats.isEmpty { poolCats = categoriesDisponibles }
            let idx = Int.random(in: 0..<poolCats.count)
            categoriesChoisies.append(poolCats.remove(at: idx))
        }

        var posturesFinales: [String] = []
        for (i, cat) in categoriesChoisies.enumerated() {
            let lettre = lettres[i % lettres.count]
            let pool = allPostures.filter { $0.category == cat && ($0.tags.contains(lettre) || $0.tags.contains("ALL")) }
            let choix = pool.randomElement()?.text ?? (allPostures.first(where: { $0.category == cat })?.text ?? "standing naturally")
            posturesFinales.append(choix)
        }

        var poolCadragesGlobal: [String] = []
        for (i, _) in (0..<4).enumerated() {
            let lettre = lettres[i % lettres.count]
            poolCadragesGlobal.append(contentsOf: filtrerParBalise(allCadrages, lettre: lettre))
        }
        poolCadragesGlobal = Array(Set(poolCadragesGlobal))
        let cadragesFinaux = tirerSansRepetition(poolCadragesGlobal, n: 4)

        var poolExpressionsGlobal: [String] = []
        for (i, _) in (0..<4).enumerated() {
            let lettre = lettres[i % lettres.count]
            poolExpressionsGlobal.append(contentsOf: filtrerParBalise(allExpressions, lettre: lettre))
        }
        poolExpressionsGlobal = Array(Set(poolExpressionsGlobal))
        let expressionsFinales = tirerSansRepetition(poolExpressionsGlobal, n: 4)

        var poolDecorsGlobal: [String] = []
        for (i, _) in (0..<4).enumerated() {
            let lettre = lettres[i % lettres.count]
            poolDecorsGlobal.append(contentsOf: filtrerParBalise(allDecors, lettre: lettre))
        }
        poolDecorsGlobal = Array(Set(poolDecorsGlobal))
        let decorsFinaux = repartir(poolDecorsGlobal, mode: modeDecors)

        var poolTenuesGlobal: [String] = []
        for (i, _) in (0..<4).enumerated() {
            let lettre = lettres[i % lettres.count]
            poolTenuesGlobal.append(contentsOf: filtrerTenuesParStyleEtBalise(allTenues, stylesChoisis: stylesChoisis, lettre: lettre))
        }
        poolTenuesGlobal = Array(Set(poolTenuesGlobal))
        let tenuesFinales = repartir(poolTenuesGlobal, mode: modeTenues)

        var resultats: [String] = []
        for i in 0..<4 {
            let posture = i < posturesFinales.count ? posturesFinales[i] : "standing naturally"
            let cadr = i < cadragesFinaux.count ? cadragesFinaux[i] : ""
            let expr = i < expressionsFinales.count ? expressionsFinales[i] : "with a calm expression"
            let dec = i < decorsFinaux.count ? decorsFinaux[i] : "a cozy bedroom"
            let ten = i < tenuesFinales.count ? tenuesFinales[i] : "a simple outfit"

            let prompt = """
            \(IDENTITY_LOCK)

            PHOTO SPECIFICATIONS:
            A highly detailed, high-resolution photo taken on an iPhone. Format: \(formatTexte(formatSortie)). Single image only.

            \(COMPOSITION_RULE)

            \(MAKEUP_RULE)

            SCENE:
            \(cadr),
            featuring her \(expr), showing her \(posture),
            wearing \(ten),
            in \(dec).

            \(PHOTO_STYLE)

            FINAL REMINDER: The face must be an EXACT COPY of the reference image. Do not change any feature. Do not beautify. Do not invent a new face.
            """

            resultats.append(prompt)
        }

        prompts = resultats
        promptCategories = categoriesChoisies
    }
}
