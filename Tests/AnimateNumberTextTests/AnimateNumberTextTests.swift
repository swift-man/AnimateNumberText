//
//  AnimateNumberTextTests.swift
//
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation
import Testing
@testable import AnimateNumberText

struct AnimateNumberTextTests {
  @Test
  func zero() {
    let formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                              stringFormatter: nil)

    #expect(formatter.string(from: 0) == "0")
  }

  @Test
  func currencyNumberStyle() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 0
    let formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                              stringFormatter: nil)

    #expect(formatter.string(from: 5000000) == "$5,000,000")
  }

  @Test
  func numberStyleKoKR() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "ko-KR")
    numberFormatter.numberStyle = .currency
    let formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                              stringFormatter: nil)

    #expect(formatter.string(from: 100) == "₩100")
  }

  @Test
  func decimalNumberStyle() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.numberStyle = .decimal
    let formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                              stringFormatter: "%@원")

    #expect(formatter.string(from: 10000000) == "10,000,000원")
  }

  @Test
  func maximumFractionDigitsZero() {
    let formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                              stringFormatter: "%@원")

    #expect(formatter.string(from: 10.23) == "10원")
  }

  @Test
  func stringFormat() {
    let formatter = AnimateNumberTextFomatter(numberFormatter: nil,
                                              stringFormatter: "%@ ms")

    #expect(formatter.string(from: 10.23) == "10 ms")
  }

  @Test
  func maximumFractionDigitsTwo() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.maximumFractionDigits = 2
    let formatter = AnimateNumberTextFomatter(numberFormatter: numberFormatter,
                                              stringFormatter: "%@ ms")

    #expect(formatter.string(from: 10.23) == "10.23 ms")
  }
}
