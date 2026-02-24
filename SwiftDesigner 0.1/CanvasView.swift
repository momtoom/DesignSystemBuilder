import SwiftUI

struct CanvasView: View {
    let node: Node
    let tokens: TokenRegistry
    let selectedID: UUID?
    let onSelect: (UUID) -> Void
    let isRoot: Bool

    var body: some View {
        core()
            .canvasSelectable(nodeID: node.id, selectedID: selectedID, onSelect: onSelect)
    }

    @ViewBuilder
    private func core() -> some View {
        switch node.kind {

        case .vStack:
            let p = node.props.stack ?? StackProps()
            let sp = tokens.spacing[p.spacingToken.name] ?? 16

            VStack(alignment: alignment(p.alignment), spacing: sp) {
                ForEach(node.children) { child in
                    CanvasView(node: child, tokens: tokens, selectedID: selectedID, onSelect: onSelect, isRoot: false)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: isRoot ? .infinity : nil, alignment: .topLeading)
            .padding(p.padding)

        case .hStack:
            let p = node.props.stack ?? StackProps()
            let sp = tokens.spacing[p.spacingToken.name] ?? 16

            HStack(alignment: .center, spacing: sp) {
                ForEach(node.children) { child in
                    CanvasView(node: child, tokens: tokens, selectedID: selectedID, onSelect: onSelect, isRoot: false)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(p.padding)

        case .text:
            let p = node.props.text ?? TextProps()
            let font = tokens.typography[p.typography.name] ?? .body

            Text(p.value)
                .font(font)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(p.padding)

        case .button:
            let p = node.props.button ?? ButtonProps()
            let tint = tokens.buttonTint[p.style.name] ?? .accentColor

            Button(p.title) { }
                .frame(maxWidth: .infinity, alignment: .leading)
                .buttonStyle(SwiftUI.BorderedProminentButtonStyle())
                .tint(tint)
                .padding(p.padding)

        case .image:
            let p = node.props.image ?? ImageProps()
            let h = tokens.imageHeight[p.variant.name] ?? 200

            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: h)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.secondary)
                .padding(10)
                .background(.quaternary.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(p.padding)

        case .spacer:
            let p = node.props.spacer ?? SpacerProps()
            Spacer(minLength: p.minLength)
        }
    }

    private func alignment(_ a: StackAlignment) -> HorizontalAlignment {
        switch a {
        case .leading: return .leading
        case .center: return .center
        case .trailing: return .trailing
        }
    }
}