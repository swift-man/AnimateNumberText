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
  /// The timing curve used when numeric digits roll to a new value.
  public enum DigitTiming: Equatable, Sendable {
    /// The original per-index spring timing used by AnimateNumberText.
    case defaultSpring
    /// A constant-speed animation.
    case linear(duration: TimeInterval)
    /// An animation that starts slowly and speeds up.
    case easeIn(duration: TimeInterval)
    /// An animation that starts quickly and slows down.
    case easeOut(duration: TimeInterval)
    /// An animation that eases both at the start and end.
    case easeInOut(duration: TimeInterval)
    /// A custom interactive spring animation.
    case interactiveSpring(response: TimeInterval,
                           dampingFraction: Double,
                           blendDuration: TimeInterval)
  }

  /// The default animation, preserving the original AnimateNumberText behavior.
  public static let `default` = AnimateNumberTextAnimation()

  /// Creates a constant-speed digit animation.
  public static func linear(duration: TimeInterval) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(digitTiming: .linear(duration: duration))
  }

  /// Creates a digit animation that starts slowly and speeds up.
  public static func easeIn(duration: TimeInterval) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(digitTiming: .easeIn(duration: duration))
  }

  /// Creates a digit animation that starts quickly and slows down.
  public static func easeOut(duration: TimeInterval) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(digitTiming: .easeOut(duration: duration))
  }

  /// Creates a digit animation that eases both at the start and end.
  public static func easeInOut(duration: TimeInterval) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(digitTiming: .easeInOut(duration: duration))
  }

  /// Creates a custom interactive spring digit animation.
  public static func interactiveSpring(
    response: TimeInterval = 0.45,
    dampingFraction: Double = 1,
    blendDuration: TimeInterval = 1
  ) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(digitTiming: .interactiveSpring(response: response,
                                                               dampingFraction: dampingFraction,
                                                               blendDuration: blendDuration))
  }

  /// The timing curve used when numeric digits roll to a new value.
  public let digitTiming: DigitTiming

  /// The animation duration used when the formatted string grows or shrinks.
  public let resizeDuration: TimeInterval

  /// The delay between resizing the character range and rolling digits.
  public let resizeDelay: TimeInterval

  /// Creates an animation configuration.
  ///
  /// - Parameters:
  ///   - digitTiming: The timing curve used when numeric digits roll to a new value.
  ///   - resizeDuration: The animation duration used when the formatted string grows or shrinks.
  ///   - resizeDelay: The delay between resizing the character range and rolling digits.
  public init(
    digitTiming: DigitTiming = .defaultSpring,
    resizeDuration: TimeInterval = 0.05,
    resizeDelay: TimeInterval = 0.05
  ) {
    self.digitTiming = digitTiming
    self.resizeDuration = resizeDuration
    self.resizeDelay = resizeDelay
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnimateNumberTextAnimation {
  var resizeAnimation: Animation {
    .easeIn(duration: sanitized(resizeDuration))
  }

  var resizeDelayNanoseconds: UInt64 {
    let seconds = sanitized(resizeDelay)
    guard seconds < TimeInterval(UInt64.max) / 1_000_000_000 else {
      return UInt64.max
    }
    return UInt64(seconds * 1_000_000_000)
  }

  func digitAnimation(at index: Int) -> Animation {
    switch digitTiming {
    case .defaultSpring:
      let fraction = Swift.min(Double(index) * 0.15, 0.5)
      return .interactiveSpring(response: 0.45,
                                dampingFraction: 1 + fraction,
                                blendDuration: 1 + fraction)

    case .linear(let duration):
      return .linear(duration: sanitized(duration))

    case .easeIn(let duration):
      return .easeIn(duration: sanitized(duration))

    case .easeOut(let duration):
      return .easeOut(duration: sanitized(duration))

    case .easeInOut(let duration):
      return .easeInOut(duration: sanitized(duration))

    case .interactiveSpring(let response, let dampingFraction, let blendDuration):
      return .interactiveSpring(response: sanitized(response),
                                dampingFraction: dampingFraction,
                                blendDuration: sanitized(blendDuration))
    }
  }

  private func sanitized(_ value: TimeInterval) -> TimeInterval {
    guard value.isFinite else { return 0 }
    return Swift.max(0, value)
  }
}
