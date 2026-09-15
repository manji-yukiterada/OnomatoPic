import Foundation
import SwiftData

@Model
final class PhotoRecord{
    @Attribute(.unique) var id: UUID = UUID()
    var capturedAt: Date
    var createdAt: Date
    var imageFileName: String
    var sceneNote: String
    var analysisVersion: String
    var representativeFindingID: UUID?
    var latitude: Double?
    var longitude: Double?
    var locationHorizontalAccuracy: Double?
    var locationCapturedAt: Date?
//    var analysisStatus: String
    
    @Relationship(deleteRule: .cascade, inverse: \OnomatopeFinding.photo)
    var findings: [OnomatopeFinding]
    
    init(id: UUID = UUID(),
         capturedAt: Date = .now,
         createdAt: Date = .now,
         imageFileName: String,
         sceneNote: String = "",
         analysisVersion: String = "mock-1",
         representativeFindingID: UUID? = nil,
         latitude: Double? = nil,
         longitude: Double? = nil,
         locationHorizontalAccuracy: Double? = nil,
         locationCapturedAt: Date? = nil,
         findings: [OnomatopeFinding] = []
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.createdAt = createdAt
        self.imageFileName = imageFileName
        self.sceneNote = sceneNote
        self.analysisVersion = analysisVersion
        self.representativeFindingID = representativeFindingID
        self.latitude = latitude
        self.longitude = longitude
        self.locationHorizontalAccuracy = locationHorizontalAccuracy
        self.locationCapturedAt = locationCapturedAt
        self.findings = findings
    }
    
    var representativeFinding: OnomatopeFinding? {
        guard let representativeFindingID else { return findings.sorted { $0.displayOrder < $1.displayOrder }.first }
        return findings.first { $0.id == representativeFindingID }
    }
    
    func setRepresentative(_ finding: OnomatopeFinding) {
        guard findings.contains(where: { $0.id == finding.id }) else { return }
        representativeFindingID = finding.id
    }
}

@Model
final class OnomatopeFinding {
    @Attribute(.unique) var id: UUID
    var word: String
    var wordKey: String
    var reading: String
    var meaning: String
    var targetDescription: String
    var applicabilityNote: String
    var examplePrefix: String
    var exampleSuffix: String
    var quizHint: String
    var quizExplanation: String
    var isQuizEligible: Bool
    var displayOrder: Int
    
    var photo: PhotoRecord?
    
    init(
        id: UUID = UUID(),
        word: String,
        reading: String,
        meaning: String,
        targetDescription: String,
        applicabilityNote: String = "",
        examplePrefix: String,
        exampleSuffix: String,
        quizHint: String = "",
        quizExplanation: String = "",
        isQuizEligible: Bool = true,
        displayOrder: Int = 0,
        photo: PhotoRecord? = nil
    ) {
        self.id = id
        self.word = word
        self.wordKey = Self.normalize(word)
        self.reading = reading
        self.meaning = meaning
        self.targetDescription = targetDescription
        self.applicabilityNote = applicabilityNote
        self.examplePrefix = examplePrefix
        self.exampleSuffix = exampleSuffix
        self.quizHint = quizHint
        self.quizExplanation = quizExplanation
        self.isQuizEligible = isQuizEligible
        self.displayOrder = displayOrder
        self.photo = photo
    }
    var exampleSentence: String { examplePrefix + word + exampleSuffix }
    var clozeSentence: String { examplePrefix + "（　）" + exampleSuffix }
    
    static func normalize(_ word: String) -> String {
        word.trimmingCharacters(in: .whitespacesAndNewlines)
            .precomposedStringWithCanonicalMapping
    }
}

enum SampleData {
    static func insertIfNeeded(in context: ModelContext) {
        let descriptor = FetchDescriptor<PhotoRecord>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        let photo = PhotoRecord(
            imageFileName: "sample-flower",
            sceneNote: "花が風に揺れている"
        )
        let findings = [
            OnomatopeFinding(
                word: "ゆらゆら", reading: "ゆらゆら",
                meaning: "左右にゆっくり繰り返し揺れる様子",
                targetDescription: "花の茎や花全体",
                applicabilityNote: "風を受けて花が揺れる動き",
                examplePrefix: "花が風に吹かれて",
                exampleSuffix: "と揺れている。",
                quizHint: "左右にゆっくり繰り返し揺れる様子。",
                quizExplanation: "花の揺れる動きに注目した表現です。",
                displayOrder: 0,
                photo: photo
            ),
            OnomatopeFinding(
                word: "そよそよ", reading: "そよそよ",
                meaning: "弱い風が静かに吹く様子",
                targetDescription: "花の周りの風",
                applicabilityNote: "穏やかな風を表すときの表現",
                examplePrefix: "風が",
                exampleSuffix: "と吹いている。",
                quizHint: "弱く穏やかな風が静かに吹く様子。",
                quizExplanation: "揺れ方ではなく、風そのものの穏やかさを表します。",
                displayOrder: 1,
                photo: photo
            ),
            OnomatopeFinding(
                word: "ふわふわ", reading: "ふわふわ",
                meaning: "軽く柔らかそうな様子",
                targetDescription: "花びらの柔らかな印象",
                applicabilityNote: "写真から感じる柔らかな質感",
                examplePrefix: "この花びらは",
                exampleSuffix: "している。",
                quizHint: "軽く柔らかそうな様子。",
                quizExplanation: "揺れや風よりも、軽さ・柔らかさに注目した表現です。",
                displayOrder: 2,
                photo: photo
            )
        ]
        photo.findings = findings
        photo.representativeFindingID = findings[1].id
        context.insert(photo)
        try? context.save()
    }
}

//enum ImageFileStore {
//    static func save(_ data: Data) throws -> String {
//        let fileName = "\(UUID().uuidString).jpg"
//        
//        let folderURL = FileManager.default.urls(
//                    for: .applicationSupportDirectory,
//                    in: .userDomainMask
//                )[0]
//        
//        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
//        
//        let fileURL = folderURL.appendingPathComponent(fileName)
//        try data.write(to: fileURL)
//        
//        return fileName
//    }
//}
