//
//  MessageUserView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import SwiftUI

struct MessageUserView: View {
    var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                }
                .padding(.leading, 8)

                Text("6")
                    .font(.system(size: 16, weight: .regular))

                if let uiImage = UIImage(data: user.userPhoto) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .foregroundColor(.gray)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .padding(.leading, 12)
                }

                Text(user.username)
                    .font(.system(size: 16, weight: .regular))
                    .padding(.leading, 8)

                Spacer()

                Button(action: {
                }) {
                    Image(systemName: "camera")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 8)

                Button(action: {
                }) {
                    Image(systemName: "phone")
                        .foregroundColor(.black)
                }
                .padding(.trailing, 8)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            .background(Color.white)
            
            Rectangle()
                .fill(Color.gray)
                .frame(height: 0.4)
        }
    }
}
