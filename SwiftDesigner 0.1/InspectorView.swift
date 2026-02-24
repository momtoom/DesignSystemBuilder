import SwiftUI

struct InspectorView: View {
    @Binding var node: Node
    let tokens: TokenRegistry
    @FocusState.Binding var editingFieldID: UUID?

    var body: some View {
        Form {
            Section("Properties") {
                switch node.kind {
                case .vStack, .hStack: stackInspector
                case .text: textInspector
                case .button: buttonInspector
                case .image: imageInspector
                case .spacer: spacerInspector
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(.background)
    }

    private var stackInspector: some View {
        let binding = Binding(
            get: { node.props.stack ?? StackProps() },
            set: { node.props.stack = $0 }
        )

        return VStack(alignment: .leading, spacing: 12) {
            Picker("Spacing", selection: Binding(
                get: { binding.wrappedValue.spacingToken.name },
                set: { binding.wrappedValue.spacingToken = .init($0) }
            )) {
                ForEach(tokens.spacing.keys.sorted(by: { Int($0)! < Int($1)! }), id: \.self) { k in
                    Text("\(k)px").tag(k)
                }
            }

            Slider(value: Binding(
                get: { Double(binding.wrappedValue.padding) },
                set: { binding.wrappedValue.padding = CGFloat($0) }
            ), in: 0...64, step: 1) {
                Text("Padding")
            }
            Text("Padding: \(Int(binding.wrappedValue.padding))")
                .foregroundStyle(.secondary)
        }
    }

    private var textInspector: some View {
        let binding = Binding(
            get: { node.props.text ?? TextProps() },
            set: { node.props.text = $0 }
        )

        return VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Text") {
                TextField("", text: Binding(
                    get: { binding.wrappedValue.value },
                    set: { binding.wrappedValue.value = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 220)
                .focused($editingFieldID, equals: node.id)
            }

            Picker("Typography", selection: Binding(
                get: { binding.wrappedValue.typography.name },
                set: { binding.wrappedValue.typography = .init($0) }
            )) {
                ForEach(["Title","Body","Caption"], id: \.self) { t in
                    Text(t).tag(t)
                }
            }
        }
    }

    private var buttonInspector: some View {
        let binding = Binding(
            get: { node.props.button ?? ButtonProps() },
            set: { node.props.button = $0 }
        )

        return VStack(alignment: .leading, spacing: 12) {
            LabeledContent("Title") {
                TextField("", text: Binding(
                    get: { binding.wrappedValue.title },
                    set: { binding.wrappedValue.title = $0 }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(minWidth: 220)
                .focused($editingFieldID, equals: node.id)
            }

            Picker("Style", selection: Binding(
                get: { binding.wrappedValue.style.name },
                set: { binding.wrappedValue.style = .init($0) }
            )) {
                ForEach(["Primary","Secondary","Destructive"], id: \.self) { t in
                    Text(t).tag(t)
                }
            }
        }
    }

    private var imageInspector: some View {
        let binding = Binding(
            get: { node.props.image ?? ImageProps() },
            set: { node.props.image = $0 }
        )

        return VStack(alignment: .leading, spacing: 12) {
            Picker("Variant", selection: Binding(
                get: { binding.wrappedValue.variant.name },
                set: { binding.wrappedValue.variant = .init($0) }
            )) {
                ForEach(["Hero","Thumbnail","Icon"], id: \.self) { t in
                    Text(t).tag(t)
                }
            }
        }
    }

    private var spacerInspector: some View {
        let binding = Binding(
            get: { node.props.spacer ?? SpacerProps() },
            set: { node.props.spacer = $0 }
        )

        return VStack(alignment: .leading, spacing: 12) {
            Slider(value: Binding(
                get: { Double(binding.wrappedValue.minLength) },
                set: { binding.wrappedValue.minLength = CGFloat($0) }
            ), in: 0...200, step: 1) {
                Text("Min Length")
            }
            Text("Min Length: \(Int(binding.wrappedValue.minLength))")
                .foregroundStyle(.secondary)
        }
    }
}