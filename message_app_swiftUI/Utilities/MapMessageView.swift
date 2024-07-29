//
//  MapMessageView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 29.07.2024.
//

import Foundation
import SwiftUI
import MapKit

struct MapMessageView: View {
    let location: CLLocationCoordinate2D
    let isIncoming: Bool
    
    var body: some View {
        HStack {
            ZStack {
                Color.teaGreen
                    .cornerRadius(12)
                
                Map(coordinateRegion: .constant(MKCoordinateRegion(
                    center: location,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )))
                .frame(width: 270, height: 200)
                .cornerRadius(12)
                .padding(5)
            }
            .frame(maxWidth: .infinity, alignment: isIncoming ? .leading : .trailing)
        }
    }
}
