//
//  MapTransform.swift
//  App
//
//  Created by Jacob Sikorski on 2018-11-29.
//

import Foundation

/**
 A protocol that allows you to transform a `MapPrimitive` (JSON) value to another value. This protocol is used to add more type sypport to the `Map` class.
 */
public protocol MapDecoder {
    associatedtype Primitive: MapPrimitive
    associatedtype Object
    
    func fromMap(value: Primitive) throws -> Object?
}

/**
 A protocol that allows you to transform a value into a `MapPrimitive` (JSON) value. This protocol is used to add more type support to the `Map` class.
 */
public protocol MapEncoder {
    associatedtype Primitive: MapPrimitive
    associatedtype Object
    
    func toMap(value: Object) throws -> Primitive?
}

/**
 A protocol combining both `MapEncoder` and `MapDecoder`.
 */
public protocol MapCoder: MapEncoder, MapDecoder {
}
