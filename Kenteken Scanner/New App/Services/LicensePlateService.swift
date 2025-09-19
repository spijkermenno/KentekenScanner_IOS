//
//  LicensePlateService.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import Foundation

final class LicensePlateService {
    private let baseURL = "https://pixelwonders.nl/api"

    func fetchLicensePlate(_ plate: String) async throws -> GekentekendeVoertuig {
        let urlString = "\(baseURL)/api-endpoint/\(plate)"
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(GekentekendeVoertuig.self, from: data)
    }
}
