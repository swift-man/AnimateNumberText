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

  var isNumber: Bool {
    switch self {
    case .number:
      return true
    case .string:
      return false
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

  init(placeholderFor value: Character) {
    if value.wholeNumberValue != nil {
      self.init(value: .number(0))
    } else {
      self.init(value: TextType(value))
    }
  }
}

extension Array where Element == TextColumn {
  mutating func resizeForAnimation(to string: String) {
    let extra = string.count - count
    guard extra != 0 else { return }

    if extra > 0 {
      append(contentsOf: string.suffix(extra).map {
        TextColumn(placeholderFor: $0)
      })
    } else {
      removeLast(-extra)
    }
  }

  func canAnimateDigitChange(to value: Character, index: Int) -> Bool {
    guard indices.contains(index) else { return false }

    return self[index].value.isNumber && TextType(value).isNumber
  }

  mutating func set(_ value: Character, index: Int) {
    set(TextType(value), index: index)
  }

  mutating func set(_ value: TextType, index: Int) {
    guard self.indices.contains(index) else { return }

    self[index].value = value
  }
}
