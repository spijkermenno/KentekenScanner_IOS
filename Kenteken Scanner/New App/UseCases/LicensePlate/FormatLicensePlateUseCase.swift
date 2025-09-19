//
//  FormatLicensePlateUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

struct FormatLicensePlateUseCase {
    private let getSideCode = GetSideCodeUseCase()
    
    func callAsFunction(_ plate: String) -> String {
        let sidecode = getSideCode(plate)
        var fixed = plate.uppercased().replacingOccurrences(of: "-", with: "")
        
        if sidecode == -2 { return fixed }
        
        let c = Array(fixed)
        if sidecode <= 6 { return String(c[0..<2]) + "-" + String(c[2..<4]) + "-" + String(c[4..<6]) }
        if sidecode == 7 || sidecode == 9 { return String(c[0..<2]) + "-" + String(c[2..<5]) + "-" + String(c[5..<6]) }
        if sidecode == 8 || sidecode == 10 { return String(c[0..<1]) + "-" + String(c[1..<4]) + "-" + String(c[4..<6]) }
        if sidecode == 11 || sidecode == 14 { return String(c[0..<3]) + "-" + String(c[3..<5]) + "-" + String(c[5..<6]) }
        if sidecode == 12 || sidecode == 13 { return String(c[0..<1]) + "-" + String(c[1..<3]) + "-" + String(c[3..<6]) }
        return fixed
    }
}
