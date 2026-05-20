//
//  AnimateNumberTextFomatter.swift
//  
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation

/// Formats numeric values for display in ``AnimateNumberText``.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class AnimateNumberTextFomatter {
  let numberFormatter: NumberFormatter
  let stringFormatter: String?
  
  /// Creates a formatter for animated number text.
  ///
  /// - Parameters:
  ///   - numberFormatter: The formatter used to convert numeric values into display strings.
  ///   - stringFormatter: An optional string format applied to the formatted value.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(numberFormatter: NumberFormatter?,
              stringFormatter: String?) {
    self.numberFormatter = numberFormatter ?? NumberFormatter()
    self.stringFormatter = stringFormatter
  }
  
  /// Returns the display string for a numeric value.
  ///
  /// - Parameter newValue: The numeric value to format.
  /// - Returns: A display string ready for ``AnimateNumberText``.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public func string(from newValue: Double) -> String {
    let stringValue = numberFormatter.string(from: NSNumber(value: newValue)) ?? "\(newValue)"
    
    if let stringFormatter {
      return String(format: stringFormatter, stringValue)
    }
    
    return stringValue
  }
}
