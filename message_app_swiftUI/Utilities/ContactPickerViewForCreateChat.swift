//
//  ContactPickerViewForCreateChat.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 31.07.2024.
//

import SwiftUI
import ContactsUI


struct ContactPickerViewForCreateChat: UIViewControllerRepresentable {
    var completionHandler: (CNContact?) -> Void
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(completionHandler: completionHandler)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var completionHandler: (CNContact?) -> Void
        
        init(completionHandler: @escaping (CNContact?) -> Void) {
            self.completionHandler = completionHandler
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            completionHandler(contact)
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            completionHandler(nil)
        }
    }
}
