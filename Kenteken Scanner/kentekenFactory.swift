//
//  kentekenFactory.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation

class KentekenFactory {
    func format(_ kenteken: String) -> String {
        let sidecode = getSidecode(kenteken);
        
        var fixedkenteken = kenteken.uppercased()
        fixedkenteken = fixedkenteken.replacingOccurrences(of: "-", with: "")
        
        // Not a valid kenteken
        if (sidecode == -2) {
            return fixedkenteken;
        }
        
        let kenteken = Array(fixedkenteken);
        
        if (sidecode <= 6) {
            return String(kenteken[0..<2]) + "-" + String(kenteken[2..<4]) + "-" + String(kenteken[4..<6])
        }
        
        if (sidecode == 7 || sidecode == 9) {
            return String(kenteken[0..<2]) + "-" + String(kenteken[2..<5]) + "-" + String(kenteken[5..<6])
        }
        
        if (sidecode == 8 || sidecode == 10) {
            return String(kenteken[0..<1]) + "-" + String(kenteken[1..<4]) + "-" + String(kenteken[4..<6])
        }
        
        if (sidecode == 11 || sidecode == 14) {
            return String(kenteken[0..<3]) + "-" + String(kenteken[3..<5]) + "-" + String(kenteken[5..<6])
        }
        
        if (sidecode == 12 || sidecode == 13) {
            return String(kenteken[0..<1]) + "-" + String(kenteken[1..<3]) + "-" + String(kenteken[3..<6])
        }
        
        return fixedkenteken
    }
    
    func getSidecode(_ kenteken: String) -> Int {
        let kenteken = kenteken.replacingOccurrences(of: "-", with: "")
        
        let patterns: [Int: String] = [
            0: "^[a-zA-Z]{2}[0-9]{2}[0-9]{2}$", // 1 XX-99-99
            1: "^[0-9]{2}[0-9]{2}[a-zA-Z]{2}$", // 2 99-99-XX
            2: "^[0-9]{2}[a-zA-Z]{2}[0-9]{2}$", // 3 99-XX-99
            3: "^[a-zA-Z]{2}[0-9]{2}[a-zA-Z]{2}$", // 4 XX-99-XX
            4: "^[a-zA-Z]{2}[a-zA-Z]{2}[0-9]{2}$", // 5 XX-XX-99
            5: "^[0-9]{2}[a-zA-Z]{2}[a-zA-Z]{2}$", // 6 99-XX-XX
            6: "^[0-9]{2}[a-zA-Z]{3}[0-9]{1}$", // 7 99-XXX-9
            7: "^[0-9]{1}[a-zA-Z]{3}[0-9]{2}$", // 8 9-XXX-99
            8: "^[a-zA-Z]{2}[0-9]{3}[a-zA-Z]{1}$", // 9 XX-999-X
            9: "^[a-zA-Z]{1}[0-9]{3}[a-zA-Z]{2}$", // 10 X-999-XX
            10: "^[a-zA-Z]{3}[0-9]{2}[a-zA-Z]{1}$", // 11 XXX-99-X
            11: "^[a-zA-Z]{1}[0-9]{2}[a-zA-Z]{3}$", // 12 X-99-XXX
            12: "^[0-9]{1}[a-zA-Z]{2}[0-9]{3}$", // 13 9-XX-999
            13: "^[0-9]{3}[a-zA-Z]{2}[0-9]{1}$" // 14 999-XX-9
        ]
        
        let range = NSRange(location: 0, length: kenteken.utf16.count)
        
        for (key, regpattern) in patterns {
            let regex = try! NSRegularExpression(pattern: regpattern)
            if (regex.firstMatch(in: kenteken, options: [], range: range) != nil) {
                return key + 1
            }
        }
        
        return -2;
    }
    
}
