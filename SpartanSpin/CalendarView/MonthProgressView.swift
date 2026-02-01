//
//  MonthProgressView.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct MonthProgressView: View {
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel
    
    var body: some View {
        if !mainViewModel.goals.monthlyGoals.isEmpty {
            ForEach(mainViewModel.goals.monthlyGoals) { goal in
                ZStack(alignment: .leading) {
                    ContentViewRectangle()
                    RecordRow(goal: goal, date: mainViewModel.displayedMonth)
                }
                .listRowBackground(Colors.spartanSpinGreen)
                .accessibilityIdentifier(goal.goalTitle)
            }
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    
    MonthProgressView()
        .environmentObject(mainViewModel)
}
