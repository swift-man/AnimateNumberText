# ``AnimateNumberText``

Animate numeric text changes with rolling digits in SwiftUI.

## Overview

Use `AnimateNumberText` when a `Double` value should update visually instead of changing as a static string. The view splits the formatted value into characters, animates numeric digits vertically, and renders non-numeric characters such as currency symbols, commas, decimal points, spaces, and suffixes as text.

The package supports `NumberFormatter` for localized number formatting and an optional string format for appending units such as `"ms"` or `"원"`.

## Installation

Add AnimateNumberText to your Swift package dependencies.

```swift
dependencies: [
  .package(url: "https://github.com/swift-man/AnimateNumberText.git", from: "0.6.0")
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

Pass a `NumberFormatter` to display currency, decimal separators, or other Foundation formatting styles.

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

## Topics

### Views

- ``AnimateNumberText``

### Formatting

- ``AnimateNumberTextFomatter``
