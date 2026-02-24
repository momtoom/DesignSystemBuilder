//
//  Node.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/25/26.
//


import SwiftUI

struct Node: Identifiable, Equatable {
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

enum NodeKind: String, Equatable {
    case vStack, hStack
    case text
    case button
    case image
    case spacer

    var isContainer: Bool { self == .vStack || self == .hStack }
}

struct TokenRef: Equatable, Hashable {
    var name: String
    init(_ name: String) { self.name = name }
}

struct NodeProps: Equatable {
    var stack: StackProps? = nil
    var text: TextProps? = nil
    var button: ButtonProps? = nil
    var image: ImageProps? = nil
    var spacer: SpacerProps? = nil
    init() {}
}

struct StackProps: Equatable {
    var spacingToken: TokenRef = .init("16")
    var padding: CGFloat = 0
    var alignment: StackAlignment = .leading
}

enum StackAlignment: String, Equatable {
    case leading, center, trailing
}

struct TextProps: Equatable {
    var value: String = "Text"
    var typography: TokenRef = .init("Body")
    var padding: CGFloat = 0
}

struct ButtonProps: Equatable {
    var title: String = "Button"
    var style: TokenRef = .init("Primary")
    var padding: CGFloat = 0
}

struct ImageProps: Equatable {
    var variant: TokenRef = .init("Hero")
    var padding: CGFloat = 0
}

struct SpacerProps: Equatable {
    var minLength: CGFloat = 8
}