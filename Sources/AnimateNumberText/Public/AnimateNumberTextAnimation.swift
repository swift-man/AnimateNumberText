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
  private let duration: TimeInterval

  /// Creates a smooth digit animation that accelerates then decelerates.
  ///
  /// The animation uses a critically damped spring so interrupted rolls keep
  /// their in-flight velocity instead of restarting from a standstill.
  public static func smooth(duration: TimeInterval = 0.5) -> AnimateNumberTextAnimation {
    AnimateNumberTextAnimation(duration: duration)
  }

  private init(duration: TimeInterval = 0.5) {
    self.duration = duration
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnimateNumberTextAnimation {
  func digitAnimation(at index: Int) -> Animation {
    .interactiveSpring(response: sanitized(duration),
                       dampingFraction: 1,
                       blendDuration: 0)
  }

  private func sanitized(_ value: TimeInterval) -> TimeInterval {
    guard value.isFinite else { return 0 }
    return Swift.max(0, value)
  }
}
