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
     Thrown when the JSON object could not be decoded to the specified object for the given key. For example, you're expecting the object to parse to a specific `MapCodable` object, but the JSON structure is not valid for that object. Can also be thrown for invalid enum types.
     */
    case failedToDecode(key: MapKey)
    
    /**
     Thrown when the JSON value for the key provided is different from the expected type. For example if you're expecting a `String` but the JSON dictionary contains an `Int`.
     */
    case unexpectedType(key: MapKey, expected: Any.Type, received: Any.Type)
    
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
        case .unexpectedType(let key, let expected, let received):
            return "Could not return value for key `\(key.rawValue)` because its type is invalid. Expected to get `\(expected)` but received `\(received)`."
        case .invalidKey(let key):
            return "Could not return value from map because the key `\(key.rawValue)` is invalid or uses unsupported characters."
        }
    }
}
