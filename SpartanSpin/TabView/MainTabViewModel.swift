//
//  MainTabViewModel.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 11/29/25.
//

import Foundation

extension MainTabView {
    class ViewModel: ObservableObject {
        var persistenceController: PersistenceController
        
        @Published var selectedDate: DateComponents?
        var calendar: Calendar = .current
        
        @Published var showingDetail = false
        
        let today = Date()
        
        func setToday() {
            selectedDate = Calendar.current.dateComponents([.day, .month, .year], from: today)
        }
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
            self.selectedDate = Calendar.current.dateComponents([.day, .month, .year], from: Date())
        }
    }
}
