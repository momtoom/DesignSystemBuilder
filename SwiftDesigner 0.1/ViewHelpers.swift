//
//  TokenRegistry.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//


import SwiftUI

// MARK: - Tree helpers (Binding search)

func bindingForNode(root: Binding<Node>, id: UUID) -> Binding<Node>? {
    if root.wrappedValue.id == id { return root }

    for i in root.wrappedValue.children.indices {
        let child = root.children[i]
        if let found = bindingForNode(root: child, id: id) { return found }
    }
    return nil
}

@discardableResult
func expandAncestors(to targetID: UUID, in node: inout Node) -> Bool {
    if node.id == targetID { return true }

    for i in node.children.indices {
        if expandAncestors(to: targetID, in: &node.children[i]) {
            if node.kind.isContainer { node.isExpanded = true }
            return true
        }
    }
    return false
}

// MARK: - Visible list for keyboard navigation

func collectVisibleIDs(from node: Node, parent: UUID?, ids: inout [UUID], parentMap: inout [UUID: UUID?]) {
    ids.append(node.id)
    parentMap[node.id] = parent

    if node.kind.isContainer, node.isExpanded {
        for c in node.children {
            collectVisibleIDs(from: c, parent: node.id, ids: &ids, parentMap: &parentMap)
        }
    }
}

@discardableResult
func mutateNode(_ id: UUID, in node: inout Node, mutate: (inout Node) -> Void) -> Bool {
    if node.id == id {
        mutate(&node)
        return true
    }
    for i in node.children.indices {
        if mutateNode(id, in: &node.children[i], mutate: mutate) { return true }
    }
    return false
}

@discardableResult
func removeNode(_ id: UUID, in node: inout Node) -> Bool {
    if let idx = node.children.firstIndex(where: { $0.id == id }) {
        node.children.remove(at: idx)
        return true
    }
    for i in node.children.indices {
        if removeNode(id, in: &node.children[i]) { return true }
    }
    return false
}
