//
//  MapTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

class MapStringTests: XCTestCase {
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }

    func testGivenMap_WhenAddingString_ReturnsValue() {
        // Given
        let value = "Pam Beesly"
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: String = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingStringArray_ReturnsValue() {
        // Given
        let value = ["Jim Halpert", "Dwight Schrute", "Micheal Scott"]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [String] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingBoolDictionary_ReturnsValue() {
        // Given
        let value = ["first": "Jim Halpert", "second": "Dwight Schrute", "third": "Michael Scott"]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [String: String] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingString_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = "Some String"
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: String = try map.value(fromKey: "not_value")
            XCTFail("Should have failed to map value")
        } catch let error as MappingError {
            switch error {
            case .valueNotFound(let key):
                XCTAssertEqual("not_value", key)
            default:
                XCTFail("Invalid MappingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
    
    func testGivenMap_WhenAddingString_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = "Some String"
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: Int = try map.value(fromKey: "value")
            XCTFail("Should have failed to map value")
        } catch let error as MappingError {
            switch error {
            case .invalidType(let key):
                XCTAssertEqual("value", key)
            default:
                XCTFail("Invalid MappingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
}
