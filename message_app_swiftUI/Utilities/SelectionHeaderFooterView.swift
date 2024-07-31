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
        HStack {
            Image(systemName: "person.crop.circle")
                .resizable()
                .frame(width: 40, height: 40)
            Text(user.username)
            Spacer()
            Button(action: cancelAction) {
                Text("Cancel")
            }
        }
        .padding()
        .background(Color.white)
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
