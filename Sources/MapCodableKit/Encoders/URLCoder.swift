//
//  MapEncodableEncoder.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

/**
 Transforms a `String` to a `URL` using its `URL(string:String)` when getting value from a map.
 Transforms a `URL` back to a `String` using its `absoluteString` variable when adding it to a map.
 */
public class URLCoder: MapCoder {
    
    public init() {}
    
    /**
     Converts a `URL` into a `String` value using its `absoluteString` property.
     */
    public func toMap(value: URL) -> String? {
        return value.absoluteString
    }
    
    /**
     Attempts to convert a `String` into a `URL` using its `init(string:String)` initializer.
     */
    public func fromMap(value: String) throws -> URL? {
        return URL(string: value)
    }
}
