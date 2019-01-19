//
//  RawRepresentableCoder.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2019-01-19.
//

import Foundation

/// A transform to convert a `RawRepresentable` object into a JSON primitive.
public class RawRepresentableEncoder<T: RawRepresentable>: MapEncoder {
    
    /// Initialized the object
    public init() {}
    
    /// Converts the `RawRepresentable` object to its raw value.
    ///
    /// - Parameter value: The `RawRepresentable` value to convert.
    /// - Returns: The raw representation of the object.
    /// - Throws: Throws no errors.
    public func toMap(value: T) throws -> T.RawValue? {
        return value.rawValue
    }
}


/// Transforms a JSON primitive object into a `RawRepresentable` object.
public class RawRepresentableDecoder<T: RawRepresentable>: MapDecoder {
    
    /// Initialized the object
    public init() {}
    
    
    /// Converts a RawValue into a `RawRepresentable` object.
    ///
    /// - Parameter value: The raw value.
    /// - Returns: The `RawRepresentable` object.
    /// - Throws: Throws no errors.
    public func fromMap(value: T.RawValue) throws -> T? {
        return T(rawValue: value)
    }
}
