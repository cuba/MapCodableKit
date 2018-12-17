//
//  Errors.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

/**
 An error that is returned when attempting to return an object from a map.
 */
public enum MapDecodingError: Error, CustomStringConvertible {
    case valueNotFound(key: MapKey)
    case failedToDecode(key: MapKey)
    case unexpectedType(key: MapKey)
    case invalidKey(key: MapKey)
    
    public var description: String {
        switch self {
        case .failedToDecode(let key):
            return "Could not return value for key `\(key.rawValue)` because it cound not be decoded."
        case .valueNotFound(let key):
            return "Could not return value from map because no value cound not be found for key `\(key.rawValue)`."
        case .unexpectedType(let key):
            return "Could not return value for key `\(key.rawValue)` because its type is invalid. "
        case .invalidKey(let key):
            return "Could not return value from map because the key `\(key.rawValue)` is invalid or uses unsupported characters."
        }
    }
}
