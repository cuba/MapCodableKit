//
//  Map.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

/**
 A wrapper around a json object that conveniently returns parsed objects or adds complex objects into the json object.
 
 Basic example of returning objects:
 ```
 let jsonString = // Source of json string
 let map = Map(jsonString: jsonString, encoding: .utf8)
 
 let string: String = try map.value("some_key")
 ```
 
 Basic example of adding objects:
 ```
 let map = Map()
 map.add("some string", for: "some_key")
 let jsonString = map.jsonString(encoding: .utf8)
 ```
 */
public class Map {
    private var tree: [String: Any?]
    
    /**
     Initialize this map from a JSON dictionary. You should only pass `MapPrimitive` (JSON) values in this dictionary.
     */
    public init(json: [String: Any?] = [:]) {
        self.tree = json
    }
    
    /**
     Initialize this `Map` from a `MapEncodable` object using its `fill` method.
     */
    public convenience init(_ mapEncodable: MapEncodable) throws {
        self.init()
        try mapEncodable.fill(map: self)
    }
    
    /**
     Initialize this object from a JSON `String`.
     
     - parameter jsonString: The JSON `String` that will be deserialized.
     - parameter encoding: The encoding used on the string.
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public convenience init(jsonString: String, encoding: String.Encoding = .utf8) throws {
        guard let data = jsonString.data(using: encoding) else {
            self.init()
            return
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let json = jsonObject as? [String: Any] {
            self.init(json: json)
        } else {
            self.init()
        }
    }
    
    /**
     Initialize this object from a JSON `String`.
     
     - parameter jsonString: The JSON `String` that will be deserialized.
     - parameter encoding: The encoding used on the string.
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public convenience init(jsonData: Data, encoding: String.Encoding = .utf8) throws {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        
        if let json = jsonObject as? [String: Any?] {
            self.init(json: json)
        } else {
            self.init()
        }
    }
    
    /**
     Create a `Map` `Array` from a JSON `String`
     
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public static func parseArray(jsonString: String, encoding: String.Encoding = .utf8) throws -> [Map] {
        guard let data = jsonString.data(using: encoding) else {
            return []
        }
        
        return try self.parseArray(jsonData: data)
    }
    
    /**
     Create a `Map` `Array` from a JSON `Data`
     
     - parameter jsonData: The JSON `Data` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public static func parseArray(jsonData: Data) throws -> [Map] {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
        
        if let paramsArray = jsonObject as? [[String: Any?]] {
            return paramsArray.map({ Map(json: $0) })
        } else {
            return []
        }
    }
    
    /**
     Returns the JSON dictionary representation of this map.
     
     - returns: A dictionary object representing this map.
     */
    public func makeDictionary() -> [String: Any?] {
        return tree
    }
    
    /**
     Serializes this object into a JSON `Data` object.
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: makeDictionary(), options: options)
    }
    
    /**
     Serializes this object into a JSON `String`.
     
     - parameter options: The writing options.
     - parameter encoding: The string encoding that should be used.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonString(options: JSONSerialization.WritingOptions = [], encoding: String.Encoding = .utf8) throws -> String? {
        let data = try jsonData(options: options)
        return String(data: data, encoding: encoding)
    }
    
    /**
     Add a value to the map. The object added should always be a `MapPrimitive` (JSON value) otherwise parsing this object into JSON will result in a runtime exception.
     
     - parameter value: The value that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to retrive this value.
     */
    public func add(_ value: Any?, for key: MapKey) throws {
        var parts = try key.parseKeyParts()
        
        guard parts.count > 0 else {
            throw MapEncodingError.invalidKey(key: key)
        }
        
        let firstPart = parts.removeFirst()
        let existingValue = tree[firstPart.key] as? [String: Any?]
        let newValue = wrap(value, in: existingValue, with: parts)
        
        switch firstPart {
        case .object(let key):
            tree[key] = newValue
        case .array(let key):
            tree[key] = [newValue]
        }
    }
    
    /**
     Returns a value from the map. All values returned will always conform to `MapPrimitive` unless the add method was used incorrectly.
     
     - parameter key: The key that that is used to store this value in the map.
     - returns: The stored object.
     */
    public func value(from key: MapKey) throws -> Any? {
        let parts = try key.parseKeyParts()
        var currentValue: Any? = tree
        
        for part in parts {
            guard let dictionary = currentValue as? [String: Any?] else { return nil }
            guard let value = dictionary[part.key] else { return nil }
            
            switch part {
            case .object:
                currentValue = value
            case .array:
                guard let array = value as? [[String: Any?]] else { return nil }
                currentValue = array.first
            }
        }
        
        return currentValue
    }
    
