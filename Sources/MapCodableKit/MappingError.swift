//
//  Errors.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-26.
//

import Foundation

public enum MappingError: Error, CustomStringConvertible {
    case valueNotFound(key: String)
    case failedToDecode(key: String)
    case invalidType(key: String)
    
    public var description: String {
        switch self {
        case .failedToDecode(let key)      : return "Mapping failed because value cound not be serialized for `\(key)`"
        case .valueNotFound(let key)    : return "Mapping failed because value cound not be found for `\(key)`"
        case .invalidType(let key)      : return "Mapping failed because type is invalid for `\(key)`"
        }
    }
}
