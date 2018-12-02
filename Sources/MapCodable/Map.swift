//
//  Map.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

public typealias MapKey = String

public class Map {
    private var values: [MapKey: Any?]
    
    /**
     Initialize this map from a dictionary
     */
    public init(json: [MapKey: Any?] = [:]) {
        self.values = json
    }
    
    /**
     Initialize this `Map` from a `MapEncodable` object using its `fill` method.
     */
    public convenience init(_ mapEncodable: MapEncodable) throws {
        self.init()
        try mapEncodable.fill(map: self)
    }
    
    /**
     Initialize this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public convenience init(jsonString: String, encoding: String.Encoding = .utf8) throws {
        guard let data = jsonString.data(using: encoding) else {
            self.init()
            return
        }
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        
        if let json = jsonObject as? [MapKey: Any] {
            self.init(json: json)
        } else {
            self.init()
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
        
        if let json = jsonObject as? [MapKey: Any?] {
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
        
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [.allowFragments])
        
        if let paramsArray = jsonObject as? [[MapKey: Any?]] {
            return paramsArray.map({ Map(json: $0) })
        } else {
            return []
        }
    }
    
    /**
     Returns the dictionary representation of this map
     
     - returns: A dictionary object representing this map.
     */
    public func makeDictionary() -> [MapKey: Any?] {
        return values
    }
    
    /**
     Serializes this object into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        return try JSONSerialization.data(withJSONObject: makeDictionary(), options: options)
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
    private func add(_ value: Any?, forKey key: MapKey) {
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
    private func value(fromKey key: MapKey) -> Any? {
        let keyParts = key.split(separator: ".")
        var currentValue: Any? = values
        
        for keyPart in keyParts {
            guard let dictionary = currentValue as? [String: Any?] else { return nil }
            guard let value = dictionary[String(keyPart)] else { return nil }
            currentValue = value
        }
        
        return currentValue
    }
}

public extension Sequence where Iterator.Element == Map {
    
    /**
     Returns an array representation of all these maps.
     
     - returns: An array of all the dictionary objects representing the maps.
     */
    func makeDictionaries() -> [[String: Any?]] {
        let array = self.map({ $0.makeDictionary() })
        return array
    }
    
    /**
     Serializes an `Array` of `Map` objects into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let array = makeDictionaries()
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
    public func add<T: MapEncoder>(_ value: T.Object?, forKey key: MapKey, using encoder: T) throws {
        guard let value = value else { return }
        guard let encoded = try encoder.toMap(value: value) else { return }
        self.add(encoded as Any, forKey: key)
    }
    
    /**
     Returns a value from the map. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecoder>(fromKey key: MapKey, using decoder: T) throws -> T.Object {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let element = value as? T.Primitive else { throw MappingError.invalidType(key: key) }
        
        guard let object = try decoder.fromMap(value: element) else {
            throw MappingError.failedToDecode(key: key)
        }
        
        return object
    }
}

// MARK: MapPrimitive

extension Map {
    
    /**
     Add a MapPrimitive value to the map. MapPrimitive values includes:
     * `String`
     * `Int`
     * `Bool`
     * `Double`
     * `[T]` where T also conforms to `MapPrimitive`
     
     - parameter value: The value that will be stored in the map
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: MapPrimitive>(_ value: T?, forKey key: MapKey) {
        guard let value = value else { return }
        self.add(value as Any, forKey: key)
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(fromKey key: MapKey) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? T else { throw MappingError.invalidType(key: key) }
        return object
    }
    
    /**
     Returns a value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapPrimitive>(fromKey key: MapKey) throws -> Set<T> {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let object = value as? [T] else { throw MappingError.invalidType(key: key) }
        return Set(object)
    }
}

// MARK: RawRepresentable

extension Map {
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: RawRepresentable>(_ value: T?, forKey key: MapKey) {
        guard let value = value else { return }
        self.add(value.rawValue as Any, forKey: key)
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(fromKey key: MapKey) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let rawValue = value as? T.RawValue else { throw MappingError.invalidType(key: key) }
        guard let object = T(rawValue: rawValue) else { throw MappingError.failedToDecode(key: key) }
        return object
    }
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: RawRepresentable>(_ value: [T]?, forKey key: MapKey) {
        guard let value = value else { return }
        let rawValues = value.map({ $0.rawValue })
        self.add(rawValues as Any, forKey: key)
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(fromKey key: MapKey) throws -> [T] {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let rawValues = value as? [T.RawValue] else { throw MappingError.invalidType(key: key) }
        let objects = rawValues.compactMap({ T(rawValue: $0) })
        return objects
    }
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: RawRepresentable>(_ value: [String: T]?, forKey key: MapKey) {
        guard let value = value else { return }
        var rawValues: [String: T.RawValue] = [:]
        value.forEach({ rawValues[$0] = $1.rawValue })
        self.add(rawValues as Any, forKey: key)
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(fromKey key: MapKey) throws -> [String: T] {
        guard let values: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        guard let rawValues = values as? [String: T.RawValue] else { throw MappingError.invalidType(key: key) }
        var result: [String: T] = [:]
        
        for (key, rawValue) in rawValues {
            guard let value = T(rawValue: rawValue) else { continue }
            result[key] = value
        }
        
        return result
    }
    
    /**
     Add a value to the map
     
     - parameter value: The value that will be stored in the map. Will be converted to its RawType.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: RawRepresentable>(_ value: Set<T>?, forKey key: MapKey) {
        guard let value = value else { return }
        let rawValues = value.map({ $0.rawValue })
        add(rawValues, forKey: key)
    }
    
    /**
     Returns a value from the map
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value is invalid or it is nil. Filters out any enums that don't serialize properly instead of failing.
     - returns: The deserialized object.
     */
    public func value<T: RawRepresentable>(fromKey key: MapKey) throws -> Set<T> {
        let objects: [T] = try value(fromKey: key)
        return Set(objects)
    }
}

