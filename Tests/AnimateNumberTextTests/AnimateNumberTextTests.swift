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
  func defaultAnimationConfiguration() {
    let animation = AnimateNumberTextAnimation.default

    #expect(animation.digitTiming == .defaultSpring)
    #expect(animation.resizeDuration == 0.05)
    #expect(animation.resizeDelay == 0.05)
  }

  @Test
  func durationBasedAnimationConfigurations() {
    #expect(AnimateNumberTextAnimation.linear(duration: 0.2).digitTiming == .linear(duration: 0.2))
    #expect(AnimateNumberTextAnimation.easeIn(duration: 0.3).digitTiming == .easeIn(duration: 0.3))
    #expect(AnimateNumberTextAnimation.easeOut(duration: 0.4).digitTiming == .easeOut(duration: 0.4))
    #expect(AnimateNumberTextAnimation.easeInOut(duration: 0.5).digitTiming == .easeInOut(duration: 0.5))

    let spring = AnimateNumberTextAnimation.interactiveSpring(response: 0.6,
                                                             dampingFraction: 0.8,
                                                             blendDuration: 0.2)
    #expect(spring.digitTiming == .interactiveSpring(response: 0.6,
                                                    dampingFraction: 0.8,
                                                    blendDuration: 0.2))
  }

  @Test
  func customAnimationConfiguration() {
    let animation = AnimateNumberTextAnimation(
      digitTiming: .interactiveSpring(response: 0.6,
                                      dampingFraction: 0.8,
                                      blendDuration: 0.2),
      resizeDuration: 0.1,
      resizeDelay: 0.1
    )

    #expect(animation.digitTiming == .interactiveSpring(response: 0.6,
                                                       dampingFraction: 0.8,
                                                       blendDuration: 0.2))
    #expect(animation.resizeDuration == 0.1)
    #expect(animation.resizeDelay == 0.1)
  }
}
