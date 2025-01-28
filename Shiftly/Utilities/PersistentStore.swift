//
//  PersistentStore.swift
//  Shiftly
//
//  Created by Srujan Simha Adicharla on 1/25/25.
//

import Foundation

class PersistentStore {
    static let shared = PersistentStore()
    private let defaults = UserDefaults.standard

    private init() {}

    /// Saves a value to UserDefaults
    /// - Parameters:
    ///   - value: The value to save. Must conform to Codable.
    ///   - key: The key under which the value is stored.
    func save<T: Codable>(_ value: T, forKey key: String) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            defaults.set(data, forKey: key)
        } catch {
            print("Error saving value for key \(key): \(error.localizedDescription)")
        }
    }

    /// Retrieves a value from UserDefaults
    /// - Parameters:
    ///   - type: The type of the value to retrieve.
    ///   - key: The key under which the value is stored.
    /// - Returns: The decoded value, or `nil` if not found or decoding fails.
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(type, from: data)
            return value
        } catch {
            print("Error retrieving value for key \(key): \(error.localizedDescription)")
            return nil
        }
    }

    /// Retrieves all values stored in UserDefaults matching a specific type
    /// - Parameter type: The type of the objects to retrieve.
    /// - Returns: An array of all stored objects of the specified type.
    func retrieveAll<T: Codable>(_ type: T.Type) -> [T] {
        var results = [T]()
        for key in defaults.dictionaryRepresentation().keys {
            if let value: T = retrieve(type, forKey: key) {
                results.append(value)
            }
        }
        return results
    }

    /// Removes a value from UserDefaults
    /// - Parameter key: The key under which the value is stored.
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    /// Clears all data from UserDefaults
    func clearAll() {
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObject(forKey: key)
        }
    }

    /// Checks if a key exists in UserDefaults
    /// - Parameter key: The key to check for existence.
    /// - Returns: `true` if the key exists, otherwise `false`.
    func contains(key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
}

extension PersistentStore {
    func getAllShiftEntries(forMonth date: Date) -> [ShiftEntryItem] {
        // Fetch entries matching the month and year of the given date
        return retrieveAll(ShiftEntryItem.self)
            .filter { $0.date.hasPrefix(date.toMonthYearString()) }
    }

    func removeAllShiftEntries(forMonth date: Date) {
        let savedKeys = getAllKeys()
        let calendar = Calendar.current
        let selectedMonth = calendar.component(.month, from: date)
        let selectedYear = calendar.component(.year, from: date)
        
        for key in savedKeys {
            if let shiftDate = formattedDateToDate(key) {
                let month = calendar.component(.month, from: shiftDate)
                let year = calendar.component(.year, from: shiftDate)
                
                if month == selectedMonth && year == selectedYear {
                    remove(forKey: key)
                }
            }
        }
    }
    
    func formattedDateToDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.date(from: dateString)
    }

    /// Retrieves all keys stored in UserDefaults
    /// - Returns: An array of strings representing all the keys in UserDefaults
    func getAllKeys() -> [String] {
        return defaults.dictionaryRepresentation().keys.map { $0 }
    }
}


extension Date {
    func toMonthYearString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: self)
    }
}
