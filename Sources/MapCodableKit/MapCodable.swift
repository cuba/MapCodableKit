//
//  MapCodable.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

/**
 A protocol that adds support of complex objects to be serialized into a json object.
 */
public protocol MapEncodable {
    
    /**
     Fill a map with the contents of this object.
     
     - parameter map: A map that needs to be filled with this object. In default implementations, this map is empty.
     */
    func fill(map: Map) throws
}

/**
 A protocol that adds support of complex objects to be deserialized from a json object.
 */
public protocol MapDecodable {
    
    /**
     Initializes the object with the contents of a map
     
     - parameter map: A filled map that represents the content of this object.
     */
    init(map: Map) throws
}

/**
 A wrapper protocol that reqires both `MapEncodable` and `MapDecodable` protocols.
 */
public protocol MapCodable: MapEncodable, MapDecodable {
}

/**
 Convenience extension for `MapEncodable` objects.
 */
public extension MapEncodable {
    
    /**
     Returns a map filled with the contents of this object
     
     - throws: Throws an error if this object fails to initalize. This will mostly likely throw a `MapDecodingError` but since this method is implemented by the user, it may throw any error.
     - returns: The filled map.
     */
    func filledMap() throws -> Map {
        let map = Map()
        try self.fill(map: map)
        return map
    }
    
    /**
     Returns a map filled with the contents of this object
     
     - throws: Throws an error if this object fails to initalize. This will mostly likely throw a `MapDecodingError` but since this method is implemented by the user, it may throw any error.
     - returns: The filled map.
     */
    func json() throws -> [String: Any?] {
        let map = try filledMap()
        return map.makeDictionary()
    }
    
    /**
     Serializes this object into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let map = try filledMap()
        return try map.jsonData(options: options)
    }
    
    /**
     Serializes this object into a JSON `String`
     
     - parameter options: The writing options.
     - parameter encoding: The string encoding that should be used.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonString(options: JSONSerialization.WritingOptions = [], encoding: String.Encoding = .utf8) throws -> String? {
        let map = try filledMap()
        return try map.jsonString(options: options, encoding: encoding)
    }
}

/**
 Convenience extension for `MapDecodable` objects.
 */
public extension MapDecodable {
    
    /**
     Initialize this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public init(jsonString: String, encoding: String.Encoding = .utf8) throws {
        let map = try Map(jsonString: jsonString, encoding: encoding)
        try self.init(map: map)
    }
    
    /**
     Initialize this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public init(jsonData: Data, encoding: String.Encoding = .utf8) throws {
        let map = try Map(jsonData: jsonData, encoding: encoding)
        try self.init(map: map)
    }
    
    /**
     Initialize this object from a JSON Object
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    public init(json: [String: Any]) throws {
        let map = Map(json: json)
        try self.init(map: map)
    }
    
    /**
     Initialize an array of this object from a JSON `String`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - parameter failOnError: When true, throws an exception if any object fails to parse. Otherwise the object is just removedfrom the list.
     - throws: Throws an error if the json string cannot be deserialized.
     */
    static func parseArray(jsonString: String, encoding: String.Encoding = .utf8, failOnError: Bool = false) throws -> [Self] {
        let maps = try Map.parseArray(jsonString: jsonString, encoding: encoding)
        
        let result: [Self] = try maps.compactMap() {
            do {
                return try Self(map: $0)
            } catch {
                guard failOnError else { return nil }
                throw error
            }
        }
        
        return result
    }
    
    /**
     Initialize an array of this object from a JSON `Data`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    static func parseArray(jsonData: Data, failOnError: Bool = false) throws -> [Self]{
        let maps = try Map.parseArray(jsonData: jsonData)
        
        let result: [Self] = try maps.compactMap() {
            do {
                return try Self(map: $0)
            } catch {
                guard failOnError else { return nil }
                throw error
            }
        }
        
        return result
    }
    
    /**
     Initialize an array of this object from a JSON `Data`
     - parameter jsonString: The JSON `String` that will be deserialized
     - parameter encoding: The encoding used on the string
     - throws: Throws an error if the json string cannot be deserialized.
     */
    static func parseArray(json: [[String: Any]], failOnError: Bool = false) throws -> [Self]{
        let maps = json.map({ Map(json: $0) })
        
        let result: [Self] = try maps.compactMap() {
            do {
                return try Self(map: $0)
            } catch {
                guard failOnError else { return nil }
                throw error
            }
        }
        
        return result
    }
}

extension Array {
    
}
