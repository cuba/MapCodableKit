//
//  String+Extensions.swift
//  MapCodableKit
//
//  Created by Jacob Sikorski on 2018-12-03.
//

import Foundation

extension String {
    func matches(for regex: String, options: NSRegularExpression.MatchingOptions = []) throws -> [String: [String]] {
        let range = NSRange(self.startIndex..., in: self)
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: self, options: options, range: range)
        var finalResult: [String: [String]] = [:]
        
        for result in results {
            guard result.numberOfRanges > 0 else { return [:] }
            guard let key = substring(in: result.range(at: 0)) else { return [:] }
            var values: [String] = []
            
            for index in 1..<result.numberOfRanges {
                guard let value = substring(in: result.range(at: index)) else { continue }
                values.append(value)
            }
        
            finalResult[key] = values
        }
        
        return finalResult
    }
    
    func substring(in nsRange: NSRange) -> String? {
        guard let range = Range(nsRange, in: self) else { return nil }
        return substring(in: range)
    }
    
    func substring(in range: Range<String.Index>) -> String? {
        let text = self[range]
        return String(text)
    }
}
