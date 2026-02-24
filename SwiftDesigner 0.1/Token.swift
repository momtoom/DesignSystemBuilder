//
//  TokenRegistry.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//


import SwiftUI

struct TokenRegistry {
    // spacing tokens (string -> CGFloat)
    var spacing: [String: CGFloat] = [
        "0": 0, "4": 4, "8": 8, "12": 12, "16": 16, "24": 24, "32": 32, "48": 48, "64": 64
    ]

    // typography tokens
    var typography: [String: Font] = [
        "Title": .system(size: 28, weight: .bold),
        "Body": .system(size: 15, weight: .regular),
        "Caption": .system(size: 12, weight: .regular)
    ]

    // button style tokens -> tint
    var buttonTint: [String: Color] = [
        "Primary": .accentColor,
        "Secondary": .gray,
        "Destructive": .red
    ]

    // image variants -> heights
    var imageHeight: [String: CGFloat] = [
        "Hero": 200,
        "Thumbnail": 80,
        "Icon": 40
    ]

    static let `default` = TokenRegistry()
}