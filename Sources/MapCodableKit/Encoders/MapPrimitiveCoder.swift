//
//  MapPrimitiveCoder.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2019-01-19.
//

import Foundation

/// A transform to convert a `MapPrimitive` object back to itself. Does no transformation.
/// Simply a wrapper to use all the built in map functions.
public class MapPrimitiveEncoder<T: MapPrimitive>: MapEncoder {
    
    /// Initialized the object
    public init() {}
    
    /// Returns the value back
    ///
    /// - Parameter value: A `MapPrimitive` object
    /// - Returns: The same `MapPrimitive` object passed in value.
    /// - Throws: Throws no errors.
    public func toMap(value: T) throws -> T? {
        return value
    }
}


/// A transform to convert a `MapPrimitive` object back to itself. Does no transformation.
/// Simply a wrapper to use all the built in map functions.
public class MapPrimitiveDecoder<T: MapPrimitive>: MapDecoder {
    
    /// Initialized the object
    public init() {}
    
    /// Returns the value back
    ///
    /// - Parameter value: A `MapPrimitive` object
    /// - Returns: The same `MapPrimitive` object passed in value.
    /// - Throws: Throws no errors.
    public func fromMap(value: T) throws -> T? {
        return value
    }
}
