import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 1
    @State private var showingCamera = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraPlaceholderView().tabItem { Label("撮る", systemImage: "camera") }.tag(0)
            //            Color.clear.tabItem { Label("撮る", systemImage: "camera") }.tag(0)
            CollectionView().tabItem{ Label("一覧", systemImage: "list.bullet").tag(1)
                ReviewPlaceholderView().tabItem { Label("クイズ", systemImage: "q.circle") }.tag(2)
            }
            .task { SampleData.insertIfNeeded(in: modelContext)}
            .onChange(of: selectedTab) { _, newValue in
                if newValue == 0 {
                    showingCamera = true
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraCaptureView()
            }
            .onChange(of: showingCamera) { _, isShowing in
                if !isShowing && selectedTab == 0 {
                    selectedTab = 1
                }
            }
        }
    }
}

struct PhotoCardFront: View {
    let photo: PhotoRecord
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Group {
                if let data = ImageFileStore.load(fileName: photo.imageFileName),
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let image = UIImage(named: photo.imageFileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .mint.opacity(0.75),
                                    .indigo.opacity(0.75)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
            
            VStack(alignment: .leading, spacing: 6) {
                Text(photo.capturedAt, format: .dateTime.year().month().day())
                    .font(.caption)
                Text(photo.sceneNote.isEmpty ? "写真カード" : photo.sceneNote)
                    .font(.caption)
                Text(photo.representativeFinding?.word ?? "未設定")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .shadow(color: .black, radius: 5, x: 2, y: 2)
            }
            .foregroundStyle(.white)
            .padding(20)
            
        }
        .aspectRatio(3.0 / 4.0, contentMode: .fill)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct FlipCard: View{
    let photo: PhotoRecord
    @State private var isBack = false
    
    var body: some View {
        Group {
            if isBack { CardBack(photo: photo) } else { PhotoCardFront(photo: photo) }
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { isBack.toggle() } }
        .accessibilityHint("タップするとカードの表裏を切り替えます")
    }
}

struct CardBack: View {
    let photo: PhotoRecord
    
    var body: some View {
        ZStack {
            // 表面と同じ写真を背景に表示
            Group {
                if let data = ImageFileStore.load(fileName: photo.imageFileName),
                   let image = UIImage(data: data) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let image = UIImage(named: photo.imageFileName) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color.gray
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .opacity(0.18)
            
            // 写真を薄くするための白い膜
//            RoundedRectangle(cornerRadius: 24)
//                .fill(.white.opacity(0.72))
            
            // 裏面の文字
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    Text(
                        photo.sceneNote.isEmpty
                        ? "この写真のオノマトペ"
                        : photo.sceneNote
                    )
                    .font(.headline)
                    
                    ForEach(
                        photo.findings.sorted {
                            $0.displayOrder < $1.displayOrder
                        }
                    ) { finding in
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text(finding.word)
                                    .font(.title.bold())
                                
                                if finding.id == photo.representativeFindingID {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.gray)
                                }
                            }
                            
                            Text(finding.meaning)
                                .font(.body)
                            
                            Text(finding.applicabilityNote)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            
                            Text(finding.exampleSentence)
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(22)
            }
        }
        // 表面と同じ縦横比
        .aspectRatio(3.0 / 4.0, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.6), lineWidth: 1)
        }
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
