//
//  ToolbarItems.swift
//  Todo
//
//  Created by William Lopez on 6/11/22.
//

import SwiftUI
import ComposableArchitecture

struct ToolbarItems: View {
    let store: Store<AppState, AppAction>
    var colorScheme: ColorScheme
    
    var body: some View {
        HStack {
            addTodo
            configuration
            EditButton()
                .foregroundColor(colorScheme == .dark ? .red : .blue)
        }
    }
    
    var addTodo: some View {
        WithViewStore(self.store) { viewStore in
            Button(action: { viewStore.send(.addTodo)
            }) {
                Image(systemName: "plus")
                    .foregroundColor(colorScheme == .dark ? .red : .blue)
            }
        }
    }
    
    var configuration: some View {
        WithViewStore(self.store) { viewStore in
            Menu {
                Button(action: { viewStore.send(.clearTodos)
                }) {
                    Text("Clear all")
                }
                Button(action: { viewStore.send(.clearCompletedTodos)
                }) {
                    Text("Clear completed todos")
                }
            }
        label: {
            Image(systemName: "gearshape")
                .foregroundColor(colorScheme == .dark ? .red : .blue)
            
        }
        }
    }
}
