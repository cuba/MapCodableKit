//
//  Errors.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

/**
 An error that is returned when attempting to return an object from a `Map`.
 */
public enum MapDecodingError: Error, CustomStringConvertible {
    
    /**
     Thrown when the key provided does not correspond to any value in the JSON dictionary.
     */
    case valueNotFound(key: MapKey)
    
    /**
     Thrown when the JSON object could not be decoded to the specified object.
     */
    case failedToDecode(key: MapKey)
    
    /**
     Thrown when the JSON value is different from the expected type. For example if you're expecting a string but an Int is returned instead.
     */
    case unexpectedType(key: MapKey)
    
    /**
     Thrown when the key provided when trying to get a value from a map could not be parsed.
     */
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
