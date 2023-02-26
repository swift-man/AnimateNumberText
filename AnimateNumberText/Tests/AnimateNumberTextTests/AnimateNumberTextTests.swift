//
//  AnimateNumberTextTests.swift
//
//
//  Created by SwiftMan on 2023/02/26.
//

import XCTest
@testable import AnimateNumberText

final class AnimateNumberTextTests: XCTestCase {
  var formatter: AnimateNumberTextFomatter!
  
  func testZero() throws {
    formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                          stringFormatter: nil)
    
    XCTAssertEqual("0", formatter.string(from: 0))
  }
  
  func testCurrencyNumberStyle() throws {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale.current
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 0
    formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                          stringFormatter: nil)
    
    XCTAssertEqual("$5,000,000", formatter.string(from: 5000000))
  }
  
  func testNumberStyle_koKR() throws {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "ko-KR")
    numberFormatter.numberStyle = .currency
    formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                          stringFormatter: nil)
    
    XCTAssertEqual("₩100", formatter.string(from: 100))
  }
  
  func testDecimalNumberStyle() throws {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                          stringFormatter: "%@원")
    
    XCTAssertEqual("10,000,000원", formatter.string(from: 10000000))
  }
  
  func testMaximumFractionDigits_zero() throws {
    formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                          stringFormatter: "%@원")
    
    XCTAssertEqual("10원", formatter.string(from: 10.23))
  }
  
  func testStringFormat() throws {
    formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                          stringFormatter: "%@ ms")
    
    XCTAssertEqual("10 ms", formatter.string(from: 10.23))
  }
  
  func testMaximumFractionDigits_two() throws {
    let numberFormatter = NumberFormatter()
    numberFormatter.maximumFractionDigits = 2
    formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                          stringFormatter: "%@ ms")
    
    XCTAssertEqual("10.23 ms", formatter.string(from: 10.23))
  }
}
