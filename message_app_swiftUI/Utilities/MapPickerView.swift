//
//  MapPickerView.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 29.07.2024.
//
import SwiftUI
import MapKit

import SwiftUI
import MapKit

struct MapPickerView: View {
    @Binding var isPresented: Bool
    @Binding var selectedLocation: CLLocationCoordinate2D?
    
    @StateObject private var locationManager = LocationManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var temporaryLocation: IdentifiableCoordinate?
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                
                Spacer()
                
                Button("Send") {
                    if let tempLocation = temporaryLocation {
                        selectedLocation = tempLocation.coordinate
                    }
                    isPresented = false
                }
                .padding()
            }
            
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: [temporaryLocation].compactMap { $0 }) { location in
                MapMarker(coordinate: location.coordinate)
            }
            .onAppear {
                locationManager.requestLocationPermission()
                locationManager.startUpdatingLocation()
                if let currentLocation = selectedLocation {
                    region.center = currentLocation
                    temporaryLocation = IdentifiableCoordinate(coordinate: currentLocation)
                }
            }
            .onChange(of: region.center) { newCenter in
                temporaryLocation = IdentifiableCoordinate(coordinate: newCenter)
            }
            .onReceive(locationManager.$userLocation) { userLocation in
                if let userLocation = userLocation, selectedLocation == nil {
                    region.center = userLocation
                    temporaryLocation = IdentifiableCoordinate(coordinate: userLocation)
                }
            }
        }
    }
}

struct IdentifiableCoordinate: Identifiable, Equatable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D

    static func ==(lhs: IdentifiableCoordinate, rhs: IdentifiableCoordinate) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