    private func wrap(_ value: Any?, in existingDictionary: [String: Any?]?, with parts: [KeyPart]) -> Any? {
        var parts = parts
        
        guard !parts.isEmpty else { return value }
        let currentPart = parts.removeFirst()
        let nextDictionary = existingDictionary?[currentPart.key] as? [String: Any?]
        let newValue = wrap(value, in: nextDictionary, with: parts)
        var currentDictionary = existingDictionary ?? [:]
        
        switch currentPart {
        case .object(let key):
            currentDictionary[key] = newValue
        case .array(let key):
            currentDictionary[key] = [newValue]
        }
        
        return currentDictionary
    }
}

public extension Sequence where Iterator.Element == Map {
    
    /**
     Returns an JSON array representation of the objects contained in this set.
     
     - returns: An array of all the dictionary objects representing the maps.
     */
    func makeDictionaries() -> [[String: Any?]] {
        let array = self.map({ $0.makeDictionary() })
        return array
    }
    
    /**
     Serializes this set into a json data object.
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let array = makeDictionaries()
        return try JSONSerialization.data(withJSONObject: array, options: options)
    }
    
    /**
     Serializes this set into a jsonString.
     
     - parameter options: The writing options.
     - parameter encoding: The string encoding that should be used.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    func jsonString(options: JSONSerialization.WritingOptions = [], encoding: String.Encoding = .utf8) throws -> String? {
        let data = try jsonData(options: options)
        return String(data: data, encoding: encoding)
    }
}

// MARK: MapEncodable

extension Map {
    
    /**
     Add a value to the map encoding it using the provided `MapEncoder`.
     
     - parameter value: The value that will be stored in this map.
     - parameter key: The JSON key that will be used for the JSON object.
     - parameter encoder: The encoder that will be used to serialize the object.
     */
    public func add<T: MapEncoder>(_ value: T.Object?, for key: MapKey, using encoder: T) throws {
        guard let value = value else { return }
        guard let encoded = try encoder.toMap(value: value) else { return }
        try self.add(encoded as Any, for: key)
    }
    
