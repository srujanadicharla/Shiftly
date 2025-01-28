//
//  Item.swift
//  Shiftly
//
//  Created by Srujan Simha Adicharla on 1/24/25.
//

import Foundation

struct ShiftEntryItem: Codable {
    let date: String
    let startHour: Int
    let startMinute: Int
    let startPeriod: String
    let endHour: Int
    let endMinute: Int
    let endPeriod: String
    let hoursWorked: Int
}
