import SwiftUI
import SwiftData

struct CollectionView: View {
    @Query(sort: \PhotoRecord.createdAt, order:.reverse)private var photos: [PhotoRecord]
    @State var selectedPhoto: PhotoRecord? = nil
    @State var showingWords: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("表示",selection: $showingWords)
                {
                    Text("写真").tag(false)
                    Text("ことば").tag(true)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if showingWords {
                    WordListView(photos: photos)
                } else if photos.isEmpty {
                    ContentUnavailableView("まだカードがありません", systemImage: "rectangle.stack", description: Text("「撮る」から最初の写真を追加できます。"))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 18) {
                            ForEach(photos) { photo in
                                PhotoCardFront(photo: photo)
                                    .onTapGesture { selectedPhoto = photo }
                            }
                        }
                        .padding()
                    }
                }
                
            }
            .navigationTitle("OnomatoPic")
            .sheet(item: $selectedPhoto) { photo in
                CardReaderView(photos: photos, initialPhotoID: photo.id)
            }
        }
    }
}
