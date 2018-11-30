//
//  MapCodable.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

public protocol MapEncodable {
    
    /**
     Fill a map with the contents of this object.
     
     - parameter map: A map that needs to be filled with this object. In default implementations, this map is empty.
     */
    func fill(map: Map)
}

public protocol MapDecodable {
    
    /**
     Initializes the object with the contents of a map
     
     - parameter map: A filled map that represents the content of this object.
     */
    init(map: Map) throws
}

public protocol MapCodable: MapEncodable, MapDecodable {
}

public extension MapEncodable {
    
    /**
     Returns a map filled with the contents of this object
     
     - throws: Throws an error if this object fails to initalize. This will mostly likely throw a `MappingError` but since this method is implemented by the user, it may throw any error.
     - returns: The filled map.
     */
    func filledMap() -> Map {
        let map = Map()
        self.fill(map: map)
        return map
    }
    
    /**
     Serializes this object into a JSON `Data` object
     
     - parameter options: The writing options.
     - throws: Throws an error if this object failed to serialize.
     - returns: The serialized object.
     */
    public func jsonData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        let map = filledMap()
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
        let map = filledMap()
        return try map.jsonString(options: options, encoding: encoding)
    }
}

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
}
