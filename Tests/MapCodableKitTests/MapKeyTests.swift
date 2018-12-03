//
//  MapKeyTests.swift
//  MapCodableKitTests
//
//  Created by Jacob Sikorski on 2018-12-03.
//

import XCTest
import MapCodableKit

class MapKeyTests: XCTestCase {

    func testGivenValidString_RetunsAllParts() {
        // Given
        let string = "abc.def[]"
        
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
        } catch let error as MappingError {
            switch error {
            case .invalidKey(let key):
                XCTAssertEqual("abc .def[]", key.rawValue)
            default:
                XCTFail("Invalid MappingError type thrown")
            }
        } catch {
            XCTFail("Invalid error thrown")
        }
    }
}
