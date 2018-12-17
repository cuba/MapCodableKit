//
//  MapKey.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import Foundation


/**
 A MapKey is a protocol that provides a parsing mechanism for converting any object (such as a `String`) into key parts (an array of `KeyPart` objects). Key parts individually represent a key in a JSON dictionary or position in a JSON array. When combined, key parts represent the nesting structure of a JSON dictionary for a specific value, object or array. The order of key parts matter as they coencide with the nesting order in a dictionary.
 
 For example, lets say we are given the following key parts:
 1 `KeyPart.object("first")`
 2 `KeyPart.array("second")`
 3 `KeyPart.object("first")`
 
 This can be used to return the value "My Value" from the nested key `first` in the following JSON dictionary:
 
 ```json
 {
    "first": {
        "second": [
            {
                "first": "My Value"
            }
        ]
    }
 }
 ```
 
 Using this key when storing a value in the map will, on the other hand, create the above JSON dictionary.
 
 JSON dictionaries created using key parts are merged when the key part does not represent a leaf in a JSON dictionary.
 
 For example, if I were to add the value "My other value" to the above JSON using the following key parts:
 1 `KeyPart.object("first")`
 2 `KeyPart.array("second")`
 3 `KeyPart.object("second")`
 
 Then i will end up with the following result:
 ```json
 {
    "first": {
        "second": [
            {
                "first": "My Value"
                "second": "My other Value"
            }
        ],
    }
 }
 ```
 */
public protocol MapKey {
    
    /**
     Returns the raw representation (human readable `String`) of the `MapKey`.
     */
    var rawValue: String { get }
    
    /**
     A method that parses the object into key parts (an array of `KeyPart`)
     */
    func parseKeyParts() throws -> [KeyPart]
}

/**
 A key that represents a value or object in a dictionary. A `KeyPart` also conforms to a `MapKey` so that they can be individually used in an `Map`.
 */
public enum KeyPart: MapKey {
    
    /**
     Represents an object, dictionary or primitive value in a dictionary.
     */
    case object(key: String)
    
    /**
     Represents the first object in a JSON dictionary.
     */
    case array(key: String)
    
    /**
     Returns the JSON key representing the object, primitive or array. Strips out extra information such as any array indexes.
     */
    public var key: String {
        switch self {
        case .object(let key):
            return key
        case .array(let key):
            return key
        }
    }
    
    /**
     Returns a raw (human readable) representation of this key as it would be before it was parsed.
     */
    public var rawValue: String {
        switch self {
        case .object(let key):
            return key
        case .array(let key):
            return "\(key)[]"
        }
    }
    
    /**
     Returns a raw (human readable) representation of this key as it would be before it was parsed.
     */
    public func parseKeyParts() throws -> [KeyPart] {
        return [self]
    }
}

// MARK: MapKey Arrays

extension Array: MapKey where Element: MapKey {
    
    /**
     Returns a string (human readable) representation of these keys.
     */
    public var rawValue: String {
        return self.map({ $0.rawValue }).joined(separator: ".")
    }
    
    
    /**
     Returns iteslf.
     */
    public func parseKeyParts() throws -> [KeyPart] {
        return self as! [KeyPart]
    }
}
