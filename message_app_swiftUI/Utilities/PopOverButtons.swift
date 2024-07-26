//
//  PopOverButtons.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import SwiftUI

struct PopOverButtons: View {
    var galleryAction: () -> Void // Gallery action parameter
    
    var body: some View {
        VStack(spacing: 0) {
            PopoverButton(imageName: "photo", title: "Gallery", action: galleryAction)
                .frame(width: 100, height: 40)
            PopoverButton(imageName: "location", title: "Location", action: { /* location action */ })
                .frame(width: 100, height: 40)
            PopoverButton(imageName: "person", title: "Person", action: { /* person action */ })
                .frame(width: 100, height: 40)
        }
        .frame(width: 100, height: 150)
    }
}


struct PopoverButton: View {
    let imageName: String
    let title: String
    var action: () -> Void // Action parameter
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: imageName)
                    .frame(width: 15, height: 15, alignment: .leading)
                    .foregroundColor(.black)
                Text(title)
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.horizontal, 7)
            }
            .frame(alignment: .leading)
            .cornerRadius(8)
        }
    }
}
