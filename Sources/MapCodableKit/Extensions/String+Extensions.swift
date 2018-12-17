//
//  String+Extensions.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-03.
//

import Foundation

extension String {
    func matches(for regex: String, options: NSRegularExpression.MatchingOptions = []) throws -> [String: [String]] {
        let range = NSRange(self.startIndex..., in: self)
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: self, options: options, range: range)
        var finalResult: [String: [String]] = [:]
        
        for result in results {
            guard result.numberOfRanges > 0 else { return [:] }
            guard let key = substring(in: result.range(at: 0)) else { return [:] }
            var values: [String] = []
            
            for index in 1..<result.numberOfRanges {
                guard let value = substring(in: result.range(at: index)) else { continue }
                values.append(value)
            }
        
            finalResult[key] = values
        }
        
        return finalResult
    }
    
    func substring(in nsRange: NSRange) -> String? {
        guard let range = Range(nsRange, in: self) else { return nil }
        return substring(in: range)
    }
    
    func substring(in range: Range<String.Index>) -> String? {
        let text = self[range]
        return String(text)
    }
}

// MARK: MapKey Strings

/**
 Adds MapKey support to a `String`. The string will be parsed into a MapKey by pulling out all key parts in the string. Key parts are seperated using `.`.
 
 For example, the string `first.second[].third` will be converted to the following key parts:
 1 `KeyPart.object("first")`
 2 `KeyPart.array("second")`
 3 `KeyPart.object("third")`
 
 This key can be used to return the value "My Value", from `third` in the following JSON dictionary:
 
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
    
    /**
     Parses the string into key parts seperated by a `.`. Throws an error if the string is badly formatted.
     */
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
    
    /**
     Returns itself.
     */
    public var rawValue: String {
        return self
    }
    
    /**
     Parses the string into a single KeyPart. Throws an error if the string is badly formatted. It assumes you already split the string up by its key delimiter (`.`).
     */
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
