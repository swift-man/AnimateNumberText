//
//  AnimateNumberTextAnimation.swift
//
//
//  Created by SwiftMan on 2026/06/26.
//

import Foundation
import SwiftUI

/// Animation configuration for ``AnimateNumberText`` digit updates.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnimateNumberTextAnimation: Equatable, Sendable {
  enum Style: Equatable, Sendable {
    case smooth(duration: TimeInterval)
    case reel(duration: TimeInterval, revolutions: Int, settleInterval: TimeInterval)
  }

  let style: Style

  /// Creates a smooth digit animation that accelerates then decelerates.
  ///
  /// The animation uses a critically damped spring so interrupted rolls keep
  /// their in-flight velocity instead of restarting from a standstill.
  public static func smooth(duration: TimeInterval = 0.5) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(style: .smooth(duration: duration))
  }

  /// Creates a slot-machine reel animation.
  ///
  /// Every digit spins through 0–9, neighbouring places spin in opposite
  /// directions, and the places come to rest one after another from left to
  /// right, each decelerating to a stop.
  ///
  /// - Parameters:
  ///   - duration: The total time until the last digit settles.
  ///   - revolutions: The number of full 0–9 turns each digit makes before
  ///     landing on its value.
  ///   - settleInterval: The time between each digit settling. With
  ///     `duration: 2.5` and `settleInterval: 0.25`, a value like `301.9`
  ///     settles as `3`, then `0`, then `1`, then `9`, ending at 2.5 seconds.
  public static func reel(duration: TimeInterval = 0.9,
                          revolutions: Int = 1,
                          settleInterval: TimeInterval = 0.25) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(style: .reel(duration: duration,
                                            revolutions: Swift.max(0, revolutions),
                                            settleInterval: settleInterval))
  }

  private init(style: Style) {
    self.style = style
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnimateNumberTextAnimation {
  /// Whether digits should render as spinning reels.
  var isReel: Bool {
    if case .reel = style { return true }
    return false
  }

  /// The number of full 0–9 turns each reel makes before landing.
  var reelRevolutions: Int {
    if case .reel(_, let revolutions, _) = style { return revolutions }
    return 0
  }

  /// Returns the continuous reel position that lands on `digit`.
  ///
  /// Even ordinals move upward through increasing digits, while odd ordinals
  /// move downward through decreasing digits. The value includes the configured
  /// full revolutions so unchanged digits still spin before settling.
  func reelTargetPosition(from currentPosition: Double, to digit: Int, ordinal: Int) -> Double {
    guard isReel else { return Double(digit) }
    guard currentPosition.isFinite else { return Double(digit) }

    let currentDigit = positiveRemainder(currentPosition, dividedBy: 10)
    let targetDigit = Double(Swift.max(0, Swift.min(9, digit)))
    let distance = reelDistance(from: currentDigit, to: targetDigit, ordinal: ordinal)
    let revolutions = Double(reelRevolutions) * 10

    if ordinal.isMultiple(of: 2) {
      return currentPosition + distance + revolutions
    } else {
      return currentPosition - distance - revolutions
    }
  }

  /// The animation applied when the digit at `ordinal` rolls to its value.
  ///
  /// `ordinal` is the zero-based position among digit columns. In reel mode it
  /// adds the settle interval so places come to rest one after another.
  func digitAnimation(at ordinal: Int, digitCount: Int = 1) -> Animation {
    switch style {
    case .smooth(let duration):
      return .interactiveSpring(response: sanitized(duration),
                                dampingFraction: 1,
                                blendDuration: 0)

    case .reel(let duration, _, let settleInterval):
      return .easeOut(duration: digitDuration(duration,
                                              settleInterval: settleInterval,
                                              ordinal: ordinal,
                                              digitCount: digitCount))
    }
  }

  func digitDuration(at ordinal: Int, digitCount: Int = 1) -> TimeInterval {
    switch style {
    case .smooth(let duration):
      return sanitized(duration)
    case .reel(let duration, _, let settleInterval):
      return digitDuration(duration,
                           settleInterval: settleInterval,
                           ordinal: ordinal,
                           digitCount: digitCount)
    }
  }

  private func sanitized(_ value: TimeInterval) -> TimeInterval {
    guard value.isFinite else { return 0 }
    return Swift.max(0, value)
  }

  private func digitDuration(_ duration: TimeInterval,
                             settleInterval: TimeInterval,
                             ordinal: Int,
                             digitCount: Int) -> TimeInterval {
    let totalDuration = sanitized(duration)
    let interval = sanitized(settleInterval)
    let lastOrdinal = Swift.max(0, digitCount - 1)
    let clampedOrdinal = Swift.max(0, Swift.min(ordinal, lastOrdinal))
    let remainingDigits = lastOrdinal - clampedOrdinal

    return Swift.max(0, totalDuration - Double(remainingDigits) * interval)
  }

  private func reelDistance(from currentDigit: Double, to targetDigit: Double, ordinal: Int) -> Double {
    if ordinal.isMultiple(of: 2) {
      return positiveRemainder(targetDigit - currentDigit, dividedBy: 10)
    } else {
      return positiveRemainder(currentDigit - targetDigit, dividedBy: 10)
    }
  }

  private func positiveRemainder(_ value: Double, dividedBy divisor: Double) -> Double {
    let remainder = value.truncatingRemainder(dividingBy: divisor)
    return remainder >= 0 ? remainder : remainder + divisor
  }
}
