//
//  MapEncodableTests.swift
//  MapCodableTests
//
//  Created by Jacob Sikorski on 2018-11-30.
//

import XCTest
import MapCodableKit

class MapCodableTests: XCTestCase {
    struct MockUser: Codable, MapCodable, Equatable {
        let id: String
        let name: String
        
        init(id: String) {
            self.id = id
            self.name = "Michael Scott"
        }
        
        init(map: Map) throws {
            self.id     = try map.value(fromKey: "id")
            self.name   = try map.value(fromKey: "name")
        }
        
        func fill(map: Map) throws {
            try map.add(id, forKey: "id")
            try map.add(name, forKey: "name")
        }
        
        public static func == (lhs: MockUser, rhs: MockUser) -> Bool {
            return lhs.id == rhs.id && lhs.name == rhs.name
        }
    }
    
    struct GiantCodableTestModel: MapCodable, Equatable {
        let string: String
        let int: Int
        let bool: Bool
        let double: Double
        
        let strings: [String]
        let ints: [Int]
        let bools: [Bool]
        let doubles: [Double]
        
        let stringsDictionary: [String: String]
        
        let codable: MockUser
        let mapCodable: MockUser
        let mapCodables: [MockUser]
        let url: URL
        
        init(id: String) {
            self.string = "Pam Beesly"
            self.int = 8
            self.bool = false
            self.double = 8.9
            
            self.strings = ["Jim Halpert", "Dwight Schrute", "Michael Scott"]
            self.ints = [2, 6, 8]
            self.bools = [true, false, true]
            self.doubles = [2.5, 6.8, 8.9]
            
            self.stringsDictionary = ["name": "Kevin Malone"]
            
            self.codable = MockUser(id: "123")
            self.mapCodable = MockUser(id: "234")
            self.mapCodables = [MockUser(id: "123"), MockUser(id: "234")]
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
            
            codable     = try map.decodable(fromKey: "codable")
            mapCodable  = try map.value(fromKey: "map_codable")
            mapCodables = try map.value(fromKey: "map_codables")
            
            url         = try map.value(fromKey: "url", using: URLCoder())
        }
        
        func fill(map: Map) throws {
            try map.add(string, forKey: "string")
            try map.add(int, forKey: "int")
            try map.add(bool, forKey: "bool")
            try map.add(double, forKey: "double")
            
            try map.add(strings, forKey: "strings")
            try map.add(ints, forKey: "ints")
            try map.add(bools, forKey: "bools")
            try map.add(doubles, forKey: "doubles")
            
            try map.add(stringsDictionary, forKey: "strings_dictionary")
            
            try map.add(encodable: codable, forKey: "codable")
            try map.add(mapCodable, forKey: "map_codable")
            try map.add(mapCodables, forKey: "map_codables")
            try map.add(url, forKey: "url", using: URLCoder())
        }
        
        public static func == (lhs: GiantCodableTestModel, rhs: GiantCodableTestModel) -> Bool {
            return lhs.string == rhs.string
                && lhs.int == rhs.int
                && lhs.bool == rhs.bool
                && lhs.double == rhs.double
                && lhs.strings == rhs.strings
                && lhs.ints == rhs.ints
                && lhs.bools == rhs.bools
                && lhs.doubles == rhs.doubles
                && lhs.stringsDictionary == rhs.stringsDictionary
                && lhs.codable == rhs.codable
                && lhs.mapCodable == rhs.mapCodable
                && lhs.mapCodables == rhs.mapCodables
        }
    }
    
    var map = Map()
    
    override func setUp() {
        self.map = Map()
    }
    
    func testGivenMap_WhenAddingMapCodable_ReturnsValue() {
        // Given
        let value = MockUser(id: "123")
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let result: MockUser = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingMapCodableArray_ReturnsValue() {
        // Given
        let value = [MockUser(id: "123"), MockUser(id: "234")]
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [MockUser] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingMapCodableDictionary_ReturnsValue() {
        // Given
        let value = ["first": MockUser(id: "123"), "second": MockUser(id: "234")]
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let result: [String: MockUser] = try map.value(fromKey: "value")
            XCTAssertEqual(value, result)
        } catch {
            XCTFail("Did not get value for the correct key")
        }
    }
    
    func testGivenMap_WhenAddingMapCodable_ThrowsCorrectErrorWhenKeyIsWrong() {
        // Given
        let value = MockUser(id: "123")
        
        // When
        try! map.add(value, forKey: "value")
        
        // Then
        do {
            let _: MockUser = try map.value(fromKey: "not_value")
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
    
    func testGivenMap_WhenAddingMapCodable_ThrowsCorrectErrorWhenTypeWrong() {
        // Given
        let value = MockUser(id: "123")
        
        do {
            // When
            try map.add(value, forKey: "value")
            
            // Then
            let _: String = try map.value(fromKey: "value")
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
    
    func testGivenModel_SerializesToJSON() {
        // Given
        let testModel = GiantCodableTestModel(id: "123")
        
        do {
            // When
            guard let jsonString = try testModel.jsonString(options: [.prettyPrinted], encoding: .utf8) else {
                XCTFail("Should have succeeded to create json")
                return
            }
            
            // Then
            let result = try GiantCodableTestModel(jsonString: jsonString, encoding: .utf8)
            XCTAssertEqual(testModel, result)
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
    
    func testGivenModel_DeserializesJSON() {
        // Given
        let jsonString = """
            {
                "id": "123",
                "name": "Jim Halpert",
            }
        """
        
        do {
            // When
            let object = try MockUser(jsonString: jsonString, encoding: .utf8)
            
            // Then
            XCTAssertEqual(object.id, "123")
            XCTAssertEqual(object.name, "Jim Halpert")
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
    
    func testGivenValidJsonArray_GetsNestedObjects() {
        // Given
        let jsonString = """
            [
                {
                    "id": "123",
                    "name": "Kevin Malone"
                }
            ]
        """
        
        do {
            // When
            let profiles = try MockUser.parseArray(jsonString: jsonString, encoding: .utf8, failOnError: true)
            
            // Then
            XCTAssertEqual(profiles.count, 1)
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
}
