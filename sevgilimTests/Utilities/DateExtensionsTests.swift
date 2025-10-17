//
//  DateExtensionsTests.swift
//  sevgilimTests
//
//  Unit tests for Date extensions

import XCTest
@testable import sevgilim

final class DateExtensionsTests: XCTestCase {
    
    // MARK: - Days Between Tests
    
    func testDaysBetweenSameDate() {
        // Given: Same date
        let date = Date()
        
        // When: Calculating days between
        let days = date.daysBetween(date)
        
        // Then: Should be 0
        XCTAssertEqual(days, 0, "Days between same date should be 0")
    }
    
    func testDaysBetweenOneDayApart() {
        // Given: Two dates one day apart
        let calendar = Calendar.current
        let today = Date()
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        // When: Calculating days between
        let days = today.daysBetween(tomorrow)
        
        // Then: Should be 1
        XCTAssertEqual(days, 1, "Should be 1 day apart")
    }
    
    func testDaysBetweenOneWeekApart() {
        // Given: Two dates one week apart
        let calendar = Calendar.current
        let today = Date()
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        // When: Calculating days between
        let days = today.daysBetween(nextWeek)
        
        // Then: Should be 7
        XCTAssertEqual(days, 7, "Should be 7 days apart")
    }
    
    func testDaysBetweenOneYearApart() {
        // Given: Two dates one year apart
        let calendar = Calendar.current
        let today = Date()
        let nextYear = calendar.date(byAdding: .year, value: 1, to: today)!
        
        // When: Calculating days between
        let days = today.daysBetween(nextYear)
        
        // Then: Should be approximately 365 days (accounting for leap years)
        XCTAssertGreaterThanOrEqual(days, 365, "Should be at least 365 days")
        XCTAssertLessThanOrEqual(days, 366, "Should be at most 366 days")
    }
    
    func testDaysBetweenPastDate() {
        // Given: Date in the past
        let calendar = Calendar.current
        let today = Date()
        let pastDate = calendar.date(byAdding: .day, value: -30, to: today)!
        
        // When: Calculating days between
        let days = pastDate.daysBetween(today)
        
        // Then: Should be 30
        XCTAssertEqual(days, 30, "Should be 30 days since past date")
    }
    
    // MARK: - Formatted Difference Tests
    
    func testFormattedDifferenceWithinFirstWeek() {
        // Given: Date within first week
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -5, to: Date())!
        let endDate = Date()
        
        // When: Getting formatted difference
        let formatted = endDate.formattedDifference(from: startDate)
        
        // Then: Should mention days
        XCTAssertTrue(formatted.contains("gün") || formatted.contains("day"), "Should mention days")
    }
    
    func testFormattedDifferenceWithMonths() {
        // Given: Date months apart
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .month, value: -2, to: Date())!
        let endDate = Date()
        
        // When: Getting formatted difference
        let formatted = endDate.formattedDifference(from: startDate)
        
        // Then: Should mention months
        XCTAssertTrue(formatted.contains("ay") || formatted.contains("month"), "Should mention months")
    }
    
    func testFormattedDifferenceWithYears() {
        // Given: Date years apart
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .year, value: -1, to: Date())!
        let endDate = Date()
        
        // When: Getting formatted difference
        let formatted = endDate.formattedDifference(from: startDate)
        
        // Then: Should mention years
        XCTAssertTrue(formatted.contains("yıl") || formatted.contains("year"), "Should mention years")
    }
    
    // MARK: - Edge Cases
    
    func testDaysBetweenAcrossMonthBoundary() {
        // Given: Dates across month boundary
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 31))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 2, day: 1))!
        
        // When: Calculating days between
        let days = startDate.daysBetween(endDate)
        
        // Then: Should be 1
        XCTAssertEqual(days, 1, "Should be 1 day across month boundary")
    }
    
    func testDaysBetweenAcrossYearBoundary() {
        // Given: Dates across year boundary
        let calendar = Calendar.current
        let startDate = calendar.date(from: DateComponents(year: 2024, month: 12, day: 31))!
        let endDate = calendar.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        
        // When: Calculating days between
        let days = startDate.daysBetween(endDate)
        
        // Then: Should be 1
        XCTAssertEqual(days, 1, "Should be 1 day across year boundary")
    }
}
