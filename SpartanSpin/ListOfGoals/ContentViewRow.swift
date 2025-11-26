//
//  ContentViewRow.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/13/25.
//

import SwiftUI

struct ContentViewRow: View {
    @StateObject private var viewModel: ViewModel
    
    @ObservedObject var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
        let viewModel = ViewModel(goal: goal)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        HStack {
            VStack {
                Text(goal.goalTitle)
                    .font(.system(
                        size: Numbers.goalTitleFontSize,
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
                    Text(LocalizedStringKey(viewModel.createFraction(goal: goal)))
                        .foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController()
    
    ContentViewRow(goal: Goal.example(controller: persistenceController))
        .background(Colors.spartanSpinGreen)
        .environmentObject(persistenceController)
}
