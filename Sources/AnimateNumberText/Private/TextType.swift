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

  var digitValue: Int? {
    switch self {
    case .number(let number):
      return number
    case .string:
      return nil
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
    var preservedTextColumns = currentColumns.filter { !$0.value.isNumber }
    var targetColumns = targetCharacters.map { TextColumn(placeholderFor: $0) }

    for targetIndex in targetCharacters.indices.reversed() {
      guard targetColumns[targetIndex].value.isNumber else { continue }
      guard let preservedColumn = preservedDigitColumns.popLast() else { break }

      targetColumns[targetIndex] = preservedColumn
    }

    for targetIndex in targetCharacters.indices.reversed() {
      let targetValue = TextType(targetCharacters[targetIndex])
      guard !targetValue.isNumber else { continue }

      // Reverse iteration + lastIndex keeps trailing duplicate separators aligned first.
      if let currentIndex = preservedTextColumns.lastIndex(where: { $0.value == targetValue }) {
        targetColumns[targetIndex] = preservedTextColumns.remove(at: currentIndex)
      } else {
        targetColumns[targetIndex] = TextColumn(value: targetValue)
      }
    }

    self = targetColumns
  }

  var digitCount: Int {
    filter(\.value.isNumber).count
  }

  func digitOrdinalsByIndex() -> [Int: Int] {
    var ordinalsByIndex: [Int: Int] = [:]
    ordinalsByIndex.reserveCapacity(digitCount)
    var digitOrdinal = 0

    for index in indices where self[index].value.isNumber {
      ordinalsByIndex[index] = digitOrdinal
      digitOrdinal += 1
    }

    return ordinalsByIndex
  }

  func preservingReelPositions(_ positions: [UUID: Double]) -> [UUID: Double] {
    var nextPositions: [UUID: Double] = [:]

    for column in self {
      guard let digit = column.value.digitValue else { continue }
      nextPositions[column.id] = positions[column.id] ?? Double(digit)
    }

    return nextPositions
  }

  func currentDigitPositions() -> [UUID: Double] {
    var nextPositions: [UUID: Double] = [:]

    for column in self {
      guard let digit = column.value.digitValue else { continue }
      nextPositions[column.id] = Double(digit)
    }

    return nextPositions
  }

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  func reelPositions(updatingTo characters: [Character],
                     animation: AnimateNumberTextAnimation,
                     currentPositions: [UUID: Double]) -> [UUID: Double] {
    let digitOrdinals = digitOrdinalsByIndex()
    var nextPositions = preservingReelPositions(currentPositions)

    for (index, character) in characters.enumerated() {
      let targetValue = TextType(character)
      guard canAnimateDigitChange(to: targetValue, index: index),
            let digit = targetValue.digitValue,
            let digitOrdinal = digitOrdinals[index] else {
        continue
      }

      let column = self[index]
      let currentPosition = nextPositions[column.id]
        ?? Double(column.value.digitValue ?? digit)
      nextPositions[column.id] = animation.reelTargetPosition(from: currentPosition,
                                                              to: digit,
                                                              ordinal: digitOrdinal)
    }

    return nextPositions
  }

  func canAnimateDigitChange(to value: Character, index: Int) -> Bool {
    canAnimateDigitChange(to: TextType(value), index: index)
  }

  func canAnimateDigitChange(to value: TextType, index: Int) -> Bool {
    guard indices.contains(index) else { return false }

    return self[index].value.isNumber && value.isNumber
  }

  func needsUpdate(to value: Character, index: Int) -> Bool {
    needsUpdate(to: TextType(value), index: index)
  }

  func needsUpdate(to value: TextType, index: Int) -> Bool {
    guard indices.contains(index) else { return false }

    return self[index].value != value
  }

  func digitOrdinal(at index: Int) -> Int? {
    guard indices.contains(index), self[index].value.isNumber else { return nil }

    return self[..<index].filter(\.value.isNumber).count
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
