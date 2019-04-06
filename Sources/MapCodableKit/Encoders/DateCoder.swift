//
//  DateCoder.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2019-02-03.
//

import Foundation

public extension DateFormatter {
    static let rfc3339: DateFormatter = {
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter
    }()
    
    static let rfc3339WithTimeFragments: DateFormatter = {
        let rfc3339DateFormatter = DateFormatter()
        rfc3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        rfc3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        rfc3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return rfc3339DateFormatter
    }()
}

public enum DateFormat {
    case rfc3339
    case rfc3339WithTimeFragments
    
    var formatter: DateFormatter {
        switch self {
        case .rfc3339:
            return DateFormatter.rfc3339
        case .rfc3339WithTimeFragments:
            return DateFormatter.rfc3339WithTimeFragments
        }
    }
}


/// Encodes and decodes RFC3339 strings.
open class DateCoder: MapCoder {
    public let format: DateFormat
    
    public init(_ format: DateFormat) {
        self.format = format
    }
    
    /// Converts a Date object to an RFC3339 encoded string.
    ///
    /// - Parameter value: the date that will be encoded
    /// - Returns: the RFC3339 encoded string
    open func toMap(value: Date) -> String? {
        return format.formatter.string(from: value)
    }
    
    /// Converts an RFC3339 encoded string to a Date object.
    ///
    /// - Parameter value: RCF3339 encoded date string
    /// - Returns: A URL that is parsed from the RFC3339 string.
    /// - Throws: does not throw anything. This is just a conformance to the protocol
    open func fromMap(value: String) throws -> Date? {
        return format.formatter.date(from: value)
    }
}
