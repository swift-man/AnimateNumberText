//
//  AnimateNumberText.swift
//
//
//  Created by SwiftMan on 2023/02/26.
//

import SwiftUI

/// A SwiftUI view that animates digit changes for a bound numeric value.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnimateNumberText: View {
  private let formatter: AnimateNumberTextFormatter
  
  // MARK: - Text Properties
  private let font: Font
  private let weight: Font.Weight
  
  @Binding
  private var value: Double
  
  @Binding
  private var textColor: Color

  // MARK: - Animation Properties
  private let animation: AnimateNumberTextAnimation

  @State
  private var animationRange: [TextColumn] = []

  @State
  private var displayedString: String?

  /// Continuous reel positions keyed by digit column id. Used by `.reel`
  /// animations so each digit can spin through multiple 0–9 turns.
  @State
  private var reelPositions: [UUID: Double] = [:]

  /// Creates an animated number text view.
  ///
  /// - Parameters:
  ///   - font: The font used to render each character.
  ///   - weight: The font weight used to render each character.
  ///   - value: The numeric value to display and animate.
  ///   - textColor: The text color used for the rendered value.
  ///   - numberFormatter: An optional formatter for numeric presentation.
  ///   - stringFormatter: An optional string format, such as `"%@ ms"`.
  ///   - animation: The animation configuration used for digit updates.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(
    font: Font = .largeTitle,
    weight: Font.Weight = .regular,
    value: Binding<Double>,
    textColor: Binding<Color>,
    numberFormatter: NumberFormatter? = nil,
    stringFormatter: String? = nil,
    animation: AnimateNumberTextAnimation = .smooth()
  ) {
    self.font = font
    self.weight = weight
    self._value = value
    self._textColor = textColor
    self.animation = animation
    self.formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                                stringFormatter: stringFormatter)
  }

  /// Creates an animated number text view for a read-only numeric value.
  ///
  /// Use this initializer when the caller does not need to mutate `value` or
  /// `textColor` through bindings.
  ///
  /// - Parameters:
  ///   - font: The font used to render each character.
  ///   - weight: The font weight used to render each character.
  ///   - value: The numeric value to display and animate.
  ///   - textColor: The text color used for the rendered value.
  ///   - numberFormatter: An optional formatter for numeric presentation.
  ///   - stringFormatter: An optional string format, such as `"%@ ms"`.
  ///   - animation: The animation configuration used for digit updates.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(
    font: Font = .largeTitle,
    weight: Font.Weight = .regular,
    value: Double,
    textColor: Color = .primary,
    numberFormatter: NumberFormatter? = nil,
    stringFormatter: String? = nil,
    animation: AnimateNumberTextAnimation = .smooth()
  ) {
    self.init(font: font,
              weight: weight,
              value: .constant(value),
              textColor: .constant(textColor),
              numberFormatter: numberFormatter,
              stringFormatter: stringFormatter,
              animation: animation)
  }

  public var body: some View {
    let stringValue = formatter.string(from: value)
    let columns = renderedColumns

    HStack(spacing: 0) {
      ForEach(columns) { renderedColumn in
        switch renderedColumn.column.value {
        case .string(let string):
          Text(string)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(textColor)
        case .number:
          digitColumn(for: renderedColumn.column,
                      digitOrdinal: renderedColumn.digitOrdinal,
                      digitCount: renderedColumn.digitCount)
        }
      }
    }
    .onAppear {
      initializeAnimationRangeIfNeeded(for: stringValue)
    }
    .task(id: stringValue) {
      scheduleAnimationUpdateIfNeeded(for: stringValue)
    }
  }

  @MainActor
  private func scheduleAnimationUpdateIfNeeded(for stringValue: String) {
    if initializeAnimationRangeIfNeeded(for: stringValue) {
      return
    }
    guard displayedString != stringValue || animationRange.count != stringValue.count else { return }

    resizeAnimationRange(to: stringValue)

    guard animationRange.count == stringValue.count else { return }

    settingAnimationRange(stringValue, isAnimate: true)
    displayedString = stringValue
  }

  @MainActor
  @discardableResult
  private func initializeAnimationRangeIfNeeded(for stringValue: String) -> Bool {
    guard displayedString == nil else { return false }

    animationRange = stringValue.map { TextColumn(value: TextType($0)) }
    synchronizeReelPositions()
    displayedString = stringValue
    return true
  }

  @MainActor
  private func resizeAnimationRange(to stringValue: String) {
    withoutAnimation {
      animationRange.resizeForAnimation(to: stringValue)
      synchronizeReelPositions()
    }
  }

  private var renderedColumns: [RenderedTextColumn] {
    var digitOrdinal = 0
    let digitCount = animationRange.digitCount

    return animationRange.map { column in
      let ordinal = column.value.isNumber ? digitOrdinal : nil

      if column.value.isNumber {
        digitOrdinal += 1
      }

      return RenderedTextColumn(column: column,
                                digitOrdinal: ordinal,
                                digitCount: digitCount)
    }
  }

  @ViewBuilder
  private func digitColumn(for column: TextColumn, digitOrdinal: Int?, digitCount: Int) -> some View {
    if animation.isReel {
      let number = column.value.digitValue ?? 0
      let position = reelPositions[column.id] ?? Double(number)
      let ordinal = digitOrdinal ?? 0

      ReelDigitColumn(position: position,
                      font: font,
                      weight: weight,
                      textColor: textColor)
        .animation(animation.digitAnimation(at: ordinal,
                                            digitCount: digitCount), value: position)
    } else {
      smoothDigitColumn(for: column.value)
    }
  }

  private func smoothDigitColumn(for textType: TextType) -> some View {
    // Measure every digit so proportional fonts use the widest glyph without horizontal bleed.
    ZStack {
      ForEach(0...9, id: \.self) { number in
        digitText(number)
          .hidden()
      }
    }
    .overlay {
      GeometryReader { proxy in
        let size = proxy.size

        VStack(spacing: 0) {
          ForEach(0...9, id: \.self) { number in
            digitText(number)
              .frame(width: size.width,
                     height: size.height,
                     alignment: .center)
          }
        }
        .offset(y: settingOffset(for: textType, height: size.height))
      }
      .clipped()
    }
  }

  private func digitText(_ number: Int) -> some View {
    Text("\(number)")
      .font(font)
      .fontWeight(weight)
      .foregroundColor(textColor)
  }

  @MainActor
  private func settingAnimationRange(_ string: String, isAnimate: Bool) {
    let characters = Swift.Array<Character>(string)
    let immediateUpdates = characters.enumerated().filter { index, value in
      animationRange.needsUpdate(to: value, index: index)
        && (!isAnimate || !animationRange.canAnimateDigitChange(to: value, index: index))
    }

    if !immediateUpdates.isEmpty {
      withoutAnimation {
        for (index, value) in immediateUpdates {
          animationRange.set(value, index: index)
        }
      }
    }

    guard isAnimate else { return }

    if animation.isReel {
      settingReelAnimationRange(characters)
    } else {
      settingSmoothAnimationRange(characters)
    }
  }

  @MainActor
  private func settingSmoothAnimationRange(_ characters: [Character]) {
    let digitCount = animationRange.digitCount

    for (index, value) in characters.enumerated()
      where animationRange.needsUpdate(to: value, index: index)
        && animationRange.canAnimateDigitChange(to: value, index: index) {
      let digitOrdinal = animationRange.digitOrdinal(at: index) ?? index

      withAnimation(animation.digitAnimation(at: digitOrdinal,
                                             digitCount: digitCount)) {
        animationRange.set(value, index: index)
      }
    }

    synchronizeReelPositionsToCurrentDigits()
  }

  @MainActor
  private func settingReelAnimationRange(_ characters: [Character]) {
    synchronizeReelPositions()
    var nextPositions = reelPositions

    for (index, value) in characters.enumerated()
      where animationRange.canAnimateDigitChange(to: value, index: index) {
      guard let digit = TextType(value).digitValue,
            let digitOrdinal = animationRange.digitOrdinal(at: index) else {
        continue
      }

      let columnID = animationRange[index].id
      let currentPosition = reelPositions[columnID]
        ?? Double(animationRange[index].value.digitValue ?? digit)
      let targetPosition = animation.reelTargetPosition(from: currentPosition,
                                                        to: digit,
                                                        ordinal: digitOrdinal)

      nextPositions[columnID] = targetPosition
      animationRange.set(value, index: index)
    }

    reelPositions = nextPositions
  }

  @MainActor
  private func synchronizeReelPositions() {
    guard animation.isReel else { return }

    let nextPositions = animationRange.preservingReelPositions(reelPositions)
    guard reelPositions != nextPositions else { return }

    reelPositions = nextPositions
  }

  @MainActor
  private func synchronizeReelPositionsToCurrentDigits() {
    let nextPositions = animationRange.currentDigitPositions()
    guard reelPositions != nextPositions else { return }

    reelPositions = nextPositions
  }

  private func withoutAnimation(_ updates: () -> Void) {
    var transaction = Transaction(animation: nil)
    transaction.disablesAnimations = true

    withTransaction(transaction) {
      updates()
    }
  }
  
  private func settingOffset(for textType: TextType, height: CGFloat) -> CGFloat {
    switch textType {
    case .string:
      return 0
      
    case .number(let number):
      return -CGFloat(number) * height
    }
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct RenderedTextColumn: Identifiable {
  let column: TextColumn
  let digitOrdinal: Int?
  let digitCount: Int

  var id: UUID {
    column.id
  }
}

@MainActor
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct ReelDigitColumn: View, @preconcurrency Animatable {
  var position: Double

  let font: Font
  let weight: Font.Weight
  let textColor: Color

  var animatableData: Double {
    get { position }
    set { position = newValue }
  }

  var body: some View {
    ZStack {
      ForEach(0...9, id: \.self) { number in
        digitText(number)
          .hidden()
      }
    }
    .overlay {
      GeometryReader { proxy in
        let size = proxy.size
        let basePosition = floor(position)
        let baseDigit = Int(basePosition)
        let fraction = position - basePosition

        VStack(spacing: 0) {
          ForEach(-1...1, id: \.self) { offset in
            digitText(wrappedDigit(baseDigit + offset))
              .frame(width: size.width,
                     height: size.height,
                     alignment: .center)
          }
        }
        .offset(y: -(CGFloat(fraction) + 1) * size.height)
      }
      .clipped()
    }
  }

  private func digitText(_ number: Int) -> some View {
    Text("\(number)")
      .font(font)
      .fontWeight(weight)
      .foregroundColor(textColor)
  }

  private func wrappedDigit(_ value: Int) -> Int {
    let remainder = value % 10
    return remainder >= 0 ? remainder : remainder + 10
  }
}
