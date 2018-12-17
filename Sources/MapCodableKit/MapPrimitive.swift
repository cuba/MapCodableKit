//
//  MapPrimitive.swift
//  MapCodable
//
//  Created by Jacob Sikorski on 2018-12-01.
//

import Foundation

/**
 A protocol that represents JSON primatives as well as arrays and dictionaries of map primatives.
 
 WARNING: This protocol should NEVER be used directly as it only adds a form of tagging to primitive variables supported by the `Map` class. All objects in the map are converted to and from a `MapPrimitive` object. Adding this protocol to any other object will result in crashes.
 
 The following objects support `MapPrimitive`:
 * `String`
 * `Double`
 * `Bool`
 * `Int`
 * `Int8`
 * `Int16`
 * `Int32`
 * `Int64`
 * `UInt`
 * `UInt8`
 * `UInt16`
 * `UInt32`
 * `UInt64`
 * `Array` where each Element also conforms to a `MapPrimitive`
 * `Dictionary` where each Value also conforms to a `MapPrimitive`
 */
public protocol MapPrimitive {}

extension String: MapPrimitive {}
extension Double: MapPrimitive {}
extension Bool: MapPrimitive {}
extension Int: MapPrimitive {}
extension Int8: MapPrimitive {}
extension Int16: MapPrimitive {}
extension Int32: MapPrimitive {}
extension Int64: MapPrimitive {}
extension UInt: MapPrimitive {}
extension UInt8: MapPrimitive {}
extension UInt16: MapPrimitive {}
extension UInt32: MapPrimitive {}
extension UInt64: MapPrimitive {}
extension Array: MapPrimitive where Element: MapPrimitive {}
extension Dictionary: MapPrimitive where Value: MapPrimitive {}
