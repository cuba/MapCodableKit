//
//  MapCodableKitTests.swift
//  MapCodableKitTests
//
//  Created by Jacob Sikorski on 2018-12-02.
//

import XCTest
import MapCodableKit

class MapCodableKitTests: XCTestCase {
    
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
            let id: String = try map.value(from: [KeyPart.object(key: "profile"), KeyPart.object(key: "id")])
            let name: String = try map.value(from: "profile.name")
            
            // Then
            XCTAssertEqual(id, "123")
            XCTAssertEqual(name, "Kevin Malone")
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
