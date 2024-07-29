//
//  ContactMessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import SwiftUI
import Contacts

struct ContactMessageView: View {
    let contact: CNContact
    var sendMessageAction: () -> Void
    var saveContactAction: () -> Void
    
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
                Button(action: sendMessageAction) {
                    Text("Message")
                        .font(.subheadline)
                        .foregroundColor(.darkGreen)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(8)
                }
                
               Divider()
                
                Button(action: saveContactAction) {
                    Text("Save Person")
                        .font(.subheadline)
                        .foregroundColor(.darkGreen)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.teaGreen)
        .cornerRadius(12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
