# AnimateNumberText

SwiftUI-Version

![Badge](https://img.shields.io/badge/swift-white.svg?style=flat-square&logo=Swift)
![Badge](https://img.shields.io/badge/SwiftUI-001b87.svg?style=flat-square&logo=Swift&logoColor=black)
![Badge - Version](https://img.shields.io/badge/Version-0.5.0-1177AA?style=flat-square)
![Badge - Swift Package Manager](https://img.shields.io/badge/SPM-compatible-orange?style=flat-square)
![Badge - Platform](https://img.shields.io/badge/platform-mac_12|ios_15|watchos_8|tvos_15-yellow?style=flat-square)
![Badge - License](https://img.shields.io/badge/license-MIT-black?style=flat-square)  

--- 
## Support Double
![Image](/Assets/double.mov.gif)  

## Support Int
![Image](/Assets/int.mov.gif)

## Support Minus
![Image](/Assets/minus.mov.gif)

## Support NumberFormatter
![Image](/Assets/numberformatter.mov.gif)

## Support StringFormat
![Image](/Assets/stringformatter.mov.gif)

## Example
```swift
struct ContentView: View {
  @State var value: Double = 58.090
  @State var textColor: Color = .green
    
  var body: some View {
    Section("Double") {
      AnimateNumberText(font: .system(size: 55),
                        weight: .black,
                        value: $value,
                        textColor: $textColor)
      }
    }
    Button("Change Value") {
      value += 1
      textColor = Color.random
    }
  }
}

extension Color {
  static var random: Color {
    return Color(
      red: .random(in: 0...1),
      green: .random(in: 0...1),
      blue: .random(in: 0...1)
    )
  }
}
```

## NumberFormatter Example

```swift
struct ContentView: View {
  @State var value: Double = 0
  
  var numberFormatter: NumberFormatter {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = .current
    numberFormatter.maximumFractionDigits = 1
    return numberFormatter
  }
  
  var body: some View {
    Section("NumberFormatter") {
      AnimateNumberText(value: $value,
                        textColor: $textColor,
                        numberFormatter: numberFormatter)
      }
    }
  }
}
```

## StringFormat Example

```swift
struct ContentView: View {
  @State var value: Double = 0
  
  var body: some View {
    Section("StringFormatter") {
      AnimateNumberText(value: $value,
                        textColor: $textColor,
                        stringFormatter: "%@ ms")
      }
    }
  }
}
```

## Installation
### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. 

Once you have your Swift package set up, adding Alamofire as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/swift-man/AnimateNumberText.git", from: "0.5.0")
]
```
