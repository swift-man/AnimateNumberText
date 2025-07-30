//
//  TextType.swift
//  
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation

enum TextType {
  case string(String)
  case number(Int)
}

extension Array where Element == TextType {
  mutating func set(_ value: Character, index: Int) {
    guard self.indices.contains(index) else { return }
    if let number = Int(String(value)) {
      self[index] = .number(number)
    } else {
      self[index] = .string(String(value))
    }
  }
}
