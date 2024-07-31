//
//  ContactMessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import Contacts
import ContactsUI
import SwiftUI

struct ContactMessageView: View {
    let contact: CNContact
    @State private var isShowingContactEditor = false
    @State private var isNavigatingToMessageView = false
    @State private var selectedUser: User?
    @State private var navigationTrigger = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let imageData = contact.thumbnailImageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: 1)
                }

                VStack(alignment: .leading) {
                    Text(CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name")
                        .font(.headline)
                    Text(contact.phoneNumbers.first?.value.stringValue ?? "No Phone Number")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Divider()

            HStack(spacing: 0) {
                NavigationLink(destination: MessageView(user: selectedUser ?? User(username: "", userPhoto: Data())), isActive: $isNavigatingToMessageView) {
                    EmptyView()
                }
                
                Button(action: {
                    let contactUsername = CNContactFormatter.string(from: contact, style: .fullName) ?? "No Name"
                    var users = DataManager.shared.fetchUsers()
                    
                    if let existingUser = users.first(where: { $0.username == contactUsername }) {
                        self.selectedUser = existingUser
                    } else {
                        let newUser = User(
                            username: contactUsername,
                            userPhoto: UIImage(systemName: "person.crop.circle")!.jpegData(compressionQuality: 1.0)!
                        )
                        users.append(newUser)
                        DataManager.shared.saveUsers(users)
                        self.selectedUser = newUser
                        NotificationCenter.default.post(name: NSNotification.Name("UserSaved"), object: nil)
                    }
                    
                    self.isNavigatingToMessageView = false
                    DispatchQueue.main.async {
                        self.isNavigatingToMessageView = true
                    }
                }) {
                    Text("Message")
                        .font(.subheadline)
                        .foregroundColor(.darkGreen)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(8)
                }

                Divider()

                Button(action: {
                    isShowingContactEditor = true
                }) {
                    Text("Save Person")
                        .font(.subheadline)
                        .foregroundColor(.darkGreen)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $isShowingContactEditor) {
                    ContactEditorView(contact: contact, isPresented: $isShowingContactEditor)
                }
            }
        }
        .padding()
        .background(Color.teaGreen)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ContactEditorView: UIViewControllerRepresentable {
    let contact: CNContact
    @Binding var isPresented: Bool

    class Coordinator: NSObject, CNContactViewControllerDelegate {
        var parent: ContactEditorView

        init(parent: ContactEditorView) {
            self.parent = parent
        }

        func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let newContact = CNMutableContact()
        newContact.givenName = contact.givenName
        newContact.familyName = contact.familyName
        if let phoneNumber = contact.phoneNumbers.first?.value {
            newContact.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneNumber)]
        }
        if let imageData = contact.thumbnailImageData {
            newContact.imageData = imageData
        }

        let contactViewController = CNContactViewController(forNewContact: newContact)
        contactViewController.contactStore = CNContactStore()
        contactViewController.delegate = context.coordinator

        let navigationController = UINavigationController(rootViewController: contactViewController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
