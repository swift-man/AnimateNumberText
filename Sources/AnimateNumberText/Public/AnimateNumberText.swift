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

    HStack(spacing: 0) {
      ForEach(animationRange) { column in
        switch column.value {
        case .string(let string):
          Text(string)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(textColor)
        case .number:
          digitColumn(for: column)
        }
      }
    }
    .onAppear {
      initializeAnimationRangeIfNeeded(for: stringValue)
    }
    .task(id: stringValue) {
      await scheduleAnimationUpdateIfNeeded(for: stringValue)
    }
  }

  @MainActor
  private func scheduleAnimationUpdateIfNeeded(for stringValue: String) async {
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

  @ViewBuilder
  private func digitColumn(for column: TextColumn) -> some View {
    if animation.isReel {
      let number = column.value.digitValue ?? 0
      let position = reelPositions[column.id] ?? Double(number)

      ReelDigitColumn(position: position,
                      font: font,
                      weight: weight,
                      textColor: textColor)
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
    for (index, value) in characters.enumerated()
      where animationRange.needsUpdate(to: value, index: index)
        && animationRange.canAnimateDigitChange(to: value, index: index) {
      let digitOrdinal = animationRange.digitOrdinal(at: index) ?? index

      withAnimation(animation.digitAnimation(at: digitOrdinal)) {
        animationRange.set(value, index: index)
      }
    }
  }

  @MainActor
  private func settingReelAnimationRange(_ characters: [Character]) {
    synchronizeReelPositions()

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

      withAnimation(animation.digitAnimation(at: digitOrdinal)) {
        reelPositions[columnID] = targetPosition
        animationRange.set(value, index: index)
      }
    }
  }

  @MainActor
  private func synchronizeReelPositions() {
    guard animation.isReel else { return }

    var nextPositions: [UUID: Double] = [:]

    for column in animationRange {
      guard let digit = column.value.digitValue else { continue }
      nextPositions[column.id] = reelPositions[column.id] ?? Double(digit)
    }

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
