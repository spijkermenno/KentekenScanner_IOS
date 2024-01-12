//
//  NetworkRequestHelperV2.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation

class APIManager {
    private let apiBaseUrl = "https://pixelwonders.nl/api"
    private var inAppPurchaseViewModel: InAppPurchaseViewModel
    private var viewController: ViewController
    
    init (viewController: ViewController) {
        self.viewController = viewController
        self.inAppPurchaseViewModel = viewController.viewModel
    }
    
    private func checkAds() -> Bool {
        if inAppPurchaseViewModel.removedAds {
            return true
        }
        
        var requestCount: Int = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.CountRequests)
        var requestsDone: Int = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.RequestsDone)
        
        if requestCount > 20 {
            requestCount = 1
            
            // show alert
        } else {
            requestCount += 1
        }
        
        requestsDone += 1
                
        if requestsDone == 0 {
            requestsDone = 1
        } else if requestsDone >= 10 {
            requestsDone = 1
            
            // show interstitial
            
            self.viewController.showInterstitial()
            
            StorageHelper().saveToLocalStorage(amount: requestsDone, storageType: StorageIdentifier.RequestsDone)
            StorageHelper().saveToLocalStorage(amount: requestCount, storageType: StorageIdentifier.CountRequests)
            
            return false
        }
        
        StorageHelper().saveToLocalStorage(amount: requestsDone, storageType: StorageIdentifier.RequestsDone)
        StorageHelper().saveToLocalStorage(amount: requestCount, storageType: StorageIdentifier.CountRequests)
        
        return true
    }
        
    private func addToRecents(kenteken: String) {
        var recents: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent);
        
        if recents.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()) {
            recents.remove(at: recents.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())!)
        }
        
        recents.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
        
        StorageHelper().saveToLocalStorage(arr: recents, storageType: StorageIdentifier.Recent)
    }
    
    func getGekentekendeVoertuig(kenteken: String, completion: @escaping (Result<GekentekendeVoertuig, Error>) -> Void) {
        viewController.actualKenteken = kenteken
        
        if !checkAds() {
            return
        }
        
        let apiUrl = "\(apiBaseUrl)/api-endpoint/\(kenteken)"

        guard let url = URL(string: apiUrl) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        AnalyticsManager.shared.trackEvent(
            eventName: .licensePlateSearch,
            parameters: ["PlateNumber": kenteken]
        )

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
                self.addToRecents(kenteken: kenteken)
                completion(.success(gekentekendeVoertuig))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
