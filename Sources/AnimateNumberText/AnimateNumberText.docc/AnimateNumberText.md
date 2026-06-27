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

## Read-only Values

Use a plain `Double` when the view only needs to display a value and the caller
does not need binding-based updates. The default animation is used when
`animation` is omitted.

```swift
import SwiftUI
import AnimateNumberText

struct SnapshotScoreView: View {
  let value = 10.23

  var body: some View {
    AnimateNumberText(value: value)
  }
}
```

## String Formatting

Use `stringFormatter` when the formatted number needs a suffix or wrapper.
Prefer a `%@` placeholder such as `"%@ ms"` when wrapping the already formatted
display string. Numeric placeholders such as `"%.2f"` and `"%d"` are applied to
the original `Double` value for compatibility, but ``AnimateNumberTextFormatter``
with a custom `NumberFormatter` remains the recommended path for currency,
locale, and fraction digit rules.

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

The default animation uses `.smooth(duration:)`, a critically damped spring that
accelerates then decelerates while preserving in-flight velocity. Pass an
``AnimateNumberTextAnimation`` value when the smooth rolling duration needs to
be customized or when a rolling digit animation is preferred.

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
      animation: .smooth(duration: 0.5)
    )
  }
}
```

Use `.roll(_:revolutions:settleInterval:)` to make each digit spin through 0...9
before settling. Digit columns start together, alternate direction from left to
right, and stop sequentially by adding the settle interval per digit.

```swift
AnimateNumberText(
  value: $value,
  textColor: $textColor,
  stringFormatter: "%@ ms",
  animation: .roll(0.9,
                   revolutions: 1,
                   settleInterval: 0.25)
)
```

For values updated at high frequency, such as drag gestures or timers, throttle
or debounce the bound value at the call site when every intermediate value does
not need to be rendered.

## Topics

### Views

- ``AnimateNumberText``

### Formatting

- ``AnimateNumberTextFormatter``

### Animation

- ``AnimateNumberTextAnimation``
