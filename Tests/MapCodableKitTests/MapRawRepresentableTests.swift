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
    
    func testGivenMap_WhenAddingRawRepresentableArray_ReturnsValue() {
        // Given
        let value = [TestEnum.first, TestEnum.second, TestEnum.first]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [TestEnum] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentableSet_ReturnsValue() {
        // Given
        let values = [TestEnum.first, TestEnum.second, TestEnum.first]
        let set = Set(values)
        
        // When
        map.add(set, forKey: "value")
        
        // Then
        do {
            let result: Set<TestEnum> = try map.value(fromKey: "value")
            XCTAssertEqual(set, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingRawRepresentableDictionary_ReturnsValue() {
        // Given
        let value = ["first": TestEnum.first, "second": TestEnum.second, "third": TestEnum.first]
        
        // When
        map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [String: TestEnum] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
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
