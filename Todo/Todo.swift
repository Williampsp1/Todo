//
//  TODO.swift
//  Todo
//
//  Created by William Lopez on 6/11/22.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
    let id: UUID
    var task = ""
    var checked = false
    var subTodos: IdentifiedArrayOf<SubTodo> = []
}

enum TodoAction: Equatable {
    case textFieldChanged(String)
    case todoChecked
    case addSubTodo
    case subTodo(index: SubTodo.ID, action: SubTodoAction)
    case removeSubTodo(IndexSet)
    case clearSubTodos
    case clearCompletedSubTodos
    case moveSubTodo(source: IndexSet, destination: Int)
}

struct TodoEnvironment {
    let uuid: () -> UUID
}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment>.combine(subTodoReducer.forEach(
    state: \.subTodos,
    action: /TodoAction.subTodo(index:action:),
    environment: { _ in SubTodoEnvironment() }), Reducer {
        state, action, environment in
        switch action {
        case let .textFieldChanged(task):
            state.task = task
            return .none
            
        case .todoChecked:
            state.checked.toggle()
            return .none
            
        case .addSubTodo:
            state.subTodos.append(SubTodo(id: environment.uuid()))
            return .none
            
        case .subTodo(index: let index, action: let action):
            return .none
            
        case let .removeSubTodo(index):
            state.subTodos.remove(atOffsets: index)
            return .none
            
        case .clearSubTodos:
            state.subTodos = []
            return .none
            
        case .clearCompletedSubTodos:
            state.subTodos.removeAll(where: \.checked)
            return .none
            
        case let .moveSubTodo(source, destination):
            state.subTodos.move(fromOffsets: source, toOffset: destination)
            return .none
        }
    }
)

struct TodoView: View {
    let store: Store<Todo, TodoAction>
    var colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            WithViewStore(self.store) { viewStore in
                HStack {
                    TextField("Todo", text: viewStore.binding(get: \.task, send: TodoAction.textFieldChanged))
                    NavigationLink(destination: TodoInfo(store: self.store, colorScheme: colorScheme))
                    {
                        Text("")
                    }
                    Image(systemName: viewStore.checked ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(viewStore.checked ? .green : colorScheme == .dark ? .white : .black)
                        .onTapGesture {
                            viewStore.send(.todoChecked)
                        }
                }
            }
            
        }
    }
}

struct TodoInfo: View {
    let store: Store<Todo, TodoAction>
    var colorScheme: ColorScheme
    
    var body: some View {
        WithViewStore(self.store) { viewStore in
            List {
                ForEachStore(self.store.scope(state: \.subTodos, action: TodoAction.subTodo(index:action:))) {
                    SubTodoView(store: $0, colorScheme: colorScheme)
                }
                .onDelete { viewStore.send(.removeSubTodo($0)) }
                .onMove{ viewStore.send(.moveSubTodo(source: $0, destination: $1)) }
            }
            .toolbar {
                HStack {
                    Button(action: {
                        viewStore.send(.addSubTodo)
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(colorScheme == .dark ? .red : .blue)
                    }
                    EditButton()
                        .foregroundColor(colorScheme == .dark ? .red : .blue)
                }
            }
            .navigationTitle(viewStore.state.task)
        }
    }
}
