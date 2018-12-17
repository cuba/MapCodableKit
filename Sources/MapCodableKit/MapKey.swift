//
//  MapKey.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import Foundation

public protocol MapKey {
    var rawValue: String { get }
    func parseKeyParts() throws -> [KeyPart]
}

public enum KeyPart: MapKey {
    case object(key: String)
    case array(key: String)
    
    public var key: String {
        switch self {
        case .object(let key):
            return key
        case .array(let key):
            return key
        }
    }
    
    public var rawValue: String {
        switch self {
        case .object(let key):
            return key
        case .array(let key):
            return "\(key)[]"
        }
    }
    
    public func parseKeyParts() throws -> [KeyPart] {
        return [self]
    }
}

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
