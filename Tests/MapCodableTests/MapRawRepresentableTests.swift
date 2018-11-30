//
//  MapRawRepresentableTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodable

class MapRawRepresentableTests: XCTestCase {
    enum TestEnum: Int {
        case first = 0
        case second
    }
    
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }
    
    func testGivenMap_WhenAddingRawRepresentable_ReturnsValue() {
        // Given
        let value = TestEnum.first
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: TestEnum = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentable_ReturnsRawValue() {
        // Given
        let value = TestEnum.first
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: Int = try map.value(fromKey: "value")
            XCTAssertEqual(value.rawValue, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentable_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = TestEnum.first
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let _: TestEnum = try map.value(fromKey: "not_value")
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
    
    func testGivenMap_WhenAddingRawRepresentable_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = TestEnum.first
        
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
