//
//  MapCodableCoder.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2019-01-19.
//

import Foundation

/// This object transforms a MapEncodable object into a json dictionary.
public class MapEncodableEncoder<T: MapEncodable>: MapEncoder {
    
    /// Initialized the object
    public init() {}
    
    
    /// The method that is called by the mapper which performs the transform.
    ///
    /// - Parameter value: The MapEncodable object that is to be transformed.
    /// - Returns: The json dictionary that is constructed.
    /// - Throws: Throws any errors the `MapEncodable` fill method encounters.
    public func toMap(value: T) throws -> [String: Any?]? {
        return try value.json()
    }
}

/// This object transforms a json value to a MapDecodable object.
public class MapDecodableDecoder<T: MapDecodable>: MapDecoder {
    
    /// Initialized the object
    public init() {}
    
    
    /// The method called by the mapper which performs the transform
    ///
    /// - Parameter value: The JSON dictionary that is to be transformed.
    /// - Returns: The transformed MapDecodable object.
    /// - Throws: Throws any errors the `MapDecodable` init method encouters.
    public func fromMap(value: [String: Any?]) throws -> T? {
        return try T(json: value)
    }
}
