//
//  MapEncodableEncoder.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

public class URLCoder: MapCoder {
    
    public func toMap(value: URL) -> String? {
        return value.absoluteString
    }
    
    public func fromMap(value: String) throws -> URL? {
        return URL(string: value)
    }
}
