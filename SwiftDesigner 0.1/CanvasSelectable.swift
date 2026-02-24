//
//  CanvasSelectableModifier.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//


import SwiftUI

private struct CanvasSelectableModifier: ViewModifier {
    let nodeID: UUID
    let selectedID: UUID?
    let onSelect: (UUID) -> Void

    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onHover { hovering = $0 }
            .simultaneousGesture(
                TapGesture().onEnded { onSelect(nodeID) }
            )
            .overlay {
                if hovering && selectedID != nodeID {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.secondary.opacity(0.35), lineWidth: 1)
                        .padding(1)
                }
                if selectedID == nodeID {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.accentColor.opacity(0.95), lineWidth: 2)
                        .padding(1)
                }
            }
    }
}

extension View {
    func canvasSelectable(nodeID: UUID, selectedID: UUID?, onSelect: @escaping (UUID) -> Void) -> some View {
        modifier(CanvasSelectableModifier(nodeID: nodeID, selectedID: selectedID, onSelect: onSelect))
    }
}