import SwiftUI

struct StructureView: View {
    @Binding var root: Node
    @Binding var selectedNodeID: UUID?
    let searchText: String
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
            .onChange(of: selectedNodeID) { _, newValue in
                guard let id = newValue else { return }
                withAnimation(.easeInOut(duration: 0.15)) {
                    _ = expandAncestors(to: id, in: &root)
                }
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
        .background(.background)
    }
}

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
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { node.isExpanded.toggle() } }
            } else {
                Spacer().frame(width: 12)
            }

            Image(systemName: iconName(node.kind))
                .foregroundStyle(node.kind.isContainer ? Color.accentColor.opacity(0.85) : .secondary)
                .frame(width: 16)

            inlineEditor

            Spacer()

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
                RoundedRectangle(cornerRadius: 8).fill(Color.accentColor.opacity(0.14))
            } else if hovering {
                RoundedRectangle(cornerRadius: 8).fill(Color.primary.opacity(0.04))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { selectedNodeID = node.id }
        .onHover { hovering = $0 }
    }

    @ViewBuilder
    private var inlineEditor: some View {
        switch node.kind {
        case .text:
            let b = Binding(
                get: { node.props.text?.value ?? "" },
                set: {
                    var p = node.props.text ?? TextProps()
                    p.value = $0
                    node.props.text = p
                }
            )
            TextField("Text", text: b)
                .textFieldStyle(.plain)
                .focused($editingFieldID, equals: node.id)
                .font(.system(size: 13))

        case .button:
            let b = Binding(
                get: { node.props.button?.title ?? "" },
                set: {
                    var p = node.props.button ?? ButtonProps()
                    p.title = $0
                    node.props.button = p
                }
            )
            TextField("Button", text: b)
                .textFieldStyle(.plain)
                .focused($editingFieldID, equals: node.id)
                .font(.system(size: 13))

        default:
            Text(label(node.kind))
                .font(.system(size: 13, weight: .medium))
        }
    }

    private func iconName(_ kind: NodeKind) -> String {
        switch kind {
        case .vStack: return "rectangle.stack"
        case .hStack: return "rectangle.stack"
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