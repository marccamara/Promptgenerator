import SwiftUI
import UIKit

// ============================================================
// DONNÉES EXTERNES
// ============================================================

let POSTURES: [String: [(String, String)]] = [
    "Debout": [
        ("standing naturally with weight shifted to one hip, one hand in pocket", "C,M,D,S"),
        ("standing by a window looking outside, arms loosely crossed", "C,M,D"),
        ("standing with one hand on hip and the other touching hair", "C,M,S"),
        ("standing straight with both arms at sides, shoulders relaxed", "C,M,D"),
        ("leaning slightly forward with hands clasped in front", "C,D"),
        ("standing with one foot forward, hands in back pockets", "M,D"),
        ("standing with arms crossed, weight on one leg", "C,M,D")
    ],
    "Assise": [
        ("sitting on the edge of a bed with legs crossed, hands on knees", "C,D"),
        ("sitting cross-legged on a couch, hands resting on thighs", "C,D"),
        ("sitting on a chair leaning back slightly, one arm on the backrest", "C,D"),
        ("sitting on the floor with knees pulled up, arms wrapped around them", "D"),
        ("sitting on a windowsill with legs dangling, palms flat", "C,D"),
        ("sitting on a stool with legs crossed at ankles, hands on lap", "C,D")
    ],
    "Allongée": [
        ("lying flat on a bed on her back, arms relaxed at sides", "C,D"),
        ("lying on her side with one arm under her head, knees slightly bent", "C,D"),
        ("lying on her stomach propped up on elbows, looking forward", "C,D"),
        ("lying diagonally across a bed with arms stretched above head", "C,D")
    ],
    "Mur": [
        ("leaning against a wall with one shoulder, hands in pockets", "C,M,D"),
        ("leaning against a wall with one foot flat on it behind her", "C,M,D"),
        ("back flat against a wall, arms crossed, looking straight ahead", "C,M,D"),
        ("leaning against a doorway frame, one hand on the frame", "C,M,D"),
        ("pressed gently against a wall, looking sideways, hands behind back", "C,M,D")
    ],
    "Miroir Actif": [
        ("taking a quick mirror selfie holding phone at chest height", "M"),
        ("full-length mirror selfie showing the whole outfit", "M"),
        ("half-body mirror selfie with one hand on hip, phone in the other", "M"),
        ("side mirror selfie, head turned slightly, phone raised to eye level", "M")
    ],
    "Selfie Bras Tendu": [
        ("holding phone at arm's length with one arm extended, front camera", "S"),
        ("taking a quick selfie with the phone raised at eye level", "S"),
        ("selfie with the phone held slightly above eye level", "S"),
        ("selfie with the phone held at chest level, looking down slightly", "S")
    ]
]

let EXPRESSIONS: [(String, String)] = [
    ("looking directly at the lens with a calm and collected demeanor", "ALL"),
    ("looking sideways with a subtle moody aesthetic", "ALL"),
    ("gazing softly into the distance with a dreamy expression", "ALL"),
    ("looking at the camera with a natural slight smile", "C,S"),
    ("looking at the mirror reflection with a playful expression", "M"),
    ("caught in a candid moment, looking away from the camera", "D"),
    ("expressing quiet confidence with a relaxed gaze", "ALL"),
    ("giving a soft half-smile with a hint of shyness", "M,C,S"),
    ("with a neutral calm expression, lips slightly parted", "ALL"),
    ("with a warm friendly expression, eyes slightly narrowed", "M,C,S")
]

let CADRAGES: [(String, String)] = [
    ("front camera selfie at 30cm from face, 24mm equivalent lens, f/2.2, ISO 400, natural indoor window light coming from the left, soft diffused shadows, slightly warm white balance, shallow depth of field with blurred background, slight motion blur", "C"),
    ("front camera selfie at 40cm from face, 26mm lens, f/2.0, ISO 320, soft daylight from a window behind the camera, even lighting on the face, neutral white balance, medium depth of field, sharp focus on eyes", "C"),
    ("mirror selfie at 50cm from the mirror, 26mm lens, f/2.2, ISO 400, natural daylight from a window on the left, soft shadows on the right side of the face, neutral white balance, background slightly out of focus, sharp handheld", "M"),
    ("mirror selfie at 1 meter from mirror, 24mm lens, f/2.0, ISO 500, warm ambient bedroom light, soft diffused shadows, warm color cast, medium depth of field, slight natural handheld tilt", "M"),
    ("rear camera photo at 6 meters from subject, 100mm telephoto equivalent lens, f/2.8, ISO 200, natural daylight from a large window, soft directional shadows, neutral white balance, shallow depth of field with blurred background, sharp and stable", "D"),
    ("rear camera photo at 4 meters from subject, 50mm lens, f/2.0, ISO 320, soft afternoon daylight, even lighting, slightly warm tone, medium depth of field, natural handheld stability", "D"),
    ("selfie with arm fully extended at 60cm from face, 24mm lens, f/2.2, ISO 400, natural daylight from window, soft shadows, neutral white balance, moderate background blur, slight handheld motion", "S"),
    ("selfie with phone raised above eye level at 50cm, 26mm lens, f/2.0, ISO 320, soft indoor lighting, even exposure, neutral color, medium depth of field, sharp", "S")
]

