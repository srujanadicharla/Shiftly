//
//  Helpers.swift
//  Shiftly
//
//  Created by Srujan Simha Adicharla on 1/25/25.
//

import Foundation

struct CurrencyFormatter {
    static func format() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = .current
        return formatter
    }
    
    static func convertToCurrency(_ dollars: Int) -> String {
        let number = Float(dollars)
        return format().string(for: number) ?? ""
    }
}

