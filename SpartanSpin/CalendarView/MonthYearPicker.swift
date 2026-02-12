//
//  MonthYearPicker.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 1/15/26.
//

import SwiftUI

struct MonthYearPicker: View {
    @Binding var selectedDate: Date
    
    @State private var selectedMonth: Int
    @State private var selectedYear: Int
    
    private let months = Calendar.current.monthSymbols
    private let years: [Int]
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        
        let components = Calendar.current.dateComponents([.month, .year], from: selectedDate.wrappedValue)
        self._selectedMonth = State(initialValue: components.month ?? 1)
        self._selectedYear = State(initialValue: components.year ?? 2024)
        
        self.years = Array((1900)...(3000))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) { month in
                    Text(months[month - 1])
                        .tag(month)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 150)
            
            Picker("Year", selection: $selectedYear) {
                ForEach(years, id: \.self) { year in
                    Text(String(year))
                        .tag(year)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)
        }
        .onChange(of: selectedMonth) { newMonth in
            updateDate(month: newMonth, year: selectedYear)
        }
        .onChange(of: selectedYear) { newYear in
            updateDate(month: selectedMonth, year: newYear)
        }
    }
    
    private func updateDate(month: Int, year: Int) {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        if let newDate = Calendar.current.date(from: components) {
            selectedDate = newDate
        }
    }
}

#Preview {
    MonthYearPicker(selectedDate: .constant(.now))
}