let DECORS: [(String, String)] = [
    ("a cozy bedroom with an unmade bed, warm ambient light, clothes on a chair", "ALL"),
    ("a sunlit modern apartment bedroom with soft white linens and wooden furniture", "ALL"),
    ("a bohemian style bedroom with macrame, plants, and fairy lights", "ALL"),
    ("a minimalist bedroom with plain walls and a large floor mirror", "ALL"),
    ("a modern living room with a sofa, a plant, and framed art", "ALL"),
    ("a cozy café terrace with a coffee cup on the table, natural daylight", "C,S"),
    ("a city street with blurred passersby, daylight, candid moment", "D"),
    ("a park bench surrounded by trees, golden hour lighting", "D"),
    ("a bathroom with a large mirror, warm light, plants on shelves", "M")
]

// ============================================================
// INTERFACE
// ============================================================

struct ContentView: View {
    @State private var formatSortie: String = "3:4"
    @State private var cadrage: String = "Miroir"
    @State private var tenue: String = ""
    @State private var posturesActives: Set<String> = ["Debout", "Assise", "Allongée", "Mur", "Miroir Actif", "Selfie Bras Tendu"]
    @State private var prompts: [String] = []
    @State private var showCopiedAlert = false
    @State private var copiedIndex = 0

    let formats = ["9:16", "3:4", "1:1", "4:5", "16:9", "2:3"]
    let cadragesUI = ["Miroir", "CamAvant", "Distance", "BrasTendu", "Aléatoire"]

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

                    cardSection(title: "👗 DESCRIPTION DE LA TENUE") {
                        ZStack(alignment: .topLeading) {
                            if tenue.isEmpty {
                                Text("Colle ta description de tenue...")
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 10)
                            }
                            TextEditor(text: $tenue)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white)
                                .frame(height: 80)
                                .background(Color.clear)
                                .opacity(tenue.isEmpty ? 0.7 : 1)
                        }
                        .padding(6)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
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

                    if !prompts.isEmpty {
                        ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                            VStack(alignment: .leading, spacing: 8) {
                                Text("=== PROMPT \(index + 1) ===")
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
        .alert(isPresented: $showCopiedAlert) {
            Alert(
                title: Text("Copié ! 📋"),
                message: Text("Prompt \(copiedIndex) copié dans le presse-papiers."),
                dismissButton: .default(Text("OK"))
            )
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

    func filtrerParBalise(_ liste: [(String, String)], lettre: String) -> [String] {
        return liste.filter { $0.1.contains(lettre) || $0.1.contains("ALL") }.map { $0.0 }
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

    func generer() {
        let lettres = lettreCadrage(cadrage)
        var resultats: [String] = []

        let tenueFinale = tenue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "a simple casual outfit"
            : tenue

        var poolPostures: [String] = []
        for cat in posturesActives {
            if let arr = POSTURES[cat] {
                poolPostures.append(contentsOf: arr.map { $0.0 })
            }
        }
        if poolPostures.isEmpty { poolPostures = ["standing naturally"] }

        for i in 0..<4 {
            let lettre = lettres[i % lettres.count]

            let poolCadrages = filtrerParBalise(CADRAGES, lettre: lettre)
            let poolExpressions = filtrerParBalise(EXPRESSIONS, lettre: lettre)
            let poolDecors = filtrerParBalise(DECORS, lettre: lettre)

            let posture = poolPostures.randomElement() ?? "standing naturally"
            let cadr = poolCadrages.randomElement() ?? ""
            let expr = poolExpressions.randomElement() ?? "looking at the camera"
            let dec = poolDecors.randomElement() ?? "a cozy bedroom"

            let prompt = """
            A highly detailed, high-resolution photo taken on an iPhone. Format: \(formatTexte(formatSortie)). Single image only.

            CRITICAL COMPOSITION RULE: Leave a large empty space above the subject's head. The top of the hair must be positioned at approximately 60-70% from the bottom of the frame, leaving 30-40% of empty space above. This empty space is intentional and must NOT be filled with anything. The subject's head must never touch the top edge of the frame.

            CRITICAL: The woman in the generated image must be IDENTICAL to the reference image. Copy her exact face shape, exact eye shape and color, exact nose shape, exact lip shape, exact eyebrow shape, exact freckle pattern on cheeks and nose. Do NOT beautify, do NOT enhance, do NOT change any feature.

            Completely bare face with absolutely zero makeup. No eyeliner, no mascara, no fake eyelashes, no lipstick, no lip gloss, no foundation, no powder, no drawn eyebrows, no blush. Her lips must be natural matte pink, not red, not glossy. Her eyes must have natural short lashes. Her eyebrows must be natural and unfilled. Her skin must show visible pores, natural freckles, and slight natural redness on the cheeks.

            \(cadr),

            featuring her with \(expr), showing her \(posture),

            wearing \(tenueFinale),

            in \(dec).

            The photo must look like a real unedited photo taken with an iPhone and pulled directly from a phone's camera roll. Slight ISO noise in shadow areas, subtle JPEG compression artifacts, natural indoor white balance. No beauty filter, no skin smoothing, no professional photography look, no studio lighting, no ring light.
            """

            resultats.append(prompt)
        }

        prompts = resultats
    }
}
