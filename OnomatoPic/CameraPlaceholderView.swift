import SwiftUI

struct CameraPlaceholderView : View {
    @State private var showingCamera = false

       var body: some View {
           VStack(spacing: 24) {
               Image(systemName: "camera.fill")
                   .font(.system(size: 60))
                   .foregroundStyle(.blue)

               Text("写真を撮影して\nオノマトペを見つけよう")
                   .font(.title2.bold())
                   .multilineTextAlignment(.center)

               Button {
                   showingCamera = true
               } label: {
                   Label("カメラを起動", systemImage: "camera")
                       .frame(maxWidth: .infinity)
               }
               .buttonStyle(.borderedProminent)
               .padding(.horizontal, 40)
           }
           .padding()
           .fullScreenCover(isPresented: $showingCamera) {
               CameraCaptureView()
           }
       }
}
