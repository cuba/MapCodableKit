//
//  MapDoubleTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

class MapDoubleTests: XCTestCase {
    
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }
    
    func testGivenMap_WhenAddingDouble_ReturnsValue() {
        // Given
        let value = 1.0
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: Double = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingDoubleArray_ReturnsValue() {
        // Given
        let value = [1.2, 3.6, 6.8]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [Double] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingDoubleDictionary_ReturnsValue() {
        // Given
        let value = ["first": 1.2, "second": 3.6, "third": 6.8]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [String: Double] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingDouble_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = 1.0
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: Double = try map.value(fromKey: "not_value")
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
    
    func testGivenMap_WhenAddingDouble_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = 1.0
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: String = try map.value(fromKey: "value")
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
