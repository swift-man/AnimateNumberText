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
      return formattedString(using: stringFormatter,
                             stringValue: stringValue,
                             numberValue: newValue)
    }

    return stringValue
  }

  private func formattedNumber(from newValue: Double) -> String? {
    lock.lock()
    defer { lock.unlock() }

    return numberFormatter.string(from: NSNumber(value: newValue))
  }

  private func formattedString(using stringFormatter: String,
                               stringValue: String,
                               numberValue: Double) -> String {
    guard let argumentKinds = Self.formatArgumentKinds(for: stringFormatter) else {
      return stringValue
    }

    let arguments = argumentKinds.map { kind -> CVarArg in
      switch kind {
      case .object:
        return stringValue
      case .floatingPoint:
        return numberValue
      case .integer:
        return Int(numberValue)
      }
    }

    return String(format: stringFormatter, arguments: arguments)
  }

  private static func formatArgumentKinds(for stringFormatter: String) -> [StringFormatArgumentKind]? {
    var kinds: [StringFormatArgumentKind] = []
    var index = stringFormatter.startIndex

    while index < stringFormatter.endIndex {
      guard stringFormatter[index] == "%" else {
        stringFormatter.formIndex(after: &index)
        continue
      }

      stringFormatter.formIndex(after: &index)
      guard index < stringFormatter.endIndex else { return nil }

      if stringFormatter[index] == "%" {
        stringFormatter.formIndex(after: &index)
        continue
      }

      var foundSpecifier = false
      while index < stringFormatter.endIndex {
        let character = stringFormatter[index]
        if character == "*" {
          return nil
        }

        if let kind = StringFormatArgumentKind(character) {
          kinds.append(kind)
          stringFormatter.formIndex(after: &index)
          foundSpecifier = true
          break
        }

        guard Self.isFormatModifier(character) else { return nil }
        stringFormatter.formIndex(after: &index)
      }

      guard foundSpecifier else { return nil }
    }

    return kinds
  }

  private static func isFormatModifier(_ character: Character) -> Bool {
    "#0- +'.0123456789hljztLq$".contains(character)
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

private enum StringFormatArgumentKind {
  case object
  case floatingPoint
  case integer

  init?(_ character: Character) {
    switch character {
    case "@":
      self = .object
    case "a", "A", "e", "E", "f", "F", "g", "G":
      self = .floatingPoint
    case "d", "i", "o", "O", "u", "x", "X":
      self = .integer
    default:
      return nil
    }
  }
}
