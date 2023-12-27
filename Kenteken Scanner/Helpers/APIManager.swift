//
//  NetworkRequestHelperV2.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation

class APIManager {
    private let apiBaseUrl = "https://pixelwonders.nl/api"
    
    func getGekentekendeVoertuig(kenteken: String, completion: @escaping (Result<GekentekendeVoertuig, Error>) -> Void) {
        let apiUrl = "\(apiBaseUrl)/api-endpoint/\(kenteken)"

        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            print(apiUrl)

            do {
                let decoder = JSONDecoder()
                let gekentekendeVoertuig = try decoder.decode(GekentekendeVoertuig.self, from: data)
                completion(.success(gekentekendeVoertuig))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
