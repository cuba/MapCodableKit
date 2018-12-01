//
//  MapTransform.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

public protocol MapDecoder {
    associatedtype Primitive
    associatedtype Object
    
    func fromMap(value: Primitive) throws -> Object?
}

public protocol MapEncoder {
    associatedtype Primitive
    associatedtype Object
    
    func toMap(value: Object) throws -> Primitive?
}

public protocol MapCoder: MapEncoder, MapDecoder {
}
