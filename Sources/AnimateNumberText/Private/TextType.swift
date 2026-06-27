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
    if let number = value.asciiDigitValue {
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
    if value.asciiDigitValue != nil {
      self.init(value: .number(0))
    } else {
      self.init(value: TextType(value))
    }
  }
}

extension Array where Element == TextColumn {
  mutating func resizeForAnimation(to string: String) {
    let targetCharacters = Swift.Array<Character>(string)
    // Equal-length updates keep their columns; settingAnimationRange handles value changes.
    guard targetCharacters.count != count else { return }

    let currentColumns = self
    var preservedDigitColumns = currentColumns.filter(\.value.isNumber)
    var targetColumns = targetCharacters.map { TextColumn(placeholderFor: $0) }

    for targetIndex in targetCharacters.indices.reversed() {
      guard targetColumns[targetIndex].value.isNumber else { continue }
      guard let preservedColumn = preservedDigitColumns.popLast() else { break }

      targetColumns[targetIndex] = preservedColumn
    }

    for (index, character) in targetCharacters.enumerated() {
      let targetValue = TextType(character)
      guard !targetValue.isNumber else { continue }

      if currentColumns.indices.contains(index),
         currentColumns[index].value == targetValue {
        targetColumns[index] = currentColumns[index]
      } else {
        targetColumns[index] = TextColumn(value: targetValue)
      }
    }

    self = targetColumns
  }

  func canAnimateDigitChange(to value: Character, index: Int) -> Bool {
    guard indices.contains(index) else { return false }

    return self[index].value.isNumber && TextType(value).isNumber
  }

  func needsUpdate(to value: Character, index: Int) -> Bool {
    guard indices.contains(index) else { return false }

    return self[index].value != TextType(value)
  }

  mutating func set(_ value: Character, index: Int) {
    set(TextType(value), index: index)
  }

  mutating func set(_ value: TextType, index: Int) {
    guard self.indices.contains(index) else { return }

    self[index].value = value
  }
}

private extension Character {
  var asciiDigitValue: Int? {
    guard unicodeScalars.count == 1,
          let scalar = unicodeScalars.first,
          scalar.value >= 48,
          scalar.value <= 57 else {
      return nil
    }

    return Int(scalar.value - 48)
  }
}
