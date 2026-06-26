//
//  AnimateNumberTextFormatter.swift
//  
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation

/// Formats numeric values for display in ``AnimateNumberText``.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class AnimateNumberTextFormatter {
  private let numberFormatter: NumberFormatter
  private let stringFormatter: String?
  private let lock = NSLock()
  
  /// Creates a formatter for animated number text.
  ///
  /// - Parameters:
  ///   - numberFormatter: The formatter copied and used to convert numeric values into display strings.
  ///   - stringFormatter: An optional string format applied to the formatted string value.
  ///     Use a `%@` placeholder, such as `"%@ ms"`, because the argument is already a string.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(numberFormatter: NumberFormatter?,
              stringFormatter: String?) {
    self.numberFormatter = numberFormatter?.copy() as? NumberFormatter ?? Self.makeDefaultNumberFormatter()
    self.stringFormatter = stringFormatter
  }
  
  /// Returns the display string for a numeric value.
  ///
  /// - Parameter newValue: The numeric value to format.
  /// - Returns: A display string ready for ``AnimateNumberText``.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public func string(from newValue: Double) -> String {
    let stringValue = formattedNumber(from: newValue) ?? "\(newValue)"
    
    if let stringFormatter {
      return String(format: stringFormatter, stringValue)
    }

    return stringValue
  }

  private func formattedNumber(from newValue: Double) -> String? {
    lock.lock()
    defer { lock.unlock() }

    return numberFormatter.string(from: NSNumber(value: newValue))
  }

  private static func makeDefaultNumberFormatter() -> NumberFormatter {
    let formatter = NumberFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.numberStyle = .decimal
    formatter.usesGroupingSeparator = false
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 16

    return formatter
  }
}
