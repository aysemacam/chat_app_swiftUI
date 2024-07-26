//
//  ImagePicker.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var didFinishPicking: (UIImage?, URL?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(didFinishPicking: didFinishPicking)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.mediaTypes = ["public.image", "public.movie"]
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var didFinishPicking: (UIImage?, URL?) -> Void
        
        init(didFinishPicking: @escaping (UIImage?, URL?) -> Void) {
            self.didFinishPicking = didFinishPicking
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                didFinishPicking(uiImage, nil)
            } else if let videoURL = info[.mediaURL] as? URL {
                didFinishPicking(nil, videoURL)
            } else {
                didFinishPicking(nil, nil)
            }
            picker.dismiss(animated: true)
        }
    }
}
