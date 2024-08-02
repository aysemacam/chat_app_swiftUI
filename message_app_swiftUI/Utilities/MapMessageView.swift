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
    @State private var mapImage: UIImage? = nil

    var body: some View {
        HStack {
            ZStack {
                Color.teaGreen
                    .cornerRadius(12)
                
                if let mapImage = mapImage {
                    Image(uiImage: mapImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 280, height: 200)
                        .cornerRadius(12)
                        .padding(5)
                } else {
                    ProgressView()
                        .frame(width: 280, height: 200)
                        .cornerRadius(12)
                        .padding(5)
                        .onAppear {
                            loadMapSnapshot()
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: isIncoming ? .leading : .trailing)
        }
    }
    
    private func loadMapSnapshot() {
        let options = MKMapSnapshotter.Options()
        options.region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        options.size = CGSize(width: 280, height: 200)
        options.scale = UIScreen.main.scale

        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            guard let snapshot = snapshot else {
                return
            }

            UIGraphicsBeginImageContextWithOptions(options.size, true, 0)
            snapshot.image.draw(at: .zero)
            let pin = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
            pin.image = UIImage(systemName: "mappin.circle.fill")
            var point = snapshot.point(for: location)
            if CGRect(origin: .zero, size: options.size).contains(point) {
                point.x -= pin.bounds.size.width / 2
                point.y -= pin.bounds.size.height / 2
                point.x += pin.centerOffset.x
                point.y += pin.centerOffset.y
                pin.image?.draw(at: point)
            }
            let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            DispatchQueue.main.async {
                self.mapImage = compositeImage
            }
        }
    }
}
