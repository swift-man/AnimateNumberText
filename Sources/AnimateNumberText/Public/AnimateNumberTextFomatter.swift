//
//  AnimateNumberTextFomatter.swift
//  
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class AnimateNumberTextFomatter {
  let numberFormatter: NumberFormatter
  let stringFormatter: String?
  
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(numberFormatter: NumberFormatter?,
              stringFormatter: String?) {
    self.numberFormatter = numberFormatter ?? NumberFormatter()
    self.stringFormatter = stringFormatter
  }
  
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public func string(from newValue: Double) -> String {
    var stringValue = "\(newValue)"
    
    if let number = Double(stringValue) {
      if let formatted = numberFormatter.string(from: number as NSNumber) {
        stringValue = formatted
      }
    }
    
    if let stringFormatter {
      return String(format: stringFormatter, stringValue)
    }
    
    return stringValue
  }
}
