//
//  MapCodableKitTests.swift
//  MapCodableKitTests
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import XCTest
import MapCodableKit

class MapCodableKitTests: XCTestCase {
    
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
    
    func testGivenValidJson_GetsNestedObject() {
        // Given
        let jsonString = """
            {
                "profile": {
                    "id": "123",
                    "name": "Kevin Malone"
                }
            }
        """
        
        do {
            // When
            let map = try Map(jsonString: jsonString)
            let id: String = try map.value(fromKey: "profile.id")
            let name: String = try map.value(fromKey: "profile.name")
            
            // Then
            XCTAssertEqual(id, "123")
            XCTAssertEqual(name, "Kevin Malone")
        } catch {
            XCTFail("Should have succeeded to create json")
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
            let id: String = try map.value(fromKey: idKey)
            
            // Then
            XCTAssertEqual(id, "123")
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
    
    func testGivenValue_SetsNestedKey() {
        // Given
        let id = "123"
        let name = "Kevin Malone"
        let map = Map()
        
        do {
            // When
            try map.add(id, forKey: "profile.id")
            try map.add(name, forKey: "profile.name")
            let idResult: String = try map.value(fromKey: "profile.id")
            let nameResult: String = try map.value(fromKey: "profile.name")
            
            // Then
            XCTAssertEqual(id, idResult)
            XCTAssertEqual(name, nameResult)
        } catch {
            XCTFail("Should have succeeded to create json")
        }
    }
    
    func testGivenInvalidJson_GetsNestedKey() {
        // Given
        let jsonString = """
            {
                "profile": {
                    "id": "123",
                    name": "Kevin Malone"
                }
            }
        """
        
        do {
            // When
            let _ = try Map(jsonString: jsonString)
            XCTFail("Should have failed to map json")
        } catch {
            // Success
        }
    }
}
