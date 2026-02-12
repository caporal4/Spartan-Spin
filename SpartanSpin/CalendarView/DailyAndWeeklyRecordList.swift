//
//  DailyAndWeeklyRecordList.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import SwiftUI

struct DailyAndWeeklyRecordList: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mainViewModel: MainTabView.ViewModel

    var date: DateComponents
    let timeline: String
    let calendar = Calendar.current
    
    var records: [GoalRecord] {
        mainViewModel.goalRecords.filter { record in
            guard record.goal == nil else {
                return false
            }
            
            guard let recordDate = record.date,
                  let componentsDate = calendar.date(from: date) else {
                return false
            }
            
            guard record.recordTimeline == timeline else { return false }
            
            switch timeline {
            case "Daily":
                return calendar.isDate(recordDate, inSameDayAs: componentsDate)
            case "Weekly":
                return calendar.isDate(recordDate, equalTo: componentsDate, toGranularity: .weekOfYear)

            default:
                return false
            }
        }.sorted {
            $0.recordTitle < $1.recordTitle
        }
    }
    
    var inactiveRecords: [GoalRecord] {
        mainViewModel.goalRecords.filter { record in
            guard record.goal != nil else {
                return false
            }
            guard let recordDate = record.date,
                  let componentsDate = calendar.date(from: date) else {
                return false
            }
                
            guard record.recordTimeline == timeline else { return false }
            
            switch timeline {
            case "Daily":
                return calendar.isDate(recordDate, inSameDayAs: componentsDate)
            case "Weekly":
                return calendar.isDate(recordDate, equalTo: componentsDate, toGranularity: .weekOfYear)

            default:
                return false
            }
        }.sorted {
            $0.recordTitle < $1.recordTitle
        }
    }
    
    var body: some View {
        if !records.isEmpty || !inactiveRecords.isEmpty {
            List {
                Section("\(timeline) Goals") {
                    ForEach(records) { record in
                        ZStack(alignment: .leading) {
                            ContentViewRectangle()
                            RecordRow(record: record)
                        }
                        .listRowBackground(Colors.spartanSpinGreen)
                        .accessibilityIdentifier(record.recordTitle)
                    }
                }
                Section("Inactive \(timeline) Goals") {
                    ForEach(records) { record in
                        ZStack(alignment: .leading) {
                            ContentViewRectangle()
                            RecordRow(record: record)
                        }
                        .listRowBackground(Colors.spartanSpinGreen)
                        .accessibilityIdentifier(record.recordTitle)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(timeline == "Daily" ? formatDate(date) : formatWeekRange(date, addSixDays(to: date)))
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                }
            }
            .modifier(HideTabBarIfAvailable())
            .scrollContentBackground(.hidden)
            .background(Colors.gradientC.ignoresSafeArea())
        } else {
            ZStack {
                Colors.gradientC
                    .ignoresSafeArea()
                Text(timeline == "Daily" ? "No Data for Selected Date" : "No Data for Selected Dates")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(timeline == "Daily" ? formatDate(date) : formatWeekRange(date, addSixDays(to: date)))
                        .font(.headline)
                        .foregroundStyle(colorScheme == .dark ? .white : Colors.spartanSpinGreen)
                }
            }
            .modifier(HideTabBarIfAvailable())
        }
    }
    func addSixDays(to dateComponents: DateComponents) -> DateComponents {
        let calendar = Calendar.current
        
        // Convert DateComponents to Date
        guard let date = calendar.date(from: dateComponents) else {
            return dateComponents
        }
        
        // Add 6 days
        guard let newDate = calendar.date(byAdding: .day, value: 6, to: date) else {
            return dateComponents
        }
        
        // Convert back to DateComponents
        return calendar.dateComponents([.year, .month, .day], from: newDate)
    }
    func formatWeekRange(_ startDate: DateComponents, _ endDate: DateComponents) -> String {
        guard let startDay = startDate.day, let startMonth = startDate.month, let startYear = startDate.year,
              let endDay = endDate.day, let endMonth = endDate.month, let endYear = endDate.year else {
            return ""
        }
        
        let monsS = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let monsL = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
        
        let startForm = "\(startDay)\(daySuffix(for: startDay))"
        let endForm = "\(endDay)\(daySuffix(for: endDay))"
        
        // Different years
        if startYear != endYear {
            return "\(monsS[startMonth - 1]) \(startForm) \(startYear) - \(monsS[endMonth - 1]) \(endForm) \(endYear)"
        }
        // Same month
        else if startMonth == endMonth {
            return "\(monsL[startMonth - 1]) \(startForm)-\(endForm) \(endYear)"
        }
        // Different months, same year
        else {
            return "\(monsS[startMonth - 1]) \(startForm) - \(monsS[endMonth - 1]) \(endForm) \(endYear)"
        }
    }
    func formatDate(_ date: DateComponents) -> String {
        guard let day = date.day, let month = date.month, let year = date.year else {
            return ""
        }
        
        let monthNames = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
        
        let monthName = monthNames[month - 1]
        let dayWithSuffix = "\(day)\(daySuffix(for: day))"
        
        return "\(monthName) \(dayWithSuffix) \(year)"
    }

    func daySuffix(for day: Int) -> String {
        switch day {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

#Preview {
    DailyAndWeeklyRecordList(
        date: DateComponents(calendar: .current, year: 2025, month: 11, day: 12),
        timeline: "Weekly"
    )
}
