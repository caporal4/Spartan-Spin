//
//  MonthlyRecordList.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/6/26.
//

import SwiftUI

struct MonthlyRecordList: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel

    let calendar = Calendar.current
    
    let timeline: String
    
    var records: [GoalRecord] {
        mainViewModel.goalRecords.filter { record in
            guard let recordDate = record.date else { return false }
            
            guard record.recordTimeline == timeline else { return false }
            
            switch timeline {
            case "Monthly":
                return calendar.isDate(recordDate, equalTo: mainViewModel.displayedMonth, toGranularity: .month)
            default:
                return false
            }
        }.sorted {
            $0.recordTitle < $1.recordTitle
        }
    }
    
    var body: some View {
        if !records.isEmpty {
            ForEach(records) { record in
                ZStack(alignment: .leading) {
                    ContentViewRectangle()
                    RecordRow(record: record)
                }
                .listRowBackground(Colors.spartanSpinGreen)
                .accessibilityIdentifier(record.recordTitle)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Spartan Spin")
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                }
            }
        } else {
            Text("No Data for \(mainViewModel.displayedMonth.formatted(.dateTime.month(.wide).year()))")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

#Preview {
    let persistenceController = PersistenceController.preview
    let mainViewModel = MainTabView.ViewModel(persistenceController: persistenceController)
    
    MonthlyRecordList(timeline: "Monthly")
        .environmentObject(mainViewModel)
}
