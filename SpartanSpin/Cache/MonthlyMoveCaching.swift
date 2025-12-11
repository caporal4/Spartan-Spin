//
//  MonthlyMoveCaching.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/10/25.
//

import Foundation

protocol MonthlyMoveCaching {
    func cache(_ move: MonthlyMove)
    func getCached() -> MonthlyMove?
    func clearCache()
}
