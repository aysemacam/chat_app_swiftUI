//
//  Color+Extensions.swift
//  message_app_swiftUI
//
//  Created by Aysema Çam on 25.07.2024.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0) // default color
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    static let teaGreen = Color(hex: "#DCF8C6")
    static let chatBlue = Color(hex: "#34B7F1")
    static let lightGray = Color(hex: "#ECE5DD")
    static let grayColor = Color(hex: "#EDEDED")

    static let darkGreen = Color(hex: "#075E54")
    static let normalGreen = Color(hex: "#128C7E")
    static let lightGreen = Color(hex: "#25D366")
    static let darkGray = Color(hex: "#767C8C")


    
}
