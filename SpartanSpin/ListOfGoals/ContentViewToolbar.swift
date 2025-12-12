//
//  ContentViewToolbar.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/11/25.
//

import SwiftUI

struct ContentViewToolbarModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let showNewGoalView: () -> Void
    let createSampleData: () -> Void
    let deleteAll: () -> Void
    let removeAllNotifications: () -> Void
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Spartan Spin")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                }
                ToolbarItem {
                    Button(action: showNewGoalView) {
                        Label("Add Goal", systemImage: "plus.app")
                    }
                    .tint(colorScheme == .dark ? .white : .black)
                    
                }
    #if DEBUG
                ToolbarItem {
                    Button {
                        createSampleData()
                    } label: {
                        Label("ADD SAMPLES", systemImage: "list.bullet")
                    }
                    .tint(colorScheme == .dark ? .white : .black)
                    
                }
                ToolbarItem {
                    Button {
                        deleteAll()
                        removeAllNotifications()
                    } label: {
                        Label("DELETE SAMPLES", systemImage: "trash")
                    }
                    .tint(colorScheme == .dark ? .white : .black)
                    
                }
    #endif
            }
    }
}

extension View {
    func contentViewToolbar(
        showNewGoalView: @escaping () -> Void,
        createSampleData: @escaping () -> Void,
        deleteAll: @escaping () -> Void,
        removeAllNotifications: @escaping () -> Void
    ) -> some View {
        modifier(ContentViewToolbarModifier(
            showNewGoalView: showNewGoalView,
            createSampleData: createSampleData,
            deleteAll: deleteAll,
            removeAllNotifications: removeAllNotifications
        ))
    }
}

#Preview {
    Text("Preview")
        .modifier(
            ContentViewToolbarModifier(
                showNewGoalView: {},
                createSampleData: {},
                deleteAll: {},
                removeAllNotifications: {}
            )
        )
}
