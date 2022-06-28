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
    let content = UNMutableNotificationContent()
    let notificationInterval: Double = 5
}

enum AppAction: Equatable {
    case addTodo
    case removeTodo(IndexSet)
    case todo(index: Todo.ID, action: TodoAction)
    case clearTodos
    case clearCompletedTodos
    case moveTodo(source: IndexSet, destination: Int)
    case sortCompletedTodos
    case showNotificationPermission
    case addNotification
    case openSettings
}

struct AppEnvironment {
    let uuid: () -> UUID
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var notificationCenter: UNUserNotificationCenter
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
            
        case .addNotification:
            state.content.title = "Todos"
            state.content.subtitle = "Review your incomplete Todos for today!"
            state.content.sound = UNNotificationSound.default
            
            // show this notification only if there are any incomplete todos
            if !state.todos.allSatisfy(\.checked) {
                
                environment.notificationCenter.removeAllPendingNotificationRequests()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: state.notificationInterval, repeats: false)
                
                // choose notification identifier
                let request = UNNotificationRequest(identifier: "TODO", content: state.content, trigger: trigger)
                
                // add our notification request
                environment.notificationCenter.add(request)
            }
            return .none
        case .showNotificationPermission:
            environment.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("Permissions accepted!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            return .none
            
        case .openSettings:
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
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
    
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    print("App is in foreground")
                    viewStore.send(.showNotificationPermission)
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    print("App is in background")
                    viewStore.send(.addNotification)
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
            store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(uuid: UUID.init, mainQueue: .main, notificationCenter: UNUserNotificationCenter.current())))
    }
}
