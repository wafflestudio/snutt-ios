//
//  EditableRow.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import MemberwiseInit
import SwiftUI
import SwiftUIIntrospect
import SwiftUIUtility
import TimetableInterface

@MemberwiseInit
struct EditableRow<Value: Sendable>: View {
    @Environment(LectureEditDetailViewModel.self) private var viewModel
    @Environment(\.editMode) private var editMode

    let label: String
    @Init(default: false) let readOnly: Bool
    @Init(default: false) let multiline: Bool
    let keyPath: WritableKeyPath<Lecture, Value>

    private var isEditing: Bool {
        editMode?.wrappedValue.isEditing ?? false
    }

    private var container: ValueContainer<Value> {
        .init(
            binding: Binding(get: {
                viewModel.editableLecture[keyPath: keyPath]
            }, set: {
                viewModel.editableLecture[keyPath: keyPath] = $0
            }),
            initialValue: viewModel.entryLecture[keyPath: keyPath]
        )
    }

    var body: some View {
        HStack {
            DetailLabel(text: label)

            Group {
                switch container {
                case let container as ValueContainer<String?> where multiline:
                    PlaceholderTextEditor(
                        label: label,
                        text: container.bindingNonOptional,
                        placeholder: container.placeholderText
                    )
                case let container as ValueContainer<TimePlace>:
                    DateTimeEditor(timePlace: container.binding)
                case let container as ValueContainer<String>:
                    TextField(label, text: container.binding, prompt: Text(container.placeholderText))
                case let container as ValueContainer<String?>:
                    TextField(label, text: container.bindingNonOptional, prompt: Text(container.placeholderText))
                case let container as ValueContainer<Int64?>:
                    TextField(
                        label,
                        value: container.binding,
                        formatter: NumberFormatter(),
                        prompt: Text(container.placeholderText)
                    )
                default:
                    Text("Unsupported type \(type(of: container))")
                }
            }
            .foregroundStyle(readOnly ? Color.label.opacity(0.6) : .label)
            .disabled(!isEditing || readOnly)
        }
    }
}

private struct ValueContainer<T: Sendable>: Sendable {
    let binding: Binding<T>
    let initialValue: T
}

extension ValueContainer where T == String {
    var placeholderText: String {
        initialValue.nilIfEmpty ?? "(없음)"
    }
}

extension ValueContainer where T == String? {
    var bindingNonOptional: Binding<String> {
        .init(get: { binding.wrappedValue ?? "" }, set: { binding.wrappedValue = $0 })
    }

    var placeholderText: String {
        initialValue?.nilIfEmpty ?? "(없음)"
    }
}

extension ValueContainer where T == Int64? {
    var placeholderText: String {
        initialValue.flatMap { "\($0)" } ?? "(없음)"
    }
}

struct DetailLabel: View {
    let text: String
    var body: some View {
        VStack {
            Text(text)
                .padding(.trailing, 10)
                .padding(.top, 2.5)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.6)))
                .lineLimit(1)
                .frame(maxWidth: 84, maxHeight: .infinity, alignment: .topLeading)
        }
    }
}
