//
//  MapEncodingError.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-17.
//

import Foundation

/**
 An error that is returned when attempting to return an object from a map.
 */
public enum MapEncodingError: Error, CustomStringConvertible {
    case invalidKey(key: MapKey)
    
    public var description: String {
        switch self {
        case .invalidKey(let key):
            return "Could not add value to map because the key `\(key.rawValue)` is invalid or uses unsupported characters."
        }
    }
}
