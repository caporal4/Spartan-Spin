//
//  CacheTests.swift
//  SpartanSpinTests
//
//  Created by Brendan Caporale on 12/11/25.
//

import CoreData
import XCTest
@testable import SpartanSpin

final class CacheTests: BaseTestCase {
    var cache: MonthlyMoveCache!
    var testUserDefaults: UserDefaults!
    var suiteName: String!
    
    override func setUp() {
        super.setUp()
        
        suiteName = "com.yourapp.tests.\(UUID().uuidString)"
        testUserDefaults = UserDefaults(suiteName: suiteName)!
        
        cache = MonthlyMoveCache(userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        testUserDefaults.removePersistentDomain(forName: suiteName)
        testUserDefaults = nil
        cache = nil
        suiteName = nil
        
        super.tearDown()
    }
        
    func testCacheAndRetrieveMove() {
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        let move = MonthlyMove(
            move: "Push-ups",
            month: currentMonth,
            year: currentYear
        )
        
        cache.cache(move)
        
        let retrieved = cache.getCached()
        XCTAssertNotNil(retrieved, "Should retrieve cached move")
        XCTAssertEqual(retrieved?.move, "Push-ups")
        XCTAssertEqual(retrieved?.month, currentMonth)
        XCTAssertEqual(retrieved?.year, currentYear)
    }
        
    func testGetCachedReturnsNilWhenEmpty() {
        let retrieved = cache.getCached()
        
        XCTAssertNil(retrieved, "Should return nil when no data is cached")
    }
        
    func testClearCache() {
        // Arrange: Cache a move
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        let move = MonthlyMove(
            move: "Squats",
            month: currentMonth,
            year: currentYear
        )
        
        cache.cache(move)
        
        XCTAssertNotNil(cache.getCached(), "Move should be cached before clearing")
        
        cache.clearCache()
        
        let retrieved = cache.getCached()
        XCTAssertNil(retrieved, "Should return nil after clearing cache")
    }
        
    func testExpiredCacheWrongMonth() {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let previousMonth = currentMonth == 1 ? 12 : currentMonth - 1
        let previousMonthName = calendar.monthSymbols[previousMonth - 1]
        
        let oldMove = MonthlyMove(
            move: "Old Move",
            month: previousMonthName,
            year: currentYear
        )
        
        let encoded = try? JSONEncoder().encode(oldMove)
        testUserDefaults.set(encoded, forKey: "cachedMonthlyMove")
        
        let retrieved = cache.getCached()
        
        XCTAssertNil(retrieved, "Should return nil for expired month")
        
        let dataAfter = testUserDefaults.data(forKey: "cachedMonthlyMove")
        XCTAssertNil(dataAfter, "Cache should be cleared after detecting expired data")
    }
        
    func testExpiredCacheWrongYear() {
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        let lastYear = currentYear - 1
        
        let oldMove = MonthlyMove(
            move: "Last Year's Move",
            month: currentMonth,
            year: lastYear
        )
        
        let encoded = try? JSONEncoder().encode(oldMove)
        testUserDefaults.set(encoded, forKey: "cachedMonthlyMove")
        
        let retrieved = cache.getCached()
        
        XCTAssertNil(retrieved, "Should return nil for expired year")
        
        let dataAfter = testUserDefaults.data(forKey: "cachedMonthlyMove")
        XCTAssertNil(dataAfter, "Cache should be cleared after detecting expired data")
    }
    
    func testCorruptedCacheData() {
        let corruptedData = Data("This is not valid JSON".utf8)
        testUserDefaults.set(corruptedData, forKey: "cachedMonthlyMove")
        
        let retrieved = cache.getCached()
        
        XCTAssertNil(retrieved, "Should return nil for corrupted data")
    }
        
    func testOverwriteCache() {
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        let firstMove = MonthlyMove(
            move: "First Move",
            month: currentMonth,
            year: currentYear
        )
        
        cache.cache(firstMove)
        
        let secondMove = MonthlyMove(
            move: "Second Move",
            month: currentMonth,
            year: currentYear
        )
        
        cache.cache(secondMove)
        
        let retrieved = cache.getCached()
        XCTAssertNotNil(retrieved, "Should retrieve cached move")
        XCTAssertEqual(retrieved?.move, "Second Move", "Should retrieve the most recent cached move")
    }
        
    func testCacheWithSpecialCharacters() {
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        let move = MonthlyMove(
            move: "Jumping Jacks™ & High-Knees (30°)",
            month: currentMonth,
            year: currentYear
        )
        
        cache.cache(move)
        let retrieved = cache.getCached()
        
        XCTAssertEqual(retrieved?.move, "Jumping Jacks™ & High-Knees (30°)")
    }
        
    func testMultipleCacheInstancesShareData() {
        let cache1 = MonthlyMoveCache(userDefaults: testUserDefaults)
        let cache2 = MonthlyMoveCache(userDefaults: testUserDefaults)
        
        let calendar = Calendar.current
        let currentMonth = calendar.monthSymbols[calendar.component(.month, from: Date()) - 1]
        let currentYear = calendar.component(.year, from: Date())
        
        let move = MonthlyMove(
            move: "Shared Move",
            month: currentMonth,
            year: currentYear
        )
        
        cache1.cache(move)
        
        let retrieved = cache2.getCached()
        XCTAssertNotNil(retrieved, "Second instance should access same cached data")
        XCTAssertEqual(retrieved?.move, "Shared Move")
    }
}
