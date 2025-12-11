//
//  MonthlyMoveService.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/5/25.
//

import Foundation

protocol MonthlyMoveService {
    func fetchMoves() async throws -> [MonthlyMove]
}
