//
//  ContentView.swift
//  SwiftDesigner 0.1
//
//  Created by home studio on 2/24/26.
//

import SwiftUI

struct ContentView: View {
    @State private var root: Node = .init(
        kind: .vStack,
        isExpanded: true,
        children: [
            Node(kind: .image, isExpanded: false, props: {
                var p = NodeProps(); p.image = ImageProps(variant: .init("Hero"), padding: 0); return p
            }()),
            Node(kind: .text, isExpanded: false, props: {
                var p = NodeProps(); var t = TextProps(); t.value = "Welcome to App"; t.typography = .init("Title"); p.text = t; return p
            }()),
            Node(kind: .spacer, isExpanded: false, props: { var p = NodeProps(); p.spacer = SpacerProps(minLength: 12); return p }()),
            Node(kind: .hStack, isExpanded: true, children: [
                Node(kind: .button, props: { var p = NodeProps(); var b = ButtonProps(); b.title = "Cancel"; b.style = .init("Secondary"); p.button = b; return p }()),
                Node(kind: .button, props: { var p = NodeProps(); var b = ButtonProps(); b.title = "Confirm"; b.style = .init("Primary"); p.button = b; return p }())
            ], props: { var p = NodeProps(); p.stack = StackProps(spacingToken: .init("12"), padding: 0, alignment: .leading); return p }())
        ],
        props: {
            var p = NodeProps()
            p.stack = StackProps(spacingToken: .init("24"), padding: 24, alignment: .leading)
            return p
        }()
    )

    @State private var selectedNodeID: UUID? = nil
    @State private var searchText: String = ""

    let tokens: TokenRegistry = .default

    // 포커스 공유 (핵심)
    @FocusState private var structureFocused: Bool
    @FocusState private var editingFieldID: UUID?

    var body: some View {
        NavigationSplitView {
            StructureView(
                root: $root,
                selectedNodeID: $selectedNodeID,
                searchText: searchText,
                structureFocused: $structureFocused,
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
                .toolbar {
                    // 굳이 포커스 표시용 UI는 안 넣음 (요구사항)
                }
        }
        .onAppear {
            // 기본 선택: 루트
            selectedNodeID = root.id
            structureFocused = true
        }
        .onChange(of: editingFieldID) { _, newValue in
            // 어디서든(인스펙터/트리) 편집 끝나면 구조로 키보드 소유권 복귀
            if newValue == nil {
                structureFocused = true
            }
        }
    }

    private var detailPane: some View {
        HStack(spacing: 0) {
            // Canvas
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
                .onTapGesture {
                    // 캔버스 클릭했을 때도 구조로 포커스 복귀시켜서 방향키 끊김 방지
                    structureFocused = true
                }

                Spacer(minLength: 0)
            }
            .frame(minWidth: 520, maxWidth: .infinity)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Inspector
            VStack(spacing: 0) {
                if let sel = selectedNodeID,
                   let binding = bindingForNode(root: $root, id: sel) {

                    InspectorView(
                        node: binding,
                        tokens: tokens,
                        editingFieldID: $editingFieldID,
                        structureFocused: $structureFocused
                    )
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
}
