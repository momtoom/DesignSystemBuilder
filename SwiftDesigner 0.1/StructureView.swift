//
//  StructureView.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//


import SwiftUI

struct StructureView: View {
    @Binding var root: Node
    @Binding var selectedNodeID: UUID?
    let searchText: String

    @FocusState.Binding var structureFocused: Bool
    @FocusState.Binding var editingFieldID: UUID?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    NodeRow(
                        node: $root,
                        level: 0,
                        selectedNodeID: $selectedNodeID,
                        editingFieldID: $editingFieldID,
                        searchText: searchText
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
            }
            .focusable(true)
            .focused($structureFocused)
            .onTapGesture { structureFocused = true }
            .onMoveCommand { handleMove($0) }
            .onDeleteCommand { deleteSelection() }
            .onChange(of: selectedNodeID) { _, newValue in
                guard let id = newValue else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    _ = expandAncestors(to: id, in: &root)
                }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
            .onChange(of: editingFieldID) { _, newValue in
                // 텍필 편집이 끝나서 포커스가 nil이 되면 구조로 자동 복귀
                if newValue == nil {
                    structureFocused = true
                }
            }
        }
        .background(.background)
    }

    // MARK: - Keyboard

    private func handleMove(_ direction: MoveCommandDirection) {
        switch direction {
        case .up: moveSelection(delta: -1)
        case .down: moveSelection(delta: 1)
        case .left: leftAction()
        case .right: rightAction()
        default: break
        }
    }

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
        guard let current = selectedNodeID else { selectedNodeID = root.id; return }

        // 1) 컨테이너면 접기
        var collapsed = false
        _ = mutateNode(current, in: &root) { n in
            if n.kind.isContainer, n.isExpanded {
                n.isExpanded = false
                collapsed = true
            }
        }
        if collapsed { return }

        // 2) 아니면 부모로
        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)
        if let parent = parents[current] ?? nil {
            selectedNodeID = parent
        }
    }

    private func rightAction() {
        guard let current = selectedNodeID else { selectedNodeID = root.id; return }

        // 1) 컨테이너면 펼치기
        var expanded = false
        _ = mutateNode(current, in: &root) { n in
            if n.kind.isContainer, !n.isExpanded {
                n.isExpanded = true
                expanded = true
            }
        }
        if expanded { return }

        // 2) 펼쳐진 컨테이너면 첫 자식
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

        // 삭제 전 위치 기억
        var ids: [UUID] = []
        var parents: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids, parentMap: &parents)
        let idx = ids.firstIndex(of: id) ?? 0

        withAnimation(.easeInOut(duration: 0.12)) {
            _ = removeNode(id, in: &root)
        }

        // 삭제 후 새 선택
        var ids2: [UUID] = []
        var parents2: [UUID: UUID?] = [:]
        collectVisibleIDs(from: root, parent: nil, ids: &ids2, parentMap: &parents2)

        if ids2.isEmpty { selectedNodeID = root.id; return }
        selectedNodeID = ids2[min(idx, ids2.count - 1)]
    }
}

// MARK: - Row

struct NodeRow: View {
    @Binding var node: Node
    let level: Int
    @Binding var selectedNodeID: UUID?
    @FocusState.Binding var editingFieldID: UUID?
    let searchText: String

    @State private var hovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            rowLine
                .id(node.id)

            if node.kind.isContainer, node.isExpanded {
                ForEach(node.children.indices, id: \.self) { i in
                    NodeRow(
                        node: $node.children[i],
                        level: level + 1,
                        selectedNodeID: $selectedNodeID,
                        editingFieldID: $editingFieldID,
                        searchText: searchText
                    )
                }
            }
        }
    }

    private var rowLine: some View {
        let isSelected = selectedNodeID == node.id

        return HStack(spacing: 8) {
            Spacer().frame(width: CGFloat(level) * 18)

            if node.kind.isContainer {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(node.isExpanded ? 90 : 0))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            node.isExpanded.toggle()
                        }
                    }
            } else {
                Spacer().frame(width: 12)
            }

            Image(systemName: iconName(node.kind))
                .foregroundStyle(node.kind.isContainer ? Color.accentColor.opacity(0.8) : .secondary)
                .frame(width: 16)

            inlineTitleEditor

            Spacer()

            // 최소한의 “상태 배지” (원하면 지워도 됨)
            if node.kind.isContainer {
                Text(node.kind == .vStack ? "VStack" : "HStack")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(.quaternary.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
        .background {
            if isSelected {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor.opacity(0.14))
            } else if hovering {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedNodeID = node.id }
        .onHover { hovering = $0 }
    }

    @ViewBuilder
    private var inlineTitleEditor: some View {
        switch node.kind {
        case .text:
            let binding = Binding(
                get: { node.props.text?.value ?? "" },
                set: {
                    var p = node.props.text ?? TextProps()
                    p.value = $0
                    node.props.text = p
                }
            )
            TextField("Text", text: binding)
                .textFieldStyle(.plain)
                .focused($editingFieldID, equals: node.id)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

        case .button:
            let binding = Binding(
                get: { node.props.button?.title ?? "" },
                set: {
                    var p = node.props.button ?? ButtonProps()
                    p.title = $0
                    node.props.button = p
                }
            )
            TextField("Button", text: binding)
                .textFieldStyle(.plain)
                .focused($editingFieldID, equals: node.id)
                .font(.system(size: 13))
                .foregroundStyle(.primary)

        default:
            Text(label(node.kind))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.primary)
        }
    }

    private func iconName(_ kind: NodeKind) -> String {
        switch kind {
        case .vStack: return "square.stack.3d.down.right"
        case .hStack: return "square.stack.3d.right"
        case .text: return "textformat"
        case .button: return "capsule"
        case .image: return "photo"
        case .spacer: return "arrow.up.and.down"
        }
    }

    private func label(_ kind: NodeKind) -> String {
        switch kind {
        case .vStack: return "VStack"
        case .hStack: return "HStack"
        case .text: return "Text"
        case .button: return "Button"
        case .image: return "Image"
        case .spacer: return "Spacer"
        }
    }
}