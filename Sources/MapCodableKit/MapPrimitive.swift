//
//  MapPrimitive.swift
//  MapCodable
//
//  Created by Jacob Sikorski on 2018-12-01.
//

import Foundation

public protocol MapPrimitive {}

extension String: MapPrimitive {}
extension Double: MapPrimitive {}
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
extension Bool: MapPrimitive {}
extension Array: MapPrimitive where Element: MapPrimitive {}
extension Dictionary: MapPrimitive where Value: MapPrimitive {}
