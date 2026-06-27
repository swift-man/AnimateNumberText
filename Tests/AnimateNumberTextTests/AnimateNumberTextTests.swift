//
//  AnimateNumberTextTests.swift
//
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation
import SwiftUI
import Testing
@testable import AnimateNumberText

struct AnimateNumberTextTests {
  @Test
  func zero() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: nil)

    #expect(formatter.string(from: 0) == "0")
  }

  @Test
  func currencyNumberStyle() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.numberStyle = .currency
    numberFormatter.maximumFractionDigits = 0
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: nil)

    #expect(formatter.string(from: 5000000) == "$5,000,000")
  }

  @Test
  func numberStyleKoKR() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "ko-KR")
    numberFormatter.numberStyle = .currency
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: nil)

    #expect(formatter.string(from: 100) == "₩100")
  }

  @Test
  func decimalNumberStyle() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.numberStyle = .decimal
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: "%@원")

    #expect(formatter.string(from: 10000000) == "10,000,000원")
  }

  @Test
  func defaultFormatterPreservesFractionDigits() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: "%@원")

    #expect(formatter.string(from: 10.23) == "10.23원")
  }

  @Test
  func defaultFormatterDoesNotAddGroupingSeparators() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: nil)

    #expect(formatter.string(from: 5000000) == "5000000")
  }

  @Test
  func stringFormat() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: "%@ ms")

    #expect(formatter.string(from: 10.23) == "10.23 ms")
  }

  @Test
  func stringFormatSupportsFloatingPointPlaceholder() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: "%.2f")

    #expect(formatter.string(from: 10.236) == "10.24")
  }

  @Test
  func stringFormatSupportsIntegerPlaceholder() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: "%d")

    #expect(formatter.string(from: 10.23) == "10")
  }

  @Test
  func stringFormatIntegerPlaceholderFallsBackForNonFiniteValues() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: "%d")

    #expect(formatter.string(from: Double.nan) == "NaN")
    #expect(formatter.string(from: Double.infinity) == "+∞")
  }

  @Test
  func stringFormatWithoutPlaceholderFallsBackToFormattedValue() {
    let formatter = AnimateNumberTextFormatter(numberFormatter: nil,
                                               stringFormatter: " ms")

    #expect(formatter.string(from: 10.23) == "10.23")
  }

  @Test
  func customFormatterCanDropFractionDigits() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.maximumFractionDigits = 0
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: "%@원")

    #expect(formatter.string(from: 10.23) == "10원")
  }

  @Test
  func formatterCopiesInjectedNumberFormatter() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.maximumFractionDigits = 0
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: nil)

    numberFormatter.maximumFractionDigits = 2

    #expect(formatter.string(from: 10.23) == "10")
  }

  @Test
  func maximumFractionDigitsTwo() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.maximumFractionDigits = 2
    let formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                               stringFormatter: "%@ ms")

    #expect(formatter.string(from: 10.23) == "10.23 ms")
  }

  @Test
  @MainActor
  func readOnlyValueInitializerCompiles() {
    let view = AnimateNumberText(value: 10.23)

    #expect(String(describing: type(of: view)) == "AnimateNumberText")
  }

  @Test
  @MainActor
  func readOnlyValueInitializerAcceptsOptionalArguments() {
    let numberFormatter = NumberFormatter()
    numberFormatter.locale = Locale(identifier: "en_US")
    numberFormatter.maximumFractionDigits = 2

    let view = AnimateNumberText(font: .title,
                                 weight: .bold,
                                 value: 10.23,
                                 textColor: .green,
                                 numberFormatter: numberFormatter,
                                 stringFormatter: "%@ ms",
                                 animation: .smooth(duration: 0.5))

    #expect(String(describing: type(of: view)) == "AnimateNumberText")
  }

  @Test
  func resizeForAnimationUsesStablePlaceholders() {
    var columns = [
      TextColumn(value: .number(0)),
      TextColumn(value: .string(" ")),
      TextColumn(value: .string("m")),
      TextColumn(value: .string("s"))
    ]
    let suffixIDs = columns.suffix(3).map(\.id)

    columns.resizeForAnimation(to: "306.26 ms")

    #expect(columns.map(\.value) == [
      .number(0),
      .number(0),
      .number(0),
      .string("."),
      .number(0),
      .number(0),
      .string(" "),
      .string("m"),
      .string("s")
    ])
    #expect(columns.suffix(3).map(\.id) == suffixIDs)
  }

  @Test
  func resizeForAnimationKeepsFormattedSuffixAligned() {
    var columns = [
      TextColumn(value: .number(9)),
      TextColumn(value: .string(" ")),
      TextColumn(value: .string("m")),
      TextColumn(value: .string("s"))
    ]
    let suffixIDs = columns.suffix(3).map(\.id)

    columns.resizeForAnimation(to: "10 ms")

    #expect(columns.map(\.value) == [
      .number(0),
      .number(9),
      .string(" "),
      .string("m"),
      .string("s")
    ])
    #expect(columns.suffix(3).map(\.id) == suffixIDs)
  }

  @Test
  func resizeForAnimationKeepsFormattedSuffixAlignedWhenShrinking() {
    var columns = [
      TextColumn(value: .number(3)),
      TextColumn(value: .number(0)),
      TextColumn(value: .number(6)),
      TextColumn(value: .string(".")),
      TextColumn(value: .number(2)),
      TextColumn(value: .number(6)),
      TextColumn(value: .string(" ")),
      TextColumn(value: .string("m")),
      TextColumn(value: .string("s"))
    ]
    let suffixIDs = columns.suffix(3).map(\.id)

    columns.resizeForAnimation(to: "0 ms")

    #expect(columns.map(\.value) == [
      .number(6),
      .string(" "),
      .string("m"),
      .string("s")
    ])
    #expect(columns.suffix(3).map(\.id) == suffixIDs)
  }

  @Test
  func textTypeOnlyTreatsASCIIDigitsAsAnimatedNumbers() {
    #expect(TextType("3") == .number(3))
    #expect(TextType("٣") == .string("٣"))
    #expect(TextType("Ⅻ") == .string("Ⅻ"))
    #expect(TextColumn(placeholderFor: "٣").value == .string("٣"))
  }

  @Test
  func digitAnimationOnlyAppliesToDigitColumns() {
    let columns = [
      TextColumn(value: .number(0)),
      TextColumn(value: .string("."))
    ]

    #expect(columns.canAnimateDigitChange(to: "3", index: 0))
    #expect(!columns.canAnimateDigitChange(to: ".", index: 0))
    #expect(!columns.canAnimateDigitChange(to: "6", index: 1))
  }

  @Test
  func unchangedFormattedSuffixDoesNotNeedUpdate() {
    let columns = [
      TextColumn(value: .number(0)),
      TextColumn(value: .string(" ")),
      TextColumn(value: .string("m")),
      TextColumn(value: .string("s"))
    ]

    #expect(columns.needsUpdate(to: "1", index: 0))
    #expect(!columns.needsUpdate(to: " ", index: 1))
    #expect(!columns.needsUpdate(to: "m", index: 2))
    #expect(!columns.needsUpdate(to: "s", index: 3))
  }

  @Test
  func smoothAnimationConfiguration() {
    #expect(AnimateNumberTextAnimation.smooth() == .smooth(duration: 0.5))
    #expect(AnimateNumberTextAnimation.smooth(duration: 0.3) != .smooth(duration: 0.5))
  }
}
