# ``AnimateNumberText``

Animate numeric text changes with rolling digits in SwiftUI.

## Overview

Use `AnimateNumberText` when a `Double` value should update visually instead of changing as a static string. The view splits the formatted value into characters, animates numeric digits vertically, and renders non-numeric characters such as currency symbols, commas, decimal points, spaces, and suffixes as text.

The package supports `NumberFormatter` for localized number formatting and an optional string format for appending units such as `"ms"` or `"원"`.

## Installation

Add AnimateNumberText to your Swift package dependencies.

```swift
dependencies: [
  .package(url: "https://github.com/swift-man/AnimateNumberText.git", from: "0.7.0")
]
```

## Basic Usage

Bind a numeric value and text color to `AnimateNumberText`.

```swift
import SwiftUI
import AnimateNumberText

struct ContentView: View {
  @State private var value = 58.09
  @State private var textColor = Color.green

  var body: some View {
    VStack {
      AnimateNumberText(
        font: .system(size: 55),
        weight: .black,
        value: $value,
        textColor: $textColor
      )

      Button("Change Value") {
        value += 1
      }
    }
  }
}
```

## Number Formatting

Without a custom formatter, `AnimateNumberText` keeps fractional digits from
`Double` values and does not add grouping separators. Pass a `NumberFormatter`
to display currency, localized separators, or explicit fraction digit rules.

```swift
import SwiftUI
import AnimateNumberText

struct PriceView: View {
  @State private var value = 5000000.0
  @State private var textColor = Color.primary

  private var numberFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 0
    return formatter
  }

  var body: some View {
    AnimateNumberText(
      value: $value,
      textColor: $textColor,
      numberFormatter: numberFormatter
    )
  }
}
```

## String Formatting

Use `stringFormatter` when the formatted number needs a suffix or wrapper.

```swift
import SwiftUI
import AnimateNumberText

struct LatencyView: View {
  @State private var value = 10.23
  @State private var textColor = Color.primary

  var body: some View {
    AnimateNumberText(
      value: $value,
      textColor: $textColor,
      stringFormatter: "%@ ms"
    )
  }
}
```

## Animation Timing

The default animation preserves the original rolling spring behavior. Pass an
``AnimateNumberTextAnimation`` value when the rolling speed or timing curve
needs to be customized. Use `.easeIn(duration:)` to speed up over time,
`.easeOut(duration:)` to slow down over time, or `.linear(duration:)` for
constant speed.

```swift
import SwiftUI
import AnimateNumberText

struct ScoreView: View {
  @State private var value = 120.0
  @State private var textColor = Color.primary

  var body: some View {
    AnimateNumberText(
      value: $value,
      textColor: $textColor,
      animation: .easeOut(duration: 0.8)
    )
  }
}
```

For values updated at high frequency, such as drag gestures or timers, throttle
or debounce the bound value at the call site when every intermediate value does
not need to be rendered.

## Compatibility

Use ``AnimateNumberTextFormatter`` for custom formatting. The previous misspelled
`AnimateNumberTextFomatter` name remains available as a deprecated compatibility
alias so existing source code continues to compile.

## Topics

### Views

- ``AnimateNumberText``

### Formatting

- ``AnimateNumberTextFormatter``

### Animation

- ``AnimateNumberTextAnimation``
