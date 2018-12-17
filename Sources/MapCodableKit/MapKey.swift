//
//  MapKey.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import Foundation


/**
 A MapKey is a protocol that provides a parsing mechanism for converting any object (such as a `String`) into key parts (an array of `KeyPart` objects). Key parts individually represent a key in a json dictionary or position in an array. When combined, key parts represent the nesting structure of a JSON dictionary for a specific value, object or array. The order of key parts matter as they coencide with the nesting order in a dictionary.
 
 For example, lets say we are given the following key parts:
 # `KeyPart.object("first")`
 # `KeyPart.array("second")`
 # `KeyPart.object("first")`
 
 This can be used to return the value "My Value", from `first` in the following json dictionary:
 
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
 
 Using this key when storing a value in the map will, on the other hand, create the above dictionary. JSON dictionaries created using key parts are merged when the key part does not represent a leaf in a json dictionary.
 
 For example, if I were to add the value "My other value" to the above json using the following key parts:
 # `KeyPart.object("first")`
 # `KeyPart.array("second")`
 # `KeyPart.object("second")`
 
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
    var rawValue: String { get }
    func parseKeyParts() throws -> [KeyPart]
}

/**
 A key that represents a value or object in a dictionary. A KeyPart also conforms to a MapKey.
 */
public enum KeyPart: MapKey {
    
    /**
     Represents an object, dictionary or primitive value in a dictionary.
     */
    case object(key: String)
    
    /**
     Represents the first object in a json dictionary.
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

/**
 Adds MapKey support to strings. The string will be parsed into a MapKey by pulling out all key parts in the string. Key parts are seperated using `.`.
 
 For example, the string `first.second[].third` will be converted to the following key parts:
 # `KeyPart.object("first")`
 # `KeyPart.array("second")`
 # `KeyPart.object("third")`
 
 This key can be used to return the value "My Value", from `third` in the following json dictionary:
 
 ```json
 {
    "first": {
        "second": [
            {
                "third": "My Value"
            }
        ]
    }
 }
 ```
 
 Using this key when storing a value in the map will, on the other hand create the above dictionary.
 */
extension String: MapKey {
    private static let arrayPattern = "^([\\w[^\\[\\]]]+)\\[(0)\\]$"
    private static let objectPattern = "^([\\w[^\\[\\]]]+)$"
    
    public func parseKeyParts() throws -> [KeyPart] {
        let partStrings = self.split(separator: ".").map({ String($0) })
        var parts: [KeyPart] = []
        
        for partString in partStrings {
            guard let part = try partString.parseKeyPart() else {
                throw MapDecodingError.invalidKey(key: self)
            }
            
            parts.append(part)
        }
        
        return parts
    }
    
    public var rawValue: String {
        return self
    }
    
    func parseKeyPart() throws -> KeyPart? {
        if let part = try self.parseObjectPart() {
            return part
        } else if let part = try self.parseArrayPart() {
            return part
        } else {
            return nil
        }
    }
    
    private func parseArrayPart() throws -> KeyPart? {
        let result = try self.matches(for: String.arrayPattern)
        
        if let key = result[self]?.first {
            let part = KeyPart.array(key: key)
            return part
        } else {
            return nil
        }
    }
    
    private func parseObjectPart() throws -> KeyPart? {
        let result = try self.matches(for: String.objectPattern)
        
        if let key = result[self]?.first {
            let part = KeyPart.object(key: key)
            return part
        } else {
            return nil
        }
    }
}

extension Array: MapKey where Element: MapKey {
    
    public var rawValue: String {
        return self.map({ $0.rawValue }).joined(separator: ".")
    }
    
    public func parseKeyParts() throws -> [KeyPart] {
        return self as! [KeyPart]
    }
}
