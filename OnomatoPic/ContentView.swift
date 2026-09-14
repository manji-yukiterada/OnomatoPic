import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraPlaceholderView().tabItem { Label("撮る", systemImage: "camera") }.tag(0)
            CollectionView().tabItem{ Label("一覧", systemImage: "list.bullet").tag(1)
            ReviewPlaceholderView().tabItem { Label("クイズ", systemImage: "q.circle") }.tag(2)
            }
            .task { SampleData.insertIfNeeded(in: modelContext)}
        }
    }
}

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
                            //                                FlipCard(photo: photo).id(photo.id)
                            
                            Group {
                                PhotoCardFront(photo: photo)
                            }
                            .contentShape(Rectangle())
                            .accessibilityHint("タップするとカードの表裏を切り替えます")
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
    
    struct PhotoCardFront: View {
        let photo: PhotoRecord
        var body: some View {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(LinearGradient(colors:[.mint.opacity(0.75), .indigo.opacity(0.75)],startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 260)
                VStack(alignment: .leading, spacing: 6) {
                    Text(photo.capturedAt, format: .dateTime.year().month().day())
                        .font(.caption)
                    Text(photo.sceneNote.isEmpty ? "写真カード" : photo.sceneNote)
                        .font(.headline)
                    Text(photo.representativeFinding?.word ?? "未設定")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.white)
                .padding(20)
                
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("写真。\(photo.representativeFinding?.word ?? "未設定")")
        }
    }
    
    struct ReviewPlaceholderView : View {
        var body : some View {
            ContentUnavailableView("初期問題はまだ",systemImage:  "checkmark.circle", description: Text("クイズ機能はカード閲覧の後。"))
        }
    }
#Preview {
    ContentView().modelContainer(for: [PhotoRecord.self, OnomatopeFinding.self], inMemory: true)
}
