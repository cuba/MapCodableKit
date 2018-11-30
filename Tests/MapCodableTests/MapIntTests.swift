//
//  MapIntTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodable

class MapIntTests: XCTestCase {

    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }

    func testGivenMap_WhenAddingInt_ReturnsValue() {
        // Given
        let value = 1
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: Int = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingInt_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = 1
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: Int = try map.value(fromKey: "not_value")
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
    
    func testGivenMap_WhenAddingInt_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = 1
        
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
