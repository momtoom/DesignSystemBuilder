//
//  Node.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//


import SwiftUI

// MARK: - Node

struct Node: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var kind: NodeKind
    var isExpanded: Bool = true
    var children: [Node] = []
    var props: NodeProps = .init()

    init(kind: NodeKind, isExpanded: Bool = true, children: [Node] = [], props: NodeProps = .init()) {
        self.kind = kind
        self.isExpanded = isExpanded
        self.children = children
        self.props = props
    }
}

enum NodeKind: String, Codable {
    case vStack, hStack
    case text
    case button
    case image
    case spacer

    var isContainer: Bool { self == .vStack || self == .hStack }
}

// MARK: - Props

struct NodeProps: Codable, Equatable {
    var stack: StackProps? = nil
    var text: TextProps? = nil
    var button: ButtonProps? = nil
    var image: ImageProps? = nil
    var spacer: SpacerProps? = nil

    init() {}
}

struct TokenRef: Codable, Equatable, Hashable {
    var name: String
    init(_ name: String) { self.name = name }
}

struct StackProps: Codable, Equatable {
    var spacingToken: TokenRef = .init("16")
    var padding: CGFloat = 0
    var alignment: StackAlignment = .leading

    init(spacingToken: TokenRef = .init("16"), padding: CGFloat = 0, alignment: StackAlignment = .leading) {
        self.spacingToken = spacingToken
        self.padding = padding
        self.alignment = alignment
    }
}

enum StackAlignment: String, Codable {
    case leading, center, trailing
}

struct TextProps: Codable, Equatable {
    var value: String = "Text"
    var typography: TokenRef = .init("Body")
    var padding: CGFloat = 0
}

struct ButtonProps: Codable, Equatable {
    var title: String = "Button"
    var style: TokenRef = .init("Primary")
    var padding: CGFloat = 0
}

struct ImageProps: Codable, Equatable {
    var variant: TokenRef = .init("Hero")
    var padding: CGFloat = 0
}

struct SpacerProps: Codable, Equatable {
    var minLength: CGFloat = 8
}