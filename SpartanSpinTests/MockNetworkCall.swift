//
//  MockNetworkCall.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 12/11/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class MockNetworkCall: BaseTestCase {
    var api: MonthlyMoveAPI!
    var mockSession: URLSession!
     
    override func setUp() {
         super.setUp()
         mockSession = URLSession.makeMockSession()
         api = MonthlyMoveAPI(session: mockSession)
     }
     
     override func tearDown() {
         api = nil
         mockSession = nil
         MockURLProtocol.mockResponseData = nil
         MockURLProtocol.mockError = nil
         MockURLProtocol.mockStatusCode = 200
         super.tearDown()
     }
     
     func testFetchMovesSuccess() async throws {
         // Arrange: Create mock JSON data
         let mockMoves = [
             MonthlyMove(move: "Push-ups", month: "January", year: 2025),
             MonthlyMove(move: "Squats", month: "February", year: 2025),
             MonthlyMove(move: "Lunges", month: "March", year: 2025)
         ]
         
         let mockData = try JSONEncoder().encode(mockMoves)
         MockURLProtocol.mockResponseData = mockData
         MockURLProtocol.mockStatusCode = 200
         
         let moves = try await api.fetchMoves()
         
         XCTAssertEqual(moves.count, 3, "Should return 3 moves")
         XCTAssertEqual(moves[0].move, "Push-ups")
         XCTAssertEqual(moves[0].month, "January")
         XCTAssertEqual(moves[0].year, 2025)
         XCTAssertEqual(moves[1].move, "Squats")
         XCTAssertEqual(moves[2].move, "Lunges")
     }
     
     func testFetchMovesEmptyArray() async throws {
         let mockData = try JSONEncoder().encode([MonthlyMove]())
         MockURLProtocol.mockResponseData = mockData
         
         let moves = try await api.fetchMoves()
         
         XCTAssertEqual(moves.count, 0, "Should return empty array")
     }
     
     func testFetchMovesInvalidJSON() async {
         // Arrange: Invalid JSON data
         let invalidJSON = Data("{ this is not valid json }".utf8)
         MockURLProtocol.mockResponseData = invalidJSON
         
         // Act & Assert
         do {
             _ = try await api.fetchMoves()
             XCTFail("Should have thrown a decoding error")
         } catch {
             XCTAssertTrue(error is DecodingError, "Should be a DecodingError")
         }
     }
     
     func testFetchMovesMalformedData() async {
         // Arrange: JSON array with missing required fields
         let malformedJSON = Data("""
         [
             {
                 \"move\": \"Push-ups\",
                 \"month\": \"January\"
                 // Missing \"year\" field
             }
         ]
         """.utf8)
         
         MockURLProtocol.mockResponseData = malformedJSON
         
         // Act & Assert
         do {
             _ = try await api.fetchMoves()
             XCTFail("Should have thrown a decoding error for missing field")
         } catch {
             XCTAssertTrue(error is DecodingError)
         }
     }
 }
