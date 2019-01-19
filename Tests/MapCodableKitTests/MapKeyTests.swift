//
//  MapKeyTests.swift
//  MapCodableKitTests
//
//  Created by Jacob Sikorski on 2018-12-03.
//

import XCTest
import MapCodableKit

class MapKeyTests: XCTestCase {
    struct TestMapKey: MapKey {
        let parts: [KeyPart]
        
        init(parts: [KeyPart]) {
            self.parts = parts
        }
        
        var rawValue: String {
            let partStrings: [String] = parts.map({ (part: KeyPart) -> String in
                return part.rawValue
            })
            
            return partStrings.joined(separator: ".")
        }
        
        func parseKeyParts() throws -> [KeyPart] {
            return parts
        }
    }

    func testGivenValidString_RetunsAllParts() {
        // Given
        let string = "abc.def[0]"
        
        // When
        do {
            var result = try string.parseKeyParts()
            XCTAssertEqual(result.count, 2)
            
            guard result.count == 2 else {
                XCTFail("Should have 2 results")
                return
            }
            
            switch result[0] {
            case .object(let key):
                XCTAssertEqual(key, "abc")
            default:
                XCTFail("Invalid MapKey type")
            }
            
            switch result[1] {
            case .array(let key):
                XCTAssertEqual(key, "def")
            default:
                XCTFail("Invalid MapKey type")
            }
        } catch {
            XCTFail("Should have parsed parts")
        }
    }
    
    func testGivenInvalidString_RetunsAllParts() {
        // Given
        let string = "abc .def[]"
        
        // When
        do {
            let _ = try string.parseKeyParts()
            XCTFail("Should have failed to parse parts")
        } catch let error as MapDecodingError {
            switch error {
            case .invalidKey(let key):
                XCTAssertEqual("abc .def[]", key.rawValue)
            default:
                XCTFail("Invalid MapDecodingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thrown")
        }
    }
    
    func testGivenValue_SetsNestedKey() {
        // Given
        let id = "123"
        let name = "Kevin Malone"
        let map = Map()
        
        do {
            // When
            try map.add(id, for: "profile.id")
            try map.add(name, for: "profile.name")
            let idResult: String = try map.value(from: "profile.id")
            let nameResult: String = try map.value(from: "profile.name")
            
            // Then
            XCTAssertEqual(id, idResult)
            XCTAssertEqual(name, nameResult)
        } catch {
            XCTFail("Should have succeeded to create JSON")
        }
    }
    
    func testGivenValidJson_GetsNestedArrayKey() {
        // Given
        let jsonString = """
            {
                "profiles": [
                    {
                        "id": "123",
                        "name": "Kevin Malone"
                    }
                ]
            }
        """
        
        do {
            // When
            let map = try Map(jsonString: jsonString)
            let idKey = TestMapKey(parts: [.array(key: "profiles"), .object(key: "id")])
            let id: String = try map.value(from: idKey)
            
            // Then
            XCTAssertEqual(id, "123")
        } catch {
            XCTFail("Should have succeeded to create JSON")
        }
    }
    
    func testGivenValidJson_HasKey_ReturnsTrue() {
        // Given
        let jsonString = """
            {
                "profiles": [
                    {
                        "id": "123",
                        "name": "Kevin Malone"
                    }
                ]
            }
        """
        
        do {
            // When
            let map = try Map(jsonString: jsonString)
            let idKey = TestMapKey(parts: [.array(key: "profiles"), .object(key: "id")])
            let result = try map.has(key: idKey)
            
            // Then
            XCTAssertTrue(result)
        } catch {
            XCTFail("Should have succeeded to create JSON")
        }
    }
    
    func testGivenValidJson_WhenDoesNotHaveKey_ReturnsFalse() {
        // Given
        let jsonString = """
            {
                "profiles": [
                    {
                        "id": "123",
                        "name": "Kevin Malone"
                    }
                ]
            }
        """
        
        do {
            // When
            let map = try Map(jsonString: jsonString)
            
            // Then
            XCTAssertFalse(try map.has(key: "profiles[0].id.invalid"))
            XCTAssertFalse(try map.has(key: "profiles[0].invalid"))
            XCTAssertFalse(try map.has(key: "profiles.id"))
        } catch {
            XCTFail("Should have succeeded to create JSON")
        }
    }
}