// MARK: Codable

extension Map {
    
    /**
     Add a value to the map. The object will be converted by using its mapping function.
     
     - parameter value: the nested `MapEncodable` object that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: Encodable>(encodable: T?, forKey key: MapKey) throws {
        guard let encodable = encodable else { return }
        let data = try JSONEncoder().encode(encodable)
        let serializedObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        self.add(serializedObject as Any, forKey: key)
    }
    
    /**
     Returns a `Decodable` value from the map.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be decoded or if it is nil.
     - returns: The decoded object.
     */
    public func decodable<T: Decodable>(fromKey key: MapKey) throws -> T {
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
    public func add<T: MapEncodable>(_ encodable: T?, forKey key: MapKey) throws {
        guard let encodable = encodable else { return }
        let json = try encodable.json()
        self.add(json as Any, forKey: key)
    }
    
    /**
     Returns a value from the map. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or if it is nil.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(fromKey key: MapKey) throws -> T {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        
        if let json = value as? [String: Any] {
            return try T(json: json)
        } else {
            throw MappingError.invalidType(key: key)
        }
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: MapEncodable>(_ encodableArray: [T], forKey key: MapKey) throws {
        let values = try encodableArray.map({ (encodable: T) -> [String: Any?] in
            let map = try encodable.filledMap()
            return map.values
        })
        
        self.add(values as Any, forKey: key)
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[[String: Any]]`, `String` or `[String]`. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil and no default value was specified.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(fromKey key: MapKey, stopOnFailure: Bool = false) throws -> [T] {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        
        if let paramsArray = value as? [[String: Any]] {
            return try paramsArray.compactMap({
                do {
                    return try T(json: $0)
                } catch {
                    guard stopOnFailure else { return nil }
                    throw error
                }
            })
        } else {
            throw MappingError.invalidType(key: key)
        }
    }
    
    /**
     Add an array to the map. The objects will be converted by using their mapping function.
     
     - parameter value: The nested `MapEncodable` array that will be stored in the map.
     - parameter key: The key that will be used to store this value and that can be used to later retrive this value
     */
    public func add<T: MapEncodable>(_ values: [String: T], forKey key: MapKey) throws {
        var results: [String: [String: Any?]] = [:]
        
        for (key, encodable) in values {
            let json = try encodable.json()
            results[key] = json
        }
        
        self.add(results as Any, forKey: key)
    }
    
    /**
     Returns a value from the map. Deserializes the object from `[[String: Any]]`, `String` or `[String]`. The object will be converted by using its mapping function.
     
     - parameter key: The key that that is used to store this value in the map.
     - throws: Throws an error if the value could not be deserialized or it is nil and no default value was specified.
     - returns: The deserialized object.
     */
    public func value<T: MapDecodable>(fromKey key: MapKey, stopOnFailure: Bool = false) throws -> [String: T] {
        guard let value: Any = self.value(fromKey: key) else { throw MappingError.valueNotFound(key: key) }
        
        if let jsonDictionary = value as? [String: [String: Any]] {
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
            throw MappingError.invalidType(key: key)
        }
    }
}
