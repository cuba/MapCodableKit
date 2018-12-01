

MapCodable
============

A powerful JSON serialization framework for swift 4.0

- [Features](#features)
- [Usage](#usage)
- [Supported Types](#supported-types)
- [Installation](#installation)
- [Credits](#credits)
- [License](#license)

## Features

- [x] Can map objects to `JSON`, from `JSON` or both
- [x] Allows you create objects that are only "to" `JSON` encodable or only "from"  `JSON` 
- [x] Easy integration
- [x] Handles common object types
- [x] Easily extensible
- [x] Uses swift 4.0

## Usage

### Mapping to `JSON`

To be able to map your object to json, your object needs to implement the `MapEncodable` protocol

```swift
struct MyModel: MapEncodable {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    func fill(map: Map) {
        map.add(id, forKey: "id")
        map.add(name, forKey: "name")
    }
}
```

Then you can get any json data like this

```swift
// Initialize your object
let myModel = MyModel(id: "123", name: "Jim Halpert")

// To get a json string (i.e. `String`)
let jsonString = try myModel.jsonString(options: [.prettyPrinted], encoding: .utf8)

// To get a json data (i.e. `Data`)
let jsonData = try myModel.jsonData(options: [.prettyPrinted])


// To get a json object (i.e. `[String: Any]`)
let json = try myModel.json()
```

### Mapping from `JSON`

To be able to map your object to json, your object needs to implement the `MapDecodable` protocol

```swift
struct MyModel: MapDecodable {
    let id: String
    let name: String

    init(map: Map) throws {
        self.id     = try map.value(fromKey: "id")
        self.name   = try map.value(fromKey: "name")
    }
}
```

Then you can initialize your object like this:

```swift
let myModel = MyModel(id: "123", name: "Jim Halpert")

// Initialize from a json string (i.e. `String`)
let jsonString = ...get your `json` string from somewhere like the network
let myModel = try MyModel(jsonString: jsonString, encoding: .utf8)

// Intialize from json data (i.e. `Data`)
let jsonData = ...get your `JSON` data from somewhere like the network
let myModel = try MyModel(jsonData: hsonData, encoding: .utf8)

// Initialize from a json object (i.e. `[String: Any]`)
let json = ["id": "234", "name": "Pam Beezley"]
let jsonString = try MyModel(json: json)
```

### Mapping Both Ways

To map your object both ways, just implement both `MapDecodable` and `MapEncodable`.  As a convenience you can also use `MapCodable`

### Serializing a custom object

Sometimes you need to serialize a custom object.  For this you can use `MapEncoder` and `MapDecoder` (`MapCoder` for both).  A simple exaple of this is the built in  `URLCoder`

```swift
public class URLCoder: MapCoder {

    public init() {}

    public func toMap(value: URL) -> String? {
        return value.absoluteString
    }

    public func fromMap(value: String) throws -> URL? {
        return URL(string: value)
    }
}
```

## Supported Types

### Primitives 

MapCodable supports any `MapPrimitive` variables.  `MapPrimitive` are any json primitives such as:
- `String`
- `Double`
- `Bool`
- `Int`
- `Int8`
- `Int16`
- `Int32`
- `Int64`
- `UInt`
- `UInt8`
- `UInt16`
- `UInt32`
- `UInt64`
- `Array` of `MapPrimitive` objects
- `Dictionary` of `MapPrimitive` objects (i.e. `[Key: MapPrimitive]`)

### Enums (`RawRepresentable`)

Raw representable objects are usually enums. They are suppoted fully in this library.

### Nested `Codable` objects

`Codable` objects that are either `Encodable` or `Decodable` or both are supported.

### Nested `MapCodable` objects

Your models may contains nested `MapCodable` objects, Sets, Arrays or Dictionaries.

### Sets

Sets are supported for the following types:
- `MapPrimitive` (strings, integers, booleans, doubles etc ...)
- `RawRepresentable` (enums)
- `MapCodable` (nested objects)

### Arrays

Arrays are supported for the following types:
- `MapPrimitive` (strings, integers, booleans, doubles etc ...)
- `RawRepresentable` (enums)
- `MapCodable` (nested objects)

### Dictionaries (with `String` keys)

Arrays are supported for the following types:
- `MapPrimitive` (strings, integers, booleans, doubles etc ...)
- `RawRepresentable` (enums)
- `MapCodable` (nested objects)

## Installation

### Package Manager

Package manager is a powerful packaging tool built into xcode.  For the full documentation on how to use package manager, click [here](https://swift.org/package-manager/)

## Dependencies

`Framework` is the only dependency 😁

## Credits

`MapCodable` is owned and maintained by Jacob Sikorski.

`MapCodable` is largely inspired by [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper).

## License

`MapCodable` is released under the MIT license. [See LICENSE](https://github.com/cuba/MapCodable/blob/master/LICENSE) for details

