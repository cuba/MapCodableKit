//
//  MapKey.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import Foundation

public protocol MapKey {
    var parts: [KeyPart] { get }
    var rawValue: String { get }
}

public enum KeyPart {
    case object(key: String)
    
    var rawValue: String {
        switch self {
        case .object(let key): return key
        }
    }
}

extension String: MapKey {
    public var parts: [KeyPart] {
        let parts = self.split(separator: ".")
        return parts.map({ KeyPart.object(key: String($0)) })
    }
    
    public var rawValue: String {
        return self
    }
}
