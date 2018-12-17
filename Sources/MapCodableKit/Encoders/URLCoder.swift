//
//  MapEncodableEncoder.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

/**
 Transforms a `String` to a `URL` using its `URL(string:String)` when getting value from a map.
 Transforms a `URL~ back to a `String` using its `absoluteString` variable when adding it to a map.
 */
public class URLCoder: MapCoder {
    
    public init() {}
    
    public func toMap(value: URL) -> String? {
        return value.absoluteString
    }
    
    public func fromMap(value: String) throws -> URL? {
        return URL(string: value)
    }
}
