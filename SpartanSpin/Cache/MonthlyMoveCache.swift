//
//  MonthlyMoveCache.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/10/25.
//

import Foundation

class MonthlyMoveCache: MonthlyMoveCaching {
    private let userDefaults: UserDefaults
    
    private let cacheKey = "cachedMonthlyMove"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func cache(_ move: MonthlyMove) {
        guard let encoded = try? JSONEncoder().encode(move) else { return }
        userDefaults.set(encoded, forKey: cacheKey)
    }
    
    func getCached() -> MonthlyMove? {
        guard let data = userDefaults.data(forKey: cacheKey) else { return nil }
        guard let move = try? JSONDecoder().decode(MonthlyMove.self, from: data) else { return nil }
        
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        guard move.month == currentMonth && move.year == currentYear else {
            clearCache()
            return nil
        }
        
        return move
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
    }
}
