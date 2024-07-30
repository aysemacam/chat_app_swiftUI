//
//  ContentView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import SwiftUI
import ContactsUI

struct ContentView: View {
    @State private var users: [User] = DataManager.shared.fetchUsers()
    @State private var showingContactPicker = false
    @State private var selectedUser: User?
    @State private var isNavigationActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: MessageView(user: selectedUser ?? User(username: "", userPhoto: Data())), isActive: $isNavigationActive) {
                    EmptyView()
                }
                List(users) { user in
                    NavigationLink(destination: MessageView(user: user)) {
                        HStack {
                            Image(uiImage: UIImage(data: user.userPhoto) ?? UIImage())
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(.trailing, 10)

                            VStack(alignment: .leading) {
                                Text(user.username)
                                    .font(.headline)
                                Text(lastMessageText(for: user))
                                    .font(.subheadline)
                            }

                            Spacer()

                            Text("\(Date(), formatter: dateFormatter)")
                                .font(.caption)
                                .padding(.leading, 10)
                        }
                        .background(Color.white)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.white)
                .navigationBarTitle("Chats", displayMode: .inline)
                .navigationBarItems(trailing:
                    Button(action: {
                        showingContactPicker = true
                    }) {
                        Image(systemName: "plus")
                    }
                )
            }
        }
        .sheet(isPresented: $showingContactPicker) {
            ContactPickerViewForCreateChat { contact in
                if let contact = contact {
                    let contactUsername = contact.givenName + " " + contact.familyName
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
                    }
                    self.isNavigationActive = true
                }
            }
        }
        .onAppear {
            if users.isEmpty {
                users = [
                    User(username: "Nick Cave", userPhoto: UIImage(named: "nick")!.jpegData(compressionQuality: 1.0)!),
                    User(username: "Tanjiro Kamado", userPhoto: UIImage(named: "tanjiro")!.jpegData(compressionQuality: 1.0)!),
                    User(username: "Nezuko Kamado", userPhoto: UIImage(named: "nezuko")!.jpegData(compressionQuality: 1.0)!)
                ]
                DataManager.shared.saveUsers(users)
            }
        }
    }
    
    private func lastMessageText(for user: User) -> String {
        guard let lastMessage = user.userChat?.messages.last else {
            return user.username
        }
        
        if let text = lastMessage.text {
            return text
        } else if lastMessage.media != nil {
            switch lastMessage.media!.type {
            case .photo:
                return "You sent a photo"
            case .video:
                return "You sent a video"
            case .audio:
                return "You sent a sound"
            }
        } else if lastMessage.location != nil {
            return "You sent a location"
        } else if lastMessage.contact != nil {
            return "You sent a person"
        }
        
        return user.username
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

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
