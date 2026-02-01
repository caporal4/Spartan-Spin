//
//  RecordRow.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/31/26.
//

import SwiftUI

struct RecordRow: View {
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel

    @ObservedObject var goal: Goal
    
    let date: Date
    
    var body: some View {
        if let record = goal.findRecord(for: date, records: mainViewModel.goalRecords, timeline: "Monthly") {
            HStack {
                VStack {
                    Text(record.recordTitle)
                        .font(.system(
                            size: Numbers.goalTitleFontSize,
                            weight: .bold,
                            design: .default)
                        )
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white)
                }
                Spacer()
                Text(record.streakSentence())
                    .foregroundStyle(.white)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Progress:")
                        .font(.headline)
                        .foregroundStyle(.white)
                    HStack {
                        Text(LocalizedStringKey(record.createFraction()))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }

}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    
    RecordRow(goal: Goal.example(controller: .preview), date: Date.now)
        .background(Colors.spartanSpinGreen)
        .environmentObject(mainViewModel)
}
