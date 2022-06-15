//
//  SubTodoTests.swift
//  TodoTests
//
//  Created by William Lopez on 6/14/22.
//

import XCTest
@testable import Todo
import ComposableArchitecture

class SubTodoTests: XCTestCase {
    
    let mockSubTodos: IdentifiedArrayOf<SubTodo> = [SubTodo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!), SubTodo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!), SubTodo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,checked: true)]

    func testAddSubTodo() {
        let store = TestStore(initialState: Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!), reducer: todoReducer, environment: TodoEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000005")! }))
        
        store.send(.addSubTodo) {
            let subTodo = SubTodo(id: store.environment.uuid())
            $0.subTodos = [subTodo]
        }
    }
    
    func testDeleteSubTodo() {
        let store = TestStore(initialState: Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, subTodos: mockSubTodos), reducer: todoReducer, environment: TodoEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000005")! }))
        
        store.send(.removeSubTodo([0])) {
            $0.subTodos = [$0.subTodos[1], $0.subTodos[2]]
        }
    }
    
    func testMoveSubTodos() {
        let store = TestStore(initialState: Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, subTodos: mockSubTodos), reducer: todoReducer, environment: TodoEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000005")! }))
        
        store.send(.moveSubTodo(source: [0], destination: 2)) {
            $0.subTodos.swapAt(0, 1)
        }
    }
    
    func testCheckSubTodo() {
        let store = TestStore(initialState: Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, subTodos: mockSubTodos), reducer: todoReducer, environment: TodoEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000005")! }))
        
        store.send(.subTodo(index: store.state.subTodos[0].id, action: .subTodoChecked)) {
            $0.subTodos[id: store.state.subTodos[0].id]?.checked = true
        }
    }
    
    func testTextFieldChangedTodo() {
        let store = TestStore(initialState: Todo(id: UUID(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-DEADBEEFDEAD")!, subTodos: mockSubTodos), reducer: todoReducer, environment: TodoEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000005")! }))

        store.send(.subTodo(index: store.state.subTodos[0].id, action: .textFieldChanged("Gym"))) {
            $0.subTodos[id: store.state.subTodos[0].id]?.description = "Gym"
        }
    }

}
