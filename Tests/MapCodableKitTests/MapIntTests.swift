//
//  MapIntTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

class MapIntTests: XCTestCase {

    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }

    func testGivenMap_WhenAddingInt_ReturnsValue() {
        // Given
        let value = 1
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: Int = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingIntArray_ReturnsValue() {
        // Given
        let value = [1, 4, -10]
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: [Int] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingIntDictionary_ReturnsValue() {
        // Given
        let value = ["first": 1, "second": 4, "third": -10]
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let result: [String: Int] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingInt_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = 1
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let _: Int = try map.value(fromKey: "not_value")
            XCTFail("Should have failed to map value")
        } catch let error as MappingError {
            switch error {
            case .valueNotFound(let key):
                XCTAssertEqual("not_value", key.rawValue)
            default:
                XCTFail("Invalid MappingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
    
    func testGivenMap_WhenAddingInt_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = 1
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let _: String = try map.value(fromKey: "value")
            XCTFail("Should have failed to map value")
        } catch let error as MappingError {
            switch error {
            case .invalidType(let key):
                XCTAssertEqual("value", key.rawValue)
            default:
                XCTFail("Invalid MappingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
}
