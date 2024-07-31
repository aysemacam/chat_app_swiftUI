//
//  SelectionHeaderFooterView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 31.07.2024.
//

import SwiftUI



struct SelectionHeaderView: View {
    var user: User
    var cancelAction: () -> Void


        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                       
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

                    Button(action: cancelAction) {
                        Text("Cancel")
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

struct SelectionFooterView: View {
    var selectedCount: Int
    var deleteAction: () -> Void

    var body: some View {
        HStack {
            Button(action: deleteAction) {
                Text("Delete")
                    .foregroundColor(.red)
            }
            Spacer()
            Text("\(selectedCount) message selected")
        }
        .padding()
        .background(Color.white)
    }
}
