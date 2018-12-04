



MapCodableKit
============

A powerful JSON serialization framework for swift 4.2 which works on iOS and server side frameworks like Vapor 3.

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
- [x] Uses swift 4.2

## Usage

For the full documentation, click here: https://cuba.github.io/MapCodableKit/

### Import `MapCodableKit`

Add the following to the top of any swift file using `MapCodableKit`
```swift
import MapCodableKit 
```

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

### Generics

You can also use generics if you chose.  Here is an example of a generic used for serializing a response:

```swift
struct ListBody<T: MapEncodable>: MapEncodable {
    let key: String
    let objects: [T]

    init(key: String, objects: [T]) {
        self.key = key
        self.objects = objects
    }

    func fill(map: Map) throws {
        try map.add(objects, forKey: key)
    }
}
```

### Nested objects

You can get or set an object nested in a dictionary or an array.  

For a nested object in a dictionary, just seperate your keys using a `.`. For example the key `abc.def` will return an object with the key `def` in a parent object.  

You may also get the first object in an array. For example, the key `def[0]` will return the first object in an array `def`.

You may chain as many of these as you would like.  For example, `abc.def[0]` will return the first object in an array `def` which is itself nested in the object `abc`.

**Note**: only the first object `0` is supported for now.  using any value other than `0` will give you a `MappingError` when trying to save to write the value.  

## Supported Types

### Primitives 

MapCodableKit supports any `MapPrimitive` variables.  `MapPrimitive` are any json primitives such as:
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

**Note**: if you request a `String` for any value that does not parse to a string it will fail serialization. This includes nested objects and arrays since they entire `JSON` structure is already parsed.

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
- `MapEncodable` (read only nested objects)
- `MapDecodable` (write only nested objects)
- `MapCodable` (read and write nested objects)

### Arrays

Arrays are supported for the following types:
- `MapPrimitive` (strings, integers, booleans, doubles etc ...)
- `RawRepresentable` (enums)
- `MapEncodable` (read only nested objects)
- `MapDecodable` (write only nested objects)
- `MapCodable` (read and write nested objects)

### Dictionaries (with `String` keys)

Arrays are supported for the following types:
- `MapPrimitive` (strings, integers, booleans, doubles etc ...)
- `RawRepresentable` (enums)
- `MapEncodable` (read only nested objects)
- `MapDecodable` (write only nested objects)
- `MapCodable` (read and write nested objects)

## Installation

### Package Manager

Package manager is a powerful packaging tool built into xcode.  For the full documentation on how to use package manager, click [here](https://swift.org/package-manager/)

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `MapCodableKit` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "cuba/MapCodableKit" ~> 1.1
```

Run `carthage update` to build the framework and drag the built `MapCodableKit.framework` into your Xcode project.

## Dependencies

`Framework` is the only dependency 😁

## Credits

`MapCodableKit` is owned and maintained by Jacob Sikorski.

`MapCodableKit` is largely inspired by [ObjectMapper](https://github.com/Hearst-DD/ObjectMapper).

## License

`MapCodableKit` is released under the MIT license. [See LICENSE](https://github.com/cuba/MapCodableKit/blob/master/LICENSE) for details

