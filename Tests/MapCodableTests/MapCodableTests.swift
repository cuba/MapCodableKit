//
//  MapEncodableTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodable

class MapCodableTests: XCTestCase {
    struct TestCodable: Codable, MapCodable, Equatable {
        let string: String
        
        init() {
            self.string = "Michael Scott"
        }
        
        init(map: Map) throws {
            self.string = try map.value(fromKey: "string")
        }
        
        func fill(map: Map) {
            map.add(string, forKey: "string")
        }
        
        public static func == (lhs: TestCodable, rhs: TestCodable) -> Bool {
            return lhs.string == rhs.string
        }
    }
    
    struct TestMapCodable: MapCodable, Equatable {
        let string: String
        let int: Int
        let bool: Bool
        let double: Double
        let strings: [String]
        let ints: [Int]
        let bools: [Bool]
        let doubles: [Double]
        let codable: TestCodable
        let mapCodable: TestCodable
        
        init() {
            self.string = "Pam Beesly"
            self.int = 8
            self.bool = false
            self.double = 8.9
            
            self.strings = ["Jim Halpert", "Dwight Schrute", "Michael Scott"]
            self.ints = [2, 6, 8]
            self.bools = [true, false, true]
            self.doubles = [2.5, 6.8, 8.9]
            
            self.codable = TestCodable()
            self.mapCodable = TestCodable()
        }
        
        init(map: Map) throws {
            string      = try map.value(fromKey: "string")
            int         = try map.value(fromKey: "int")
            bool        = try map.value(fromKey: "bool")
            double      = try map.value(fromKey: "double")
            
            strings     = try map.value(fromKey: "strings")
            ints        = try map.value(fromKey: "ints")
            bools       = try map.value(fromKey: "bools")
            doubles     = try map.value(fromKey: "doubles")
            
            mapCodable  = try map.value(fromKey: "map_codable")
            codable     = try map.decodable(fromKey: "codable")
        }
        
        func fill(map: Map) throws {
            map.add(string, forKey: "string")
            map.add(int, forKey: "int")
            map.add(bool, forKey: "bool")
            map.add(double, forKey: "double")
            
            map.add(strings, forKey: "strings")
            map.add(ints, forKey: "ints")
            map.add(bools, forKey: "bools")
            map.add(doubles, forKey: "doubles")
            
            try map.add(mapCodable, forKey: "map_codable")
            try map.add(encodable: codable, forKey: "codable")
        }
        
        public static func == (lhs: TestMapCodable, rhs: TestMapCodable) -> Bool {
            return lhs.string == rhs.string && lhs.int == rhs.int && lhs.bool == rhs.bool && lhs.double == rhs.double && lhs.mapCodable == rhs.mapCodable && lhs.codable == rhs.codable
        }
    }
    
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }
    
    func testGivenMap_WhenAddingMapCodable_ReturnsValue() {
        // Given
        let value = TestMapCodable()
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let result: TestMapCodable = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingMapCodable_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = TestMapCodable()
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let _: TestMapCodable = try map.value(fromKey: "not_value")
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
    
    func testGivenMap_WhenAddingMapCodable_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = TestMapCodable()
        
        // When
        try! map.add(value, forKey: "value")
        
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
