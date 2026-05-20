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
  @State
  private var animationRange: [TextType] = []

  private enum AnimationTiming {
    static let resizeDuration: TimeInterval = 0.05
    static let resizeDelayNanoseconds: UInt64 = 50_000_000
  }
  
  /// Creates an animated number text view.
  ///
  /// - Parameters:
  ///   - font: The font used to render each character.
  ///   - weight: The font weight used to render each character.
  ///   - value: The numeric value to display and animate.
  ///   - textColor: The text color used for the rendered value.
  ///   - numberFormatter: An optional formatter for numeric presentation.
  ///   - stringFormatter: An optional string format, such as `"%@ ms"`.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public init(
    font: Font = .largeTitle,
    weight: Font.Weight = .regular,
    value: Binding<Double>,
    textColor: Binding<Color>,
    numberFormatter: NumberFormatter? = nil,
    stringFormatter: String? = nil
  ) {
    self.font = font
    self.weight = weight
    self._value = value
    self._textColor = textColor
    self.formatter = AnimateNumberTextFormatter(numberFormatter: numberFormatter,
                                                stringFormatter: stringFormatter)
  }

  public var body: some View {
    HStack(spacing: 0) {
      ForEach(animationRange.indices, id: \.self) { index in
        // MARK: To Find Text Size for Given Font
        // Random Number
        switch animationRange[index] {
        case .string(let string):
          Text(string)
            .font(font)
            .fontWeight(weight)
            .foregroundColor(textColor)
        case .number:
          Text("8")
            .font(font)
            .fontWeight(weight)
            .opacity(0)
            .overlay {
              GeometryReader { proxy in
                let size = proxy.size

                VStack(spacing: 0) {
                  // MARK: - Since Its Individual Value
                  // We Need Form 0-9
                  ForEach(0...9, id: \.self) { number in
                    Text("\(number)")
                      .font(font)
                      .fontWeight(weight)
                      .frame(width: size.width,
                             height: size.height,
                             alignment: .center)
                      .foregroundColor(textColor)
                  }
                }
                // MARK: - Setting Offset
                .offset(y: settingOffset(at: index, height: size.height))
              }
              .clipped()
            }
        }
      }
    }
    .onAppear {
      // MARK: - Loading Range
      let stringValue = formatter.string(from: value)
      animationRange = Array(repeating: .string(""), count: stringValue.count)
      settingAnimationRange(stringValue, isAnimate: false)
    }
    .task(id: value) {
      await scheduleAnimationUpdate(for: value)
    }
  }

  @MainActor
  private func scheduleAnimationUpdate(for newValue: Double) async {
    let stringValue = formatter.string(from: newValue)
    resizeAnimationRange(to: stringValue.count,
                         duration: AnimationTiming.resizeDuration)

    do {
      try await Task.sleep(nanoseconds: AnimationTiming.resizeDelayNanoseconds)
    } catch {
      return
    }

    settingAnimationRange(stringValue, isAnimate: true)
  }
  
  private func resizeAnimationRange(to count: Int, duration: TimeInterval) {
    let extra = count - animationRange.count
    guard extra != 0 else { return }

    withAnimation(.easeIn(duration: duration)) {
      if extra > 0 {
        animationRange.append(contentsOf: Array(repeating: .string(""), count: extra))
      } else {
        animationRange.removeLast(-extra)
      }
    }
  }
    
  private func settingAnimationRange(_ string: String, isAnimate: Bool) {
    for (index, value) in string.enumerated() {
      // IF First Value = 1
      // Then Offset will be Applied for -1
      // So the text will move up to show 1 Value
      
      if isAnimate {
        // MARK: DampingFaction based on Index Value
        var fraction = Double(index) * 0.15
        // Max = 0.5
        // Total = 1.5
        fraction = Swift.min(fraction, 0.5)
        
        withAnimation(.interactiveSpring(response: 0.45,
                                         dampingFraction: 1 + fraction,
                                         blendDuration: 1 + fraction)) {
          animationRange.set(value, index: index)
        }
      } else {
        animationRange.set(value, index: index)
      }
    }
  }
  
  private func settingOffset(at index: Int, height: CGFloat) -> CGFloat {
    switch animationRange[index] {
    case .string:
      return 0
      
    case .number(let number):
      return -CGFloat(number) * height
    }
  }
}
