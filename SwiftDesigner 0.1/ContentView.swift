import SwiftUI

struct ContentView: View {

    @State private var root: Node = {
        var root = Node(kind: .vStack, isExpanded: true)

        root.props.stack = StackProps(spacingToken: .init("24"), padding: 24, alignment: .leading)

        var hero = Node(kind: .image, isExpanded: false)
        hero.props.image = ImageProps(variant: .init("Hero"), padding: 0)

        var title = Node(kind: .text, isExpanded: false)
        var t = TextProps()
        t.value = "Welcome to App"
        t.typography = .init("Title")
        title.props.text = t

        let spacer = Node(kind: .spacer, isExpanded: false)

        var h = Node(kind: .hStack, isExpanded: true)
        h.props.stack = StackProps(spacingToken: .init("12"), padding: 0, alignment: .leading)

        var cancel = Node(kind: .button)
        var b1 = ButtonProps()
        b1.title = "Cancel"
        b1.style = .init("Secondary")
        cancel.props.button = b1

        var confirm = Node(kind: .button)
        var b2 = ButtonProps()
        b2.title = "Confirm"
        b2.style = .init("Primary")
        confirm.props.button = b2

        h.children = [cancel, confirm]
        root.children = [hero, title, spacer, h]
        return root
    }()

    @State private var selectedNodeID: UUID? = nil
    @State private var searchText: String = ""

    let tokens: TokenRegistry = .default

    @FocusState private var editingFieldID: UUID?

    var body: some View {
        NavigationSplitView {
            StructureView(
                root: $root,
                selectedNodeID: $selectedNodeID,
                searchText: searchText,
                editingFieldID: $editingFieldID
            )
            .navigationTitle("Structure")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)
                }
            }
        } detail: {
            detailPane
                .navigationTitle("Preview")
        }
        .background(
            KeyEventRouter { event in
                // 텍스트 편집 중이면 키는 텍스트필드에 양보
                if editingFieldID != nil { return false }

                switch event.keyCode {
                case 126: moveSelection(delta: -1); return true   // ↑
                case 125: moveSelection(delta: 1);  return true   // ↓
                case 123: leftAction();             return true   // ←
                case 124: rightAction();            return true   // →
                case 51, 117: deleteSelection();    return true   // delete
                default: return false
                }
            }
        )
        .onAppear {
            selectedNodeID = root.id
        }
    }

    private var detailPane: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                CanvasView(
                    node: root,
                    tokens: tokens,
                    selectedID: selectedNodeID,
                    onSelect: { id in selectedNodeID = id },
                    isRoot: true
                )
                .frame(width: 360, height: 640, alignment: .topLeading)
                .padding(18)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
                .padding(.vertical, 18)

                Spacer(minLength: 0)
            }
            .frame(minWidth: 520, maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            VStack(spacing: 0) {
                if let sel = selectedNodeID,
                   let binding = bindingForNode(root: $root, id: sel) {
                    InspectorView(node: binding, tokens: tokens, editingFieldID: $editingFieldID)
                } else {
                    ContentUnavailableView("No selection", systemImage: "cursorarrow.click")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.background)
                }
            }
            .frame(width: 360)
            .background(.background)
        }
    }

    // MARK: - Keyboard actions

    private func moveSelection(delta: Int) {
        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)

        guard !ids.isEmpty else { return }

        let current = selectedNodeID ?? root.id
        let idx = ids.firstIndex(of: current) ?? 0
        let next = max(0, min(ids.count - 1, idx + delta))
        selectedNodeID = ids[next]
    }

    private func leftAction() {
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

    private func rightAction() {
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

    private func deleteSelection() {
        guard let id = selectedNodeID, id != root.id else { return }

        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)
        let idx = ids.firstIndex(of: id) ?? 0

        _ = removeNode(id, in: &root)

        var ids2: [UUID] = []
        var parents2: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids2, parentMap: &parents2)

        if ids2.isEmpty { selectedNodeID = root.id; return }
        selectedNodeID = ids2[min(idx, ids2.count - 1)]
    }
}