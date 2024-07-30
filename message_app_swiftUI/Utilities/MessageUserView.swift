//
//  MessageUserView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 30.07.2024.
//

import SwiftUI

struct MessageUserView: View {
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

                Image("nick")
                    .resizable()
                    .foregroundColor(.gray)
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
                    .padding(.leading, 12)

                Text("Nick Cave")
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
            .padding(.bottom ,12)
            .background(Color.white)
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 0.4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MessageUserView()
    }
}
