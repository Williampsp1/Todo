//
//  SubTodo.swift
//  Todo
//
//  Created by William Lopez on 6/14/22.
//

import SwiftUI
import ComposableArchitecture

struct SubTodo: Equatable, Identifiable {
    let id: UUID
    var description = ""
    var checked = false
}

enum SubTodoAction: Equatable {
    case subTodoChecked
    case textFieldChanged(String)
}

struct SubTodoEnvironment {
}

let subTodoReducer: Reducer<SubTodo, SubTodoAction, Void> = Reducer {
    state, action, _ in
    switch action {
    case .subTodoChecked:
        state.checked.toggle()
        return .none
        
    case let .textFieldChanged(description):
        state.description = description
        return .none
    }
}

struct SubTodoView: View {
    let store: Store<SubTodo, SubTodoAction>
    var colorScheme: ColorScheme
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            HStack {
                Image(systemName: viewStore.checked ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(viewStore.checked ? .green : colorScheme == .dark ? .white : .black)
                    .onTapGesture {
                        viewStore.send(.subTodoChecked)
                    }
                TextField("", text: viewStore.binding(get: \.description, send: SubTodoAction.textFieldChanged))
            }
        }
    }
}
