//
//  MapEncodableEncoder.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

class URLCoder: MapCoder {
    
    func toMap(value: URL) -> String? {
        return value.absoluteString
    }
    
    func fromMap(value: String) throws -> URL? {
        return URL(string: value)
    }
}