    /**
     Returns a value from the map. The value will be decoded it using the provided `MapDecoder`.
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T) throws -> T.Object {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let element = value as? T.Primitive else { throw MapDecodingError.unexpectedType(key: key) }
        
        guard let object = try decoder.fromMap(value: element) else {
            throw MapDecodingError.failedToDecode(key: key)
        }
        
        return object
    }
}

// MARK: MapPrimitive

extension Map {
    
    /**
     Add a `MapPrimitive` value to the map. A `MapPrimitive` is any value supported by a JSON object. `MapPrimitive` values includes (but not limited to):
     * `String`
     * `Int`
     * `Bool`
     * `Double`
     * `[T]` where T also conforms to `MapPrimitive`
     * `[String: T]` where T also conforms to `MapPrimitive`
     
     - parameter value: The value that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapPrimitive>(_ value: T?, for key: MapKey) throws {
        guard let value = value else { return }
        try self.add(value as Any, for: key)
    }
    
    /**
     Returns a value from the map if it conforms to the specified `MapPrimitive` type.
     
     - parameter key: The JSON key for the primitive that will be returned.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(from key: MapKey) throws -> T {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let object = value as? T else { throw MapDecodingError.unexpectedType(key: key) }
        return object
    }
    
    /**
     Returns a set of values from the map if they all conform to the specified `MapPrimitive` type.
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(from key: MapKey) throws -> Set<T> {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let object = value as? [T] else { throw MapDecodingError.unexpectedType(key: key) }
        return Set(object)
    }
}

// MARK: RawRepresentable

extension Map {
    
    /**
     Add a value to the map. The object will be converted to its raw type.
     
     - parameter value: The value that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: T?, for key: MapKey) throws {
        guard let value = value else { return }
        try self.add(value.rawValue as Any, for: key)
    }
    
    /**
     Returns a value from the map. The object will be converted from its RawType into the .
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be converted to the specified type or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> T {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let rawValue = value as? T.RawValue else { throw MapDecodingError.unexpectedType(key: key) }
        guard let object = T(rawValue: rawValue) else { throw MapDecodingError.failedToDecode(key: key) }
        return object
    }
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: [T]?, for key: MapKey) throws {
        guard let value = value else { return }
        let rawValues = value.map({ $0.rawValue })
        try self.add(rawValues as Any, for: key)
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> [T] {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let rawValues = value as? [T.RawValue] else { throw MapDecodingError.unexpectedType(key: key) }
        let objects = rawValues.compactMap({ T(rawValue: $0) })
        return objects
    }
    
    /**
     Add a dictionary of the RawRepresentable types converted to JSON primatives.
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: [String: T]?, for key: MapKey) throws {
        guard let value = value else { return }
        var rawValues: [String: T.RawValue] = [:]
        value.forEach({ rawValues[$0] = $1.rawValue })
        try self.add(rawValues as Any, for: key)
    }
    
    /**
     Returns a dictionary of the specified `RawRepresentable` types.
     
     - parameter key: The JSON key for the dictionary that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> [String: T] {
        guard let values: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        guard let rawValues = values as? [String: T.RawValue] else { throw MapDecodingError.unexpectedType(key: key) }
        var result: [String: T] = [:]
        
        for (key, rawValue) in rawValues {
            guard let value = T(rawValue: rawValue) else { continue }
            result[key] = value
        }
        
        return result
    }
    
    /**
     Add a value to the map. The object will be converted to a json primative.
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: Set<T>?, for key: MapKey) throws {
        guard let value = value else { return }
        let rawValues = value.map({ $0.rawValue })
        try add(rawValues, for: key)
    }
    
    /**
     Returns a set of objects converted to the specified RawRepresentable type.
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> Set<T> {
        let objects: [T] = try value(from: key)
        return Set(objects)
    }
}

// MARK: Codable

extension Map {
    
    /**
     Add a value to the map.
     
     - parameter value: the nested `Encodable` object that will be serialized to JSON be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: Encodable>(encodable: T?, for key: MapKey) throws {
        guard let encodable = encodable else { return }
        let data = try JSONEncoder().encode(encodable)
        let serializedObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        try self.add(serializedObject as Any, for: key)
    }
    
    /**
     Returns a `Decodable` value from the map.
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be decoded or if it is nil.
     - returns: The decoded object.
     */
    public func decodable<T: Decodable>(from key: MapKey) throws -> T {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: MapCodable

extension Map {
    
    /**
     Add a value to the map. The object will be serialized to JSON.
     
     - parameter value: the nested `MapEncodable` object that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapEncodable>(_ encodable: T?, for key: MapKey) throws {
        guard let encodable = encodable else { return }
        let json = try encodable.json()
        try self.add(json as Any, for: key)
    }
    
    /**
     Returns a value from the map. The object will be converted from JSON..
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey) throws -> T {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        
        if let json = value as? [String: Any] {
            return try T(json: json)
        } else {
            throw MapDecodingError.unexpectedType(key: key)
        }
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapEncodable>(_ encodableArray: [T], for key: MapKey) throws {
        let values = try encodableArray.map({ (encodable: T) -> [String: Any?] in
            let map = try encodable.filledMap()
            return map.tree
        })
        
        try self.add(values as Any, for: key)
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[[String: Any?]]``. The object will be converted by using its mapping function.
     
     - parameter key: The JSON key for the array of objects that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or it is nil and no default value was specified.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey, stopOnFailure: Bool = false) throws -> [T] {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        
        if let paramsArray = value as? [[String: Any?]] {
            return try paramsArray.compactMap({
                do {
                    return try T(json: $0)
                } catch {
                    guard stopOnFailure else { return nil }
                    throw error
                }
            })
        } else {
            throw MapDecodingError.unexpectedType(key: key)
        }
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapEncodable>(_ values: [String: T], for key: MapKey) throws {
        var results: [String: [String: Any?]] = [:]
        
        for (key, encodable) in values {
            let json = try encodable.json()
            results[key] = json
        }
        
        try self.add(results as Any, for: key)
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[String: [String: Any?]]`. The object will be converted by using its mapping function.
     
     - parameter key: The JSON key for the dictionary of objects that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey, stopOnFailure: Bool = false) throws -> [String: T] {
        guard let value: Any = try self.value(from: key) else { throw MapDecodingError.valueNotFound(key: key) }
        
        if let jsonDictionary = value as? [String: [String: Any?]] {
            var results: [String: T] = [:]
            
            for (key, json) in jsonDictionary {
                do {
                    let decodable = try T(json: json)
                    results[key] = decodable
                } catch {
                    guard stopOnFailure else { continue }
                    throw error
                }
            }
            
            return results
        } else {
            throw MapDecodingError.unexpectedType(key: key)
        }
    }
}
