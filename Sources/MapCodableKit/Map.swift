//
//  Map.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

/**
 A wrapper around a JSON object that conveniently returns parsed objects or adds complex objects into the JSON object.
 
 Basic example of returning objects:
 ```
 let jsonString = // Source of JSON string
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
     - throws: Throws an error if the JSON string cannot be deserialized.
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
     - throws: Throws an error if the JSON string cannot be deserialized.
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
     - throws: Throws an error if the JSON string cannot be deserialized.
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
     - throws: Throws an error if the JSON string cannot be deserialized.
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
    
    public func has(key: MapKey) throws -> Bool {
        let parts = try key.parseKeyParts()
        var currentValue: Any? = tree
        
        for (index, part) in parts.enumerated() {
            guard let dictionary = currentValue as? [String: Any?] else { return false }
            guard dictionary.keys.contains(part.key) else { return false }
            
            // If we are at the end of the key, we don't have to check anything else. We're done
            guard index < (parts.count - 1) else { return true }
            
            // Since we are not at the end of the key, we should have another value
            switch part {
            case .object:
                guard let value = dictionary[part.key] else { return false }
                currentValue = value
            case .array:
                guard let array = dictionary[part.key] as? [[String: Any?]] else { return false }
                currentValue = array.first
            }
        }
        
        return true
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
     Serializes this set into a JSON data object.
     
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

// MARK: MapCoder

extension Map {
    
    /**
     Add a value to the map encoding it using the provided `MapEncoder`.
     
     - parameter value: The value that will be stored in this map.
     - parameter key: The JSON key that will be used for the JSON object.
     - parameter encoder: The encoder that will be used to serialize the object.
     */
    public func add<T: MapEncoder>(_ value: T.Object?, for key: MapKey, using encoder: T) throws {
        guard let value = value else {
            try self.add(nil, for: key)
            return
        }
        
        guard let encoded = try encoder.toMap(value: value) else { return }
        try self.add(encoded as Any, for: key)
    }
    
    /**
     Returns a value from the map. The value will be decoded it using the provided `MapDecoder`.
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be deserialized.
     - returns: The deserialized object.
     */
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T) throws -> T.Object? {
        guard let value: Any = try self.value(from: key) else { return nil }
        guard let element = value as? T.Primitive else { throw MapDecodingError.unexpectedType(key: key, expected: T.self, received: type(of: value).self) }
        
        guard let object = try decoder.fromMap(value: element) else {
            throw MapDecodingError.failedToDecode(key: key)
        }
        
        return object
    }
    
    /**
     Returns a value from the map. The value will be decoded it using the provided `MapDecoder`.
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T) throws -> T.Object {
        let value: T.Object? = try self.value(from: key, using: decoder)
        
        if let value = value {
            return value
        } else {
            throw MapDecodingError.valueNotFound(key: key)
        }
    }
    
    
    /// Adds an array of values using the specified encoder. If the encoder returns nil, nil values will be added to the array
    ///
    /// - Parameters:
    ///   - values: The values to be added to the map
    ///   - key: The key that is used that references this data set
    ///   - encoder: The encoder that will transform the object into a JSON friendly object
    /// - Throws: Any errors encountered by the encoder will be thrown
    public func add<T: MapEncoder>(_ values: [T.Object]?, for key: MapKey, using encoder: T) throws {
        guard let values = values else {
            try self.add(nil, for: key)
            return
        }
        
        var encodedValues: [T.Primitive?] = []
        
        for value in values {
            let encodedValue = try encoder.toMap(value: value)
            encodedValues.append(encodedValue)
        }
        
        try self.add(encodedValues as Any, for: key)
    }
    
    /// Adds an set of values using the specified encoder. If the encoder returns nil, nil values will be added to the array
    ///
    /// - Parameters:
    ///   - values: The values to be added to the map
    ///   - key: The key that is used that references this data set
    ///   - encoder: The encoder that will transform the object into a JSON friendly object.
    /// - Throws: Any errors encountered by the encoder will be thrown
    public func add<T: MapEncoder>(_ values: Set<T.Object>?, for key: MapKey, using encoder: T) throws {
        let array = values != nil ? Array(values!) : nil
        try add(array, for: key, using: encoder)
    }
    
    /// Returns an array from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created without filtering out any nil values returned by the decoder.
    /// - Throws: Throws the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [T.Object?]? {
        guard let array: Any = try self.value(from: key) else { return nil }
        
        guard let paramsArray = array as? [T.Primitive?] else {
            throw MapDecodingError.unexpectedType(key: key, expected: T.self, received: type(of: value).self)
        }
        
        return try paramsArray.map({
            guard let value = $0 else { return nil }
            
            do {
                return try decoder.fromMap(value: value)
            } catch {
                guard stopOnFailure else { return nil }
                throw error
            }
        })
    }
    
    /// Returns an array from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created filtering out any nil values returned by the decoder.
    /// - Throws: Throws if the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [T.Object]? {
        let values: [T.Object?]? = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        return values?.compactMap({ $0 })
    }
    
    /// Returns an array from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created without filtering out any nil values returned by the decoder.
    /// - Throws: Throws if the value is not found, the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [T.Object?] {
        let array: [T.Object?]? = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        
        if let array = array {
            return array
        } else {
             throw MapDecodingError.valueNotFound(key: key)
        }
    }
    
    /// Returns an array from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created filtering out any nil values returned by the decoder.
    /// - Throws: Throws if the value is not found, the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [T.Object] {
        let values: [T.Object?] = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        return values.compactMap({ $0 })
    }
    
    /// Returns an set from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created filtering out any nil values returned by the decoder.
    /// - Throws: Throws the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> Set<T.Object>? {
        let values: [T.Object]? = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        
        if let values = values {
            return Set(values)
        } else {
            return nil
        }
    }
    
    /// Returns an set from the map using the decoder specified to do the conversion.
    ///
    /// - Parameters:
    ///   - key: The json key that this object is stored under.
    ///   - decoder: The decoder that performs the transformation.
    ///   - stopOnFailure: If this is enabled, any exceptions thrown in the decoder will stop the whole operation. Otherwise the value is just filtered out of the array.
    /// - Returns: An array of objects created filtering out any nil values returned by the decoder.
    /// - Throws: Throws if the value is not found, the type is incorrect or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> Set<T.Object> {
        let set: Set<T.Object>? = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        
        if let set = set {
            return set
        } else {
            throw MapDecodingError.valueNotFound(key: key)
        }
    }
    
    /// Adds the values to the map using the specified encoder.
    ///
    /// - Parameters:
    ///   - values: The values that will be added to the map.
    ///   - key: The key that will be used to referece those values.
    ///   - encoder: The encoder that transforms the value to json object
    /// - Throws: Throws any error the encoder encounters
    public func add<T: MapEncoder>(_ values: [String: T.Object]?, for key: MapKey, using encoder: T) throws {
        guard let values = values else {
            try self.add(nil, for: key)
            return
        }
        
        var results: [String: T.Primitive] = [:]
        
        for (key, value) in values {
            let json = try encoder.toMap(value: value)
            results[key] = json
        }
        
        try self.add(results as Any, for: key)
    }
    
    
    /// Returns a value from the map.
    ///
    /// - Parameters:
    ///   - key: The key that references the value.
    ///   - decoder: The decoder that is used to transform the value into an object.
    ///   - stopOnFailure: If this is set to true, any error encountered will throw an error instead of removing the value from the dictionary.
    /// - Returns: A dictionary of the transformed values.
    /// - Throws: Throws if it is of an unexpected type or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [String: T.Object]? {
        guard let value: Any = try self.value(from: key) else { return nil }
        
        guard let jsonDictionary = value as? [String: T.Primitive?] else {
            throw MapDecodingError.unexpectedType(key: key, expected: T.self, received: type(of: value).self)
        }
        
        var results: [String: T.Object] = [:]
        
        for (key, json) in jsonDictionary {
            guard let json = json else {
                continue
            }
            
            do {
                let decodable = try decoder.fromMap(value: json)
                results[key] = decodable
            } catch {
                guard stopOnFailure else { continue }
                throw error
            }
        }
        
        return results
    }
    
    
    /// Returns a value from the map.
    ///
    /// - Parameters:
    ///   - key: The key that references the value.
    ///   - decoder: The decoder that is used to transform the value into an object.
    ///   - stopOnFailure: If this is set to true, any error encountered will throw an error instead of removing the value from the dictionary.
    /// - Returns: A dictionary of the transformed values.
    /// - Throws: Throws if the object is not found, if it is of an unexpected type or any errors encountered by the decoder.
    public func value<T: MapDecoder>(from key: MapKey, using decoder: T, stopOnFailure: Bool = false) throws -> [String: T.Object] {
        let dictionary: [String: T.Object]? = try self.value(from: key, using: decoder, stopOnFailure: stopOnFailure)
        
        if let dictionary = dictionary {
            return dictionary
        } else {
            throw MapDecodingError.valueNotFound(key: key)
        }
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
        guard let value = value else {
            try self.add(nil, for: key)
            return
        }
        
        try self.add(value as Any, for: key)
    }
    
    /**
     Returns a value from the map if it conforms to the specified `MapPrimitive` type.
     
     - parameter key: The JSON key for the primitive that will be returned.
     - throws: Throws an error if the value could not be deserialized.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(from key: MapKey) throws -> T? {
        guard let value: Any = try self.value(from: key) else { return nil }
        
        guard let object = value as? T else {
            throw MapDecodingError.unexpectedType(key: key, expected: T.self, received: type(of: value).self)
        }
        
        return object
    }
    
    /**
     Returns a value from the map if it conforms to the specified `MapPrimitive` type.
     
     - parameter key: The JSON key for the primitive that will be returned.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(from key: MapKey) throws -> T {
        let value: T? = try self.value(from: key)
        
        if let value = value {
            return value
        } else {
            throw MapDecodingError.valueNotFound(key: key)
        }
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
        try add(value, for: key, using: RawRepresentableEncoder())
    }
    
    /**
     Returns a value from the map. The object will be converted from its RawType into the .
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be converted to the specified type or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> T {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Returns a value from the map. The object will be converted from its RawType into the .
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be converted to the specified type.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> T? {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: [T]?, for key: MapKey) throws {
        try add(value, for: key, using: RawRepresentableEncoder())
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> [T] {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> [T]? {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Add a dictionary of the RawRepresentable types converted to JSON primatives.
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ value: [String: T]?, for key: MapKey) throws {
        try add(value, for: key, using: RawRepresentableEncoder())
    }
    
    /**
     Returns a dictionary of the specified `RawRepresentable` types.
     
     - parameter key: The JSON key for the dictionary that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> [String: T] {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Add a value to the map. The object will be converted to a JSON primative.
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: RawRepresentable>(_ values: Set<T>?, for key: MapKey) throws {
        try add(values, for: key, using: RawRepresentableEncoder())
    }
    
    /**
     Returns a set of objects converted to the specified RawRepresentable type.
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> Set<T> {
        return try value(from: key, using: RawRepresentableDecoder())
    }
    
    /**
     Returns a set of objects converted to the specified RawRepresentable type.
     
     - parameter key: The JSON key for the array that will be deserialized.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(from key: MapKey) throws -> Set<T>? {
        return try value(from: key, using: RawRepresentableDecoder())
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
        try add(encodable, for: key, using: EncodableMapEncoder())
    }
    
    /**
     Returns a `Decodable` value from the map.
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be decoded or if it is nil.
     - returns: The decoded object.
     */
    public func decodable<T: Decodable>(from key: MapKey) throws -> T {
        return try value(from: key, using: DecodableMapDecoder())
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
        try add(encodable, for: key, using: MapEncodableEncoder())
    }
    
    /**
     Returns a value from the map. The object will be converted from JSON..
     
     - parameter key: The JSON key for the object that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey) throws -> T {
        return try self.value(from: key, using: MapDecodableDecoder())
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapEncodable>(_ encodableArray: [T], for key: MapKey) throws {
        try add(encodableArray, for: key, using: MapEncodableEncoder())
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[[String: Any?]]``. The object will be converted by using its mapping function.
     
     - parameter key: The JSON key for the array of objects that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or it is nil and no default value was specified.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey, stopOnFailure: Bool = false) throws -> [T] {
        return try value(from: key, using: MapDecodableDecoder(), stopOnFailure: stopOnFailure)
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The JSON key that will be used for the JSON object.
     */
    public func add<T: MapEncodable>(_ values: [String: T], for key: MapKey) throws {
        try add(values, for: key, using: MapEncodableEncoder())
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[String: [String: Any?]]`. The object will be converted by using its mapping function.
     
     - parameter key: The JSON key for the dictionary of objects that will be deserialized.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(from key: MapKey, stopOnFailure: Bool = false) throws -> [String: T] {
        return try value(from: key, using: MapDecodableDecoder(), stopOnFailure: stopOnFailure)
    }
}
