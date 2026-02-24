import SwiftUI

@MainActor
final class EditorStore: ObservableObject {
    @Published var root: Node
    @Published var selectedNodeID: UUID?
    @Published var searchText: String = ""

    // 인스펙터/캔버스 편집 포커스 추적용 (KeyEventRouter가 참고)
    @Published var editingFieldID: UUID? = nil

    init(root: Node) {
        self.root = root
        self.selectedNodeID = root.id
    }

    // MARK: - Actions

    func select(_ id: UUID?) {
        selectedNodeID = id
        if let id { _ = expandAncestors(to: id, in: &root) }
    }

    func toggleExpandSelected() {
        guard let id = selectedNodeID else { return }
        _ = mutateNode(id, in: &root) { n in
            if n.kind.isContainer { n.isExpanded.toggle() }
        }
    }

    func deleteSelection() {
        guard let id = selectedNodeID, id != root.id else { return }

        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)
        let idx = ids.firstIndex(of: id) ?? 0

        _ = removeNode(id, in: &root)

        var ids2: [UUID] = []
        var parents2: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids2, parentMap: &parents2)

        selectedNodeID = ids2.isEmpty ? root.id : ids2[min(idx, ids2.count - 1)]
    }

    func moveSelection(delta: Int) {
        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)

        guard !ids.isEmpty else { return }

        let current = selectedNodeID ?? root.id
        let idx = ids.firstIndex(of: current) ?? 0
        let next = max(0, min(ids.count - 1, idx + delta))

        selectedNodeID = ids[next]
        if let id = selectedNodeID { _ = expandAncestors(to: id, in: &root) }
    }

    func leftAction() {
        guard let current = selectedNodeID else { return }

        var collapsed = false
        _ = mutateNode(current, in: &root) { n in
            if n.kind.isContainer, n.isExpanded {
                n.isExpanded = false
                collapsed = true
            }
        }
        if collapsed { return }

        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)

        if let parent = parents[current] ?? nil {
            selectedNodeID = parent
        }
    }

    func rightAction() {
        guard let current = selectedNodeID else { return }

        var expanded = false
        _ = mutateNode(current, in: &root) { n in
            if n.kind.isContainer, !n.isExpanded {
                n.isExpanded = true
                expanded = true
            }
        }
        if expanded { return }

        if let child = firstChild(of: current, in: root) {
            selectedNodeID = child
        }
    }

    private func firstChild(of id: UUID, in node: Node) -> UUID? {
        if node.id == id { return node.children.first?.id }
        for c in node.children {
            if let found = firstChild(of: id, in: c) { return found }
        }
        return nil
    }
}