//
//  PopOverButtons.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 26.07.2024.
//

import SwiftUI
import CoreLocation

struct PopOverButtons: View {
    var galleryAction: () -> Void
    var contactAction: () -> Void
    var sendLocationAction: (CLLocationCoordinate2D) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            PopoverButton(imageName: "photo", title: "Gallery", action: galleryAction)
                .frame(width: 100, height: 40)
            PopoverButton(imageName: "location", title: "Location", action: {
                let dummyLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) 
                
                sendLocationAction(dummyLocation)
            })
                .frame(width: 100, height: 40)
            PopoverButton(imageName: "person", title: "Person", action: contactAction)
                .frame(width: 100, height: 40)
        }
        .frame(width: 100, height: 120)
        .background(Color.white.opacity(0.5))
        .cornerRadius(10)
        .shadow(radius: 1)
    }
}

struct PopoverButton: View {
    let imageName: String
    let title: String
    var action: () -> Void
    
    var body: some View {
        Button(action: {
            print("\(title) button tapped")
            action()
        }) {
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
