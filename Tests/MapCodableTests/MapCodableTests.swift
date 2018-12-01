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
        
        let stringsDictionary: [String: String]
        
        let codable: TestCodable
        let mapCodable: TestCodable
        let url: URL
        
        init() {
            self.string = "Pam Beesly"
            self.int = 8
            self.bool = false
            self.double = 8.9
            
            self.strings = ["Jim Halpert", "Dwight Schrute", "Michael Scott"]
            self.ints = [2, 6, 8]
            self.bools = [true, false, true]
            self.doubles = [2.5, 6.8, 8.9]
            
            self.stringsDictionary = ["name": "Kevin Malone"]
            
            self.codable = TestCodable()
            self.mapCodable = TestCodable()
            self.url = URL(string: "https://example.com")!
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
            
            stringsDictionary     = try map.value(fromKey: "strings_dictionary")
            
            mapCodable  = try map.value(fromKey: "map_codable")
            codable     = try map.decodable(fromKey: "codable")
            url         = try map.value(fromKey: "url", using: URLCoder())
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
            
            map.add(stringsDictionary, forKey: "strings_dictionary")
            
            try map.add(mapCodable, forKey: "map_codable")
            try map.add(encodable: codable, forKey: "codable")
            try map.add(url, forKey: "url", using: URLCoder())
        }
        
        public static func == (lhs: TestMapCodable, rhs: TestMapCodable) -> Bool {
            return lhs.string == rhs.string
                && lhs.int == rhs.int
                && lhs.bool == rhs.bool
                && lhs.double == rhs.double
                && lhs.strings == rhs.strings
                && lhs.ints == rhs.ints
                && lhs.bools == rhs.bools
                && lhs.doubles == rhs.doubles
                && lhs.mapCodable == rhs.mapCodable
                && lhs.stringsDictionary == rhs.stringsDictionary
                && lhs.codable == rhs.codable
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
    
    func testGivenMap_WhenAddingMapCodable_SerializesAndDeserializesJSON() {
        // Given
        let value = TestMapCodable()
        
        // When
        try! map.add(value, forKey: "contents")
        
        // Then
        do {
            guard let jsonString = try map.jsonString(options: [.prettyPrinted]) else {
                XCTFail("Should have succeeded to create json")
                return
            }
            
            let newMap = try Map(jsonString: jsonString)
            let result: TestMapCodable = try newMap.value(fromKey: "contents")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
}
