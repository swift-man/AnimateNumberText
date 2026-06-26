//
//  TextType.swift
//  
//
//  Created by SwiftMan on 2023/02/26.
//

import Foundation

enum TextType: Equatable {
  case string(String)
  case number(Int)

  init(_ value: Character) {
    if let number = value.wholeNumberValue {
      self = .number(number)
    } else {
      self = .string(String(value))
    }
  }
}

struct TextColumn: Identifiable, Equatable {
  let id: UUID
  var value: TextType

  init(value: TextType = .string("")) {
    self.id = UUID()
    self.value = value
  }
}

extension Array where Element == TextColumn {
  mutating func set(_ value: Character, index: Int) {
    guard self.indices.contains(index) else { return }

    self[index].value = TextType(value)
  }
}
