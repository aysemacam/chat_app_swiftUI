//
//  ContactPickerView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 29.07.2024.
//

import SwiftUI
import Contacts
import ContactsUI

struct ContactPickerView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var selectedContact: CNContact?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    class Coordinator: NSObject, CNContactPickerDelegate {
        var parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
            let phoneNumbers = contact.phoneNumbers.compactMap { $0.value.stringValue }.joined(separator: ", ")
            let messageText = "Name: \(name)\nPhone: \(phoneNumbers)"
            
            parent.selectedContact = contact
            parent.isPresented = false
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.isPresented = false
        }
    }
}
