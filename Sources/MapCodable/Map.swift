//
//  Map.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

public class Map {
    private(set) public var values: [String: Any]
    
    /**
     Initialize this map from a dictionary
     */
    public init(values: [String: Any]) {
        self.values = values
    }
    
    /**
     Initialize this `Map` from a `MapEncodable` object using its `fill` method.
     */
    public convenience init(_ mapEncodable: MapEncodable) {
        self.init(values: [:])
        mapEncodable.fill(map: self)
    }
    
    /**
     Initialize an empty `Map`
     */
    public convenience init() {
        self.init(values: [:])
    }
    
    /**
     Initialize this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public convenience init(jsonString: String, encoding: String.Encoding = .utf8) throws {
        guard let data = jsonString.data(using: encoding) else {
            self.init(values: [:])
            return
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let params = jsonObject as? [String: Any] {
            self.init(values: params)
        } else {
            self.init(values: [:])
        }
    }
    
    /**
     Initialize this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public convenience init(jsonData: Data, encoding: String.Encoding = .utf8) throws {
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        
        if let params = jsonObject as? [String: Any] {
            self.init(values: params)
        } else {
            self.init(values: [:])
        }
    }
    
    /**
     Create a `Map` `Array` from a JSON `String`
     
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public static func parseArray(jsonString: String, encoding: String.Encoding = .utf8) throws -> [Map] {
        print(jsonString)
        guard let data = jsonString.data(using: encoding) else {
            return []
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        
        if let paramsArray = jsonObject as? [[String: Any]] {
            return paramsArray.map({ Map(values: $0) })
        } else {
            return []
        }
    }
    
    /**
     Serializes this object into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: values, options: options)
    }
    
    /**
     Serializes this object into a JSON `String`
     
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
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    private func add(_ value: Any, forKey key: String) {
        var keyParts = key.split(separator: ".")
        let firstKey = keyParts.removeFirst()
        var objectToStore: Any = value
        
        for keyPart in keyParts {
            objectToStore = [keyPart: objectToStore]
        }
        
        values[String(firstKey)] = objectToStore
    }
    
    /**
     Returns a value from the map. The key used can use a period (".") to access nested objects.
     
     - parameter key: The key that that is used to store this value in the map.
     - returns: The stored object.
     */
    private func value(fromKey key: String) -> Any? {
        let keyParts = key.split(separator: ".")
        var currentValue: Any = values
        
        for keyPart in keyParts {
            guard let dictionary = currentValue as? [String: Any] else { return nil }
            guard let value = dictionary[String(keyPart)] else { return nil }
            currentValue = value
        }
        
        return currentValue
    }
}

public extension Sequence where Iterator.Element == Map {
    
    /**
     Serializes an `Array` of `Map` objects into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let array = self.map({ $0.values })
        return try JSONSerialization.data(withJSONObject: array, options: options)
    }
    
    /**
     Serializes an array of `Map` object into a JSON `String`
     
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
     Add a value to the map using a transform
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     - parameter encoder: The transform that will be used to serialize the object.
     */
    public func add<T: MapEncoder>(_ value: T.Object?, forKey key: String, using encoder: T) {
        guard let value = value else { return }
        guard let encoded = encoder.toMap(value: value) else { return }
        values[key] = encoded
    }
    
    /**
     Returns a value from the map. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecoder>(fromKey key: String, using decoder: T) throws -> T.Object {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let element = value as? T.Primitive else { throw MappingError.invalidType(key: key) }
        
        guard let object = try decoder.fromMap(value: element) else {
            throw MappingError.failedToMap(key: key)
        }
        
        return object
    }
}

// MARK: String

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add(_ value: String?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value(fromKey key: String) throws -> String {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? String else { throw MappingError.invalidType(key: key) }
        return object
    }
}

// MARK: Int

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add(_ value: Int?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is nil.
     - returns: The deserialized object or the default value specified
     */
    public func value(fromKey key: String) throws -> Int {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? Int else { throw MappingError.invalidType(key: key) }
        return object
    }
}

// MARK: Bool

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add(_ value: Bool?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is nil.
     - returns: The deserialized object or the default value specified
     */
    public func value(fromKey key: String) throws -> Bool {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? Bool else { throw MappingError.invalidType(key: key) }
        return object
    }
}

// MARK: Double

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add(_ value: Double?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is nil.
     - returns: The deserialized object or the default value specified
     */
    public func value(fromKey key: String) throws -> Double {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? Double else { throw MappingError.invalidType(key: key) }
        return object
    }
}

// MARK: RawRepresentable

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: RawRepresentable>(_ value: T?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value.rawValue
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(fromKey key: String) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let rawValue = value as? T.RawValue else { throw MappingError.invalidType(key: key) }
        guard let object = T(rawValue: rawValue) else { throw MappingError.failedToMap(key: key) }
        return object
    }
}

// MARK: [String: String]

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add(_ value: [String: String]?, forKey key: String) {
        guard let value = value else { return }
        values[key] = value
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value(fromKey key: String) throws -> [String: String] {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? [String: String] else { throw MappingError.invalidType(key: key) }
        return object
    }
}

// MARK: Codable

extension Map {
    
    /**
     Add a value to the map. The object will be converted by using its mapping function.
     
     - parameter value: the nested `MapEncodable` object that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: Encodable>(encodable: T?, forKey key: String) throws {
        guard let encodable = encodable else { return }
        let data = try JSONEncoder().encode(encodable)
        let seralizedObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        
        values[key] = seralizedObject
    }
    
    /**
     Returns a `Decodable` value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be decoded or if it is nil.
     - returns: The decoded object.
     */
    public func decodable<T: Decodable>(fromKey key: String) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: MapCodable

extension Map {
    
    /**
     Add a value to the map. The object will be converted by using its mapping function.
     
     - parameter value: the nested `MapEncodable` object that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: MapEncodable>(_ encodable: T?, forKey key: String) {
        guard let encodable = encodable else { return }
        let map = Map(encodable)
        values[key] = map.values
    }
    
    /**
     Returns a value from the map. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(fromKey key: String) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        
        if let params = value as? [String: Any] {
            let map = Map(values: params)
            return try T(map: map)
        } else if let string = value as? String {
            let map = try Map(jsonString: string)
            return try T(map: map)
        } else {
            throw MappingError.invalidType(key: key)
        }
    }
}

// MARK: MapCodable Array

extension Map {
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: MapEncodable>(_ encodableArray: [T], forKey key: String) {
        let values = encodableArray.map({ (encodable: T) -> [String: Any] in
            let map = Map(encodable)
            return map.values
        })
        
        self.values[key] = values
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[[String: Any]]`, `String` or `[String]`. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil and no default value was specified.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(fromKey key: String) throws -> [T] {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        
        if let paramsArray = value as? [[String: Any]] {
            return try paramsArray.map({
                let map = Map(values: $0)
                return try T(map: map)
            })
        } else if let string = value as? String {
            let maps = try Map.parseArray(jsonString: string)
            return try maps.map({ try T(map: $0) })
        } else if let stringsArray = value as? [String] {
            return try stringsArray.map({
                let map = try Map(jsonString: $0)
                return try T(map: map)
            })
        } else {
            throw MappingError.invalidType(key: key)
        }
    }
}
