//
//  TokenRegistry.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/25/26.
//


import SwiftUI

struct TokenRegistry {
    var spacing: [String: CGFloat] = [
        "0": 0, "4": 4, "8": 8, "12": 12, "16": 16, "24": 24, "32": 32, "48": 48, "64": 64
    ]

    var typography: [String: Font] = [
        "Title": .system(size: 28, weight: .bold),
        "Body": .system(size: 15, weight: .regular),
        "Caption": .system(size: 12, weight: .regular)
    ]

    var buttonTint: [String: Color] = [
        "Primary": .accentColor,
        "Secondary": .gray,
        "Destructive": .red
    ]

    var imageHeight: [String: CGFloat] = [
        "Hero": 200,
        "Thumbnail": 80,
        "Icon": 40
    ]

    static let `default` = TokenRegistry()
}