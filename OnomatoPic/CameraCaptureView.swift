import SwiftUI
import UIKit
import SwiftData

struct CameraCaptureView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var capturedImage: UIImage?
    @State private var sceneNote = ""
    @State private var showingCamera = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Group {
                if let capturedImage {
                    VStack(spacing: 18) {
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        TextField("状況メモ（例：花が風に揺れている）", text: $sceneNote)
                            .textFieldStyle(.roundedBorder)
                        Button("この写真を追加") { savePhoto(capturedImage) }
                            .buttonStyle(.borderedProminent)
//                        Button("撮り直す") {
//                            self.capturedImage = nil
//                            showingCamera = true
//                        }
                    }
                    .padding()
                } else {
                    ContentUnavailableView("カメラを起動しています", systemImage: "camera", description: Text("撮影後に写真を確認して追加できます。"))
                }
            }
            .navigationTitle("写真を追加")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button("閉じる") {
                self.capturedImage = nil
                showingCamera = true
            } } }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView(
                    onImageCaptured: { image in
                        capturedImage = image
                        showingCamera = false
                    },
                    onCancel: {
                        showingCamera = false
                        if capturedImage == nil { dismiss() }
                    }
                )
                .ignoresSafeArea()
            }
            .alert("写真を追加できませんでした", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("閉じる", role: .cancel) {}
            } message: { Text(errorMessage ?? "") }
        }
    }
    
    private func savePhoto(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else {
            errorMessage = "画像の変換に失敗しました。"
            return
        }
        do {
            let fileName = try ImageFileStore.save(data)
            let photo = PhotoRecord(
                capturedAt: .now,
                imageFileName: fileName,
                sceneNote: sceneNote,
//                analysisStatus: "pending"
            )
            modelContext.insert(photo)
            try modelContext.save()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
