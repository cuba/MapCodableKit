//
//  EncodableMapCoder.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2019-01-19.
//

import Foundation

/// This object transforms an `Encodable` object into a JSON dictionary.
open class EncodableMapEncoder<T: Encodable>: MapEncoder {
    
    /// Initialized the object
    public init() {}
    
    
    /// The method that is called by the mapper which performs the transform.
    ///
    /// - Parameter value: The `Encodable` object that is to be transformed.
    /// - Returns: The json dictionary that is constructed.
    /// - Throws: Throws any errors the `JSONEncoder` `encode` or `JSONSerialization` `jsonObject` method encounters
    open func toMap(value: T) throws -> Any? {
        let data = try JSONEncoder().encode(value)
        let serializedObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return serializedObject
    }
}

/// This object transforms a json value to a `Decodable` object.
open class DecodableMapDecoder<T: Decodable>: MapDecoder {
    
    /// Initialized the object
    public init() {}
    
    
    /// The method called by the mapper which performs the transform.
    ///
    /// - Parameter value: The JSON dictionary that is to be transformed.
    /// - Returns: The transformed `Decodable` object.
    /// - Throws: Throws any errors the `JSONDecoder` `decode` or `JSONSerialization` `data` method encounters
    open func fromMap(value: Any) throws -> T? {
        let data = try JSONSerialization.data(withJSONObject: value, options: .prettyPrinted)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
