//
//  ValidateLicensePlateUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

struct ValidateLicensePlateUseCase {
    private let formatLicensePlate: FormatLicensePlateUseCase
    private let getSideCode: GetSideCodeUseCase

    init(
        formatLicensePlate: FormatLicensePlateUseCase = .init(),
        getSideCode: GetSideCodeUseCase = .init()
    ) {
        self.formatLicensePlate = formatLicensePlate
        self.getSideCode = getSideCode
    }

    func execute(_ plate: String) throws -> String {
        let formatted = formatLicensePlate(plate)
        let upper = formatted.uppercased()
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")

        guard getSideCode(upper) != -2 else {
            throw ValidationError.invalidLicensePlate
        }

        return formatted
    }

    enum ValidationError: Error {
        case invalidLicensePlate
    }
}
