//
//  TodoApp.swift
//  Todo
//
//  Created by William Lopez on 6/10/22.
//

import SwiftUI
import ComposableArchitecture

@main
struct TodoApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView(
                store: Store(initialState: AppState(), reducer: appReducer, environment: AppEnvironment(uuid: UUID.init, mainQueue: .main, notificationCenter: UNUserNotificationCenter.current() )))
        }
    }
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
}
