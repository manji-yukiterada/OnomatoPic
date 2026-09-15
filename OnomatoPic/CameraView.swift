import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    let onCancel: () -> Void
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}
    
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraView
        init(_ parent: CameraView) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.onImageCaptured(image) }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.onCancel() }
    }
}
