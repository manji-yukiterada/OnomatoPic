import SwiftUI
import SwiftData

struct CardReaderView: View {
    let photos: [PhotoRecord]
    let initialPhotoID: UUID
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        NavigationStack{
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 28) {
                        ForEach(photos) { photo in
                            FlipCard(photo: photo).id(photo.id)
                        }
                    }
                    .padding()
                }
                .onAppear { proxy.scrollTo(initialPhotoID, anchor: .top) }
            }
            .navigationTitle(Text("カード"))
            .toolbar { ToolbarItem(placement: .topBarTrailing){Button("閉じる"){dismiss()} }
            }
        }
    }
}
