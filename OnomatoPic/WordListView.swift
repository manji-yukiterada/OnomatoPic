import SwiftUI

struct WordListView: View {
    let photos: [PhotoRecord]
    struct WordGroup: Identifiable {
        let id: String
        let word: String
        let findings: [OnomatopeFinding]
    }
    var groups: [WordGroup] {
        Dictionary(grouping: photos.flatMap(\.findings), by: { $0.wordKey})
            .map { WordGroup(id: $0.key, word: $0.value.first?.word ?? $0.key, findings: $0.value) }
            .sorted{ $0.word < $1.word }
    }
    var body: some View{
        List(groups) { group in
            VStack(alignment: .leading) {
                Text(group.word).font(.title3.bold())
                Text("\(group.findings.count)件見つかりました").font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
