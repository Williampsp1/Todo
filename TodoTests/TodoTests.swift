//
//  TodoTests.swift
//  TodoTests
//
//  Created by William Lopez on 6/10/22.
//

import XCTest
@testable import Todo
import ComposableArchitecture

class TodoTests: XCTestCase {
    
    let scheduler = DispatchQueue.test
    let mockTodos: IdentifiedArrayOf<Todo> = [Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!), Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!), Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,checked: true)]
    
    func testAddTodo() {
        let store = TestStore(initialState: .init(), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.addTodo) {
            let todo = Todo(id: store.environment.uuid())
            $0.todos = [todo]
        }
    }
    
    func testDeleteTodo() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.removeTodo([0])) {
            $0.todos = [$0.todos[1], $0.todos[2]]
        }
    }
    
    func testClearAllTodos() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.clearTodos) {
            $0.todos = []
        }
    }
    
    func testClearCompletedTodos() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.clearCompletedTodos) {
            $0.todos = [$0.todos[0], $0.todos[1]]
        }
    }
    
    func testMoveTodos() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.moveTodo(source: [0], destination: 2)) {
            $0.todos.swapAt(0, 1)
        }
    }
    
    func testCheckTodo() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.todo(index: store.state.todos[0].id, action: .todoChecked)) {
            $0.todos[id: store.state.todos[0].id]?.checked = true
        }
        
        self.scheduler.advance(by: 1)
        
        store.receive(.sortCompletedTodos) {
            $0.todos = [$0.todos[1],$0.todos[0],$0.todos[2]]
        }
    }
    
    func testTextFieldChangedTodo() {
        let store = TestStore(initialState: AppState(todos: mockTodos), reducer: appReducer, environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000003")! }, mainQueue: self.scheduler.eraseToAnyScheduler(), notificationCenter: UNUserNotificationCenter.current()))
        
        store.send(.todo(index: store.state.todos[0].id, action: .textFieldChanged("Gym"))) {
            $0.todos[id: store.state.todos[0].id]?.task = "Gym"
        }
    }
}
