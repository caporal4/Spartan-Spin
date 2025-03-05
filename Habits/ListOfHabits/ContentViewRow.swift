//
//  ContentViewRow.swift
//  Habits
//
//  Created by Brendan Caporale on 3/4/25.
//

import SwiftUI

struct ContentViewRow: View {
    @ObservedObject var habit: Habit
    
    var body: some View {
        HStack {
            VStack {
                Text(habit.habitTitle)
                    .font(.system(
                        size: Numbers.habitTitleFontSize,
                        weight: .bold,
                        design: .default)
                    )
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("Progress:")
                    .font(.headline)
                    .foregroundStyle(.white)
                HStack {
                    Text("\(habit.tasksCompleted)/\(habit.tasksNeeded)")
                        .foregroundStyle(.white)
                    Text(LocalizedStringKey(habit.habitUnit))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    ContentViewRow(habit: .example)
}
