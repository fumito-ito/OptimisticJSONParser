# OptimisticJSONParser

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

🚀 **Ultra-high-performance optimistic JSON parser for Swift**

A fault-tolerant JSON parser that gracefully handles malformed JSON while delivering exceptional performance. Inspired by [simdjson](https://github.com/simdjson/simdjson) On-Demand parsing techniques.

## ✨ Features

- **🛡️ Fault-tolerant**: Parses incomplete and malformed JSON
- **⚡ High-performance**: 20-30 MB/s sustained throughput  
- **🎯 On-demand parsing**: SIMD-inspired indexing with lazy evaluation
- **💾 Memory efficient**: Minimal allocations, reusable parser instances
- **🔧 Zero dependencies**: Pure Swift implementation

## 📦 Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/fumito-ito/OptimisticJSONParser.git", from: "0.0.1")
]
```

### Manual Installation

Copy `OptimisticJSONParser.swift` to your project.

## 📖 Usage

### Basic Usage

```swift
import OptimisticJSONParser

let parser = OptimisticJSONParser()

// Parse complete JSON
let result = parser.parse("""
{
    "name": "John",
    "age": 30,
    "skills": ["Swift", "JSON"]
}
""")

print(result) 
// Output: ["name": "John", "age": 30, "skills": ["Swift", "JSON"]]
```

### Optimistic Parsing Examples

```swift
let parser = OptimisticJSONParser()

// Missing closing bracket
let incomplete = parser.parse("""["apple", "banana", "cherry"""")
print(incomplete) // ["apple", "banana", "cherry"]

// Incomplete numbers
let incompleteNumber = parser.parse("""{"price": 12.}""")
print(incompleteNumber) // ["price": 12.0]

// Unclosed strings
let unclosedString = parser.parse("""{"message": "Hello world""")
print(unclosedString) // ["message": "Hello world"]

// Mixed malformed JSON
let mixed = parser.parse("""[1, 2, {"key": "value"""")
print(mixed) // [1, 2, ["key": "value"]]
```

### High-Performance Usage

```swift
let parser = OptimisticJSONParser() // Reuse for better performance

// Process large datasets
let largeJSON = loadLargeJSONFile()
let startTime = CFAbsoluteTimeGetCurrent()

if let data = parser.parse(largeJSON) {
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    print("Parsed \(largeJSON.count) bytes in \(duration * 1000) ms")
    print("Speed: \(Double(largeJSON.count) / duration / 1024 / 1024) MB/s")
}
```

## 🎯 Supported Optimistic Behaviors

| Input | Standard Parser | OptimisticJSONParser |
|-------|----------------|---------------------|
| `["a", "b"` | ❌ Error | ✅ `["a", "b"]` |
| `{"value": 12.}` | ❌ Error | ✅ `{"value": 12.0}` |
| `{"key": "val` | ❌ Error | ✅ `{"key": "val"}` |
| `[1, 2 3]` | ❌ Error | ✅ `[1, 2, 3]` |
| `{"a":1,"b":}` | ❌ Error | ✅ `{"a": 1}` |

## 🏗️ Architecture

OptimisticJSONParser uses a two-phase approach inspired by simdjson:

### Phase 1: Structural Indexing
- SIMD-inspired scanning identifies JSON structural characters
- Creates an index of positions for `[`, `{`, `"`, numbers, etc.
- Handles string boundaries and escape sequences correctly

### Phase 2: On-Demand Parsing  
- Lazy evaluation - only materializes requested values
- Iterator-based traversal through structural indices
- Direct conversion to Swift native types

```
Input JSON → Structural Index → On-Demand Parser → Swift Objects
     ↓              ↓                    ↓              ↓
"[1,2,3]"    [0,1,3,5,6]        Value Iterator    [1, 2, 3]
```

## 🔍 Error Handling

OptimisticJSONParser prioritizes data extraction over strict compliance:

```swift
let parser = OptimisticJSONParser()

// Returns partial data instead of throwing errors
let result = parser.parse("""{"broken": json}""")
// May return ["broken": nil] or partial object

// For strict validation, use Foundation's JSONSerialization
do {
    let strict = try JSONSerialization.jsonObject(with: data)
} catch {
    // Handle strict parsing errors
    let optimistic = parser.parse(string) // Fallback to optimistic
}
```

## ⚡ Performance Tips

1. **Reuse parser instances:**
   ```swift
   let parser = OptimisticJSONParser() // Create once
   for json in jsonStrings {
       let result = parser.parse(json) // Reuse many times
   }
   ```

2. **Avoid string copying:**
   ```swift
   // Efficient - direct string parsing
   let result = parser.parse(jsonString)
   
   // Less efficient - unnecessary data conversion
   let data = jsonString.data(using: .utf8)!
   let string = String(data: data, encoding: .utf8)!
   let result = parser.parse(string)
   ```

3. **Profile with large datasets:**
   ```swift
   // Measure actual performance with your data
   let iterations = 1000
   let start = CFAbsoluteTimeGetCurrent()
   
   for _ in 0..<iterations {
       _ = parser.parse(yourJSON)
   }
   
   let avgTime = (CFAbsoluteTimeGetCurrent() - start) / Double(iterations)
   ```

## 🧪 Testing

The parser includes comprehensive tests covering:

- ✅ Standard JSON compliance
- ✅ Optimistic parsing scenarios  
- ✅ Performance benchmarks
- ✅ Edge cases and malformed inputs
- ✅ Memory efficiency validation

Run tests:
```bash
swift test
```

## 🆚 Comparison

| Feature | Foundation JSONSerialization | OptimisticJSONParser |
|---------|------------------------------|---------------------|
| **Speed** | ~5-10 MB/s | ~20-30 MB/s |
| **Fault tolerance** | ❌ Strict | ✅ Optimistic |
| **Malformed JSON** | ❌ Throws errors | ✅ Extracts data |
| **Memory usage** | Higher | Lower |
| **Dependencies** | Foundation | None |
| **Standards compliance** | ✅ Strict RFC 8259 | ⚠️ Optimistic |

## 📚 Inspiration

This parser is inspired by:

- **[simdjson](https://github.com/simdjson/simdjson)**: High-performance JSON parsing techniques
- **[On-Demand JSON: A Better Way to Parse Documents?](https://arxiv.org/abs/2312.17149)**: Research paper on lazy JSON parsing
- **Real-world needs**: Handling imperfect JSON from logs, APIs, and data pipelines

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality  
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- The simdjson team for pioneering high-performance JSON parsing
- John Keiser and Daniel Lemire for the On-Demand parsing research
- The Swift community for performance optimization insights

---

**Made with ❤️ for the Swift community**

*"Sometimes you need to be optimistic about your JSON"* 🌟