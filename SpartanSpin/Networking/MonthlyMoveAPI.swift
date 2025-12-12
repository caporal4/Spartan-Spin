//
//  MonthlyMoveAPI.swift
//  SpartanSpin
//
//  Created by Brendan Caporale on 12/5/25.
//

import Foundation

final class MonthlyMoveAPI: MonthlyMoveService {
    private let session: URLSession
    private let url = URL(string: "https://caporal4.github.io/monthlyMove.json")
    
    init(session: URLSession? = nil) {
        if let session = session {
            // Test path: use injected session
            self.session = session
        } else {
            // Production path: use custom config
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForResource = 10
            config.waitsForConnectivity = true
            config.httpMaximumConnectionsPerHost = 6
            config.requestCachePolicy = .useProtocolCachePolicy
            config.allowsCellularAccess = true
            config.allowsExpensiveNetworkAccess = true
            config.allowsConstrainedNetworkAccess = true
            self.session = URLSession(configuration: config)
        }
    }

    func fetchMoves() async throws -> [MonthlyMove] {
        guard let url = url else { return [] }
        let (data, _) = try await session.data(from: url)
        return try JSONDecoder().decode([MonthlyMove].self, from: data)
    }
}
