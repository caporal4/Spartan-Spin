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
        
        init(persistenceController: PersistenceController) {
            self.persistenceController = persistenceController
        }
    }
}
