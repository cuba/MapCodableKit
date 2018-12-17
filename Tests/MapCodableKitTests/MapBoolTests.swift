//
//  MapBoolTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

class MapBoolTests: XCTestCase {
    
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }
    
    func testGivenMap_WhenAddingBool_ReturnsValue() {
        // Given
        let value = true
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: Bool = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingBoolArray_ReturnsValue() {
        // Given
        let value = [true, false, true]
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: [Bool] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingBoolDictionary_ReturnsValue() {
        // Given
        let value = ["first": true, "second": false, "third": true]
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: [String: Bool] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingBool_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = true
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let _: Bool = try map.value(fromKey: "not_value")
            XCTFail("Should have failed to map value")
        } catch let error as MapDecodingError {
            switch error {
            case .valueNotFound(let key):
                XCTAssertEqual("not_value", key.rawValue)
            default:
                XCTFail("Invalid MapDecodingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
    
    func testGivenMap_WhenAddingBool_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = true
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let _: String = try map.value(fromKey: KeyPart.object(key: "value"))
            XCTFail("Should have failed to map value")
        } catch let error as MapDecodingError {
            switch error {
            case .unexpectedType(let key):
                XCTAssertEqual("value", key.rawValue)
            default:
                XCTFail("Invalid MapDecodingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
}
