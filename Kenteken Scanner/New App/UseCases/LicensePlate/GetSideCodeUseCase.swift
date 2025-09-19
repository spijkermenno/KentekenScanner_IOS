//
//  GetSideCodeUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

struct GetSideCodeUseCase {
    func callAsFunction(_ plate: String) -> Int {
        let cleaned = plate.replacingOccurrences(of: "-", with: "")
        let patterns: [Int: String] = [
            0:"^[A-Z]{2}[0-9]{2}[0-9]{2}$",
            1:"^[0-9]{2}[0-9]{2}[A-Z]{2}$",
            2:"^[0-9]{2}[A-Z]{2}[0-9]{2}$",
            3:"^[A-Z]{2}[0-9]{2}[A-Z]{2}$",
            4:"^[A-Z]{2}[A-Z]{2}[0-9]{2}$",
            5:"^[0-9]{2}[A-Z]{2}[A-Z]{2}$",
            6:"^[0-9]{2}[A-Z]{3}[0-9]{1}$",
            7:"^[0-9]{1}[A-Z]{3}[0-9]{2}$",
            8:"^[A-Z]{2}[0-9]{3}[A-Z]{1}$",
            9:"^[A-Z]{1}[0-9]{3}[A-Z]{2}$",
            10:"^[A-Z]{3}[0-9]{2}[A-Z]{1}$",
            11:"^[A-Z]{1}[0-9]{2}[A-Z]{3}$",
            12:"^[0-9]{1}[A-Z]{2}[0-9]{3}$",
            13:"^[0-9]{3}[A-Z]{2}[0-9]{1}$"
        ]
        let range = NSRange(location: 0, length: cleaned.utf16.count)
        for (key, pat) in patterns {
            let regex = try! NSRegularExpression(pattern: pat)
            if regex.firstMatch(in: cleaned, options: [], range: range) != nil { return key + 1 }
        }
        return -2
    }
}
