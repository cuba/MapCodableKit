//
//  MapRawRepresentableTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

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
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let result: TestEnum = try map.value(from: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentable_ReturnsRawValue() {
        // Given
        let value = TestEnum.first
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let result: Int = try map.value(from: "value")
            XCTAssertEqual(value.rawValue, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentableArray_ReturnsValue() {
        // Given
        let value = [TestEnum.first, TestEnum.second, TestEnum.first]
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let result: [TestEnum] = try map.value(from: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentableSet_ReturnsValue() {
        // Given
        let values = [TestEnum.first, TestEnum.second, TestEnum.first]
        let set = Set(values)
        
        do {
            // When
            try map.add(set, for: "value")
            
            // Then
            let result: Set<TestEnum> = try map.value(from: "value")
            XCTAssertEqual(set, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentableDictionary_ReturnsValue() {
        // Given
        let value = ["first": TestEnum.first, "second": TestEnum.second, "third": TestEnum.first]
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let result: [String: TestEnum] = try map.value(from: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentable_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = TestEnum.first
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let _: TestEnum = try map.value(from: "not_value")
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
    
    func testGivenMap_WhenAddingRawRepresentable_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = TestEnum.first
        
        do {
            // When
            try map.add(value, for: "value")
            
            // Then
            let _: String = try map.value(from: "value")
            XCTFail("Should have failed to map value")
        } catch let error as MapDecodingError {
            switch error {
            case .unexpectedType(let key, _, _):
                XCTAssertEqual("value", key.rawValue)
            default:
                XCTFail("Invalid MapDecodingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thown")
        }
    }
}
