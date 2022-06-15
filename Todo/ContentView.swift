//
//  ContentView.swift
//  Todo
//
//  Created by William Lopez on 6/10/22.
//

import SwiftUI
import ComposableArchitecture

struct AppState: Equatable {
    var todos: IdentifiedArrayOf<Todo> = []
}

enum AppAction: Equatable {
    case addTodo
    case removeTodo(IndexSet)
    case todo(index: Todo.ID, action: TodoAction)
    case clearTodos
    case clearCompletedTodos
    case moveTodo(source: IndexSet, destination: Int)
    case sortCompletedTodos
}

struct AppEnvironment {
    let uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    todoReducer.forEach(state: \.todos,
                        action: /AppAction.todo(index:action:),
                        environment: { TodoEnvironment(uuid: $0.uuid) }),
    Reducer { state, action, environment in
        switch action {
        case .addTodo:
            state.todos.insert(Todo(id: environment.uuid()), at: 0)
            return .none
            
        case .todo(index: _, action: .todoChecked):
            struct TodoCompletionId: Hashable {}
            
            return Effect(value: .sortCompletedTodos)
                .debounce(id: TodoCompletionId(), for: 1, scheduler: environment.mainQueue.animation())
            
        case let .removeTodo(index):
            state.todos.remove(atOffsets: index)
            return .none
            
        case .clearTodos:
            state.todos = []
            return .none
            
        case let .moveTodo(source, destination):
            state.todos.move(fromOffsets: source, toOffset: destination)
            return .none
            
        case .clearCompletedTodos:
            state.todos.removeAll(where: \.checked)
            return .none
            
        case .todo(index: let index, action: .textFieldChanged(_)):
            return .none
            
        case .sortCompletedTodos:
            state.todos.sort { $1.checked && !$0.checked }
            return .none
            
        case let .todo(index, action: .removeSubTodo(_)):
            return .none
            
        case let .todo(index, action: .addSubTodo):
            return .none
            
        case let .todo(index, action: .subTodo(idx, action: action)):
            return .none
            
        case let .todo(index, action: .clearSubTodos):
            return .none
            
        case let .todo(index, action: .clearCompletedSubTodos):
            return .none
            
        case let .todo(index, action: .moveSubTodo(source, destination)):
            return .none
        }
    }
)

struct ContentView: View {
    let store: Store<AppState, AppAction>
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store) { viewStore in
                List {
                    ForEachStore(self.store.scope(state: \.todos, action: AppAction.todo(index:action:))) {
                        TodoView(store: $0, colorScheme: colorScheme)
                    }
                    .onDelete { viewStore.send(.removeTodo($0)) }
                    .onMove { viewStore.send(.moveTodo(source: $0, destination: $1))}
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItemGroup {
                    ToolbarItems(store: self.store, colorScheme: colorScheme)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        ContentView(
            store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(uuid: UUID.init, mainQueue: .main)))
    }
}
