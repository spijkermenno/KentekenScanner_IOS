//
//  storageHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation

class StorageHelper {
    let defaults = UserDefaults.standard

    let favoriteStorageIdentifier: String = "Favorite"
    let recentStorageIdentifier: String = "Recent"
    let alertStorageIdentifier: String = "Alert"
    let CountRequestsStorageIdentifier: String = "Count"
    let RequestsDoneStorageIdentifier: String = "Done"
    let IAPStorageIdentifier: String = "IAP"
    let ShowAdStorageIdentifier: String = "ShowAd"

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func saveToLocalStorage(bool: Bool, storageType: StorageIdentifier) {
        if storageType == StorageIdentifier.IAP {
            defaults.set(bool, forKey: IAPStorageIdentifier)
        }
        
        if storageType == StorageIdentifier.ShowInter {
            defaults.set(bool, forKey: ShowAdStorageIdentifier)
        }
    }
    
    func saveToLocalStorage(arr: [String], storageType: StorageIdentifier) {
        if storageType == StorageIdentifier.Favorite {
            defaults.set(arr, forKey: favoriteStorageIdentifier)
        } else if storageType == StorageIdentifier.Recent {
            defaults.set(arr, forKey: recentStorageIdentifier)
        }
    }
    
    func saveToLocalStorage(amount: Int, storageType: StorageIdentifier) {
        if storageType == StorageIdentifier.CountRequests {
            defaults.set(amount, forKey: CountRequestsStorageIdentifier)
        } else if storageType == StorageIdentifier.RequestsDone {
            defaults.set(amount, forKey: RequestsDoneStorageIdentifier)
        }
        defaults.set(amount, forKey: CountRequestsStorageIdentifier)
    }
    
    func saveToLocalStorage(arr: [NotificationObject], storageType: StorageIdentifier) {
        if storageType == StorageIdentifier.Alert {
            defaults.set(try? PropertyListEncoder().encode(arr), forKey: alertStorageIdentifier)
        }
    }
    
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> Bool {
        if storageType == StorageIdentifier.IAP {
            if let result = defaults.object(forKey: IAPStorageIdentifier) as? Bool {
                return result
            }
        }
        
        if storageType == StorageIdentifier.ShowInter {
            if let result = defaults.object(forKey: ShowAdStorageIdentifier) as? Bool {
                return result
            }
        }
        return false
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> [String] {
        if storageType == StorageIdentifier.Favorite {
            if let result = defaults.object(forKey: favoriteStorageIdentifier) as? [String] {
                return result
            }
        } else if storageType == StorageIdentifier.Recent {
            if let result = defaults.object(forKey: recentStorageIdentifier) as? [String] {
                return result
            }
        }
        return []
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> Int {
        if storageType == StorageIdentifier.CountRequests {
            if let result = defaults.object(forKey: CountRequestsStorageIdentifier) as? Int {
                return result
            }
        } else if storageType == StorageIdentifier.RequestsDone {
            if let result = defaults.object(forKey: RequestsDoneStorageIdentifier) as? Int {
                return result
            }
        }
        
        
        return 0
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> [NotificationObject] {
        if let alerts = defaults.object(forKey: alertStorageIdentifier) as? Data {
            let d = try? PropertyListDecoder().decode(Array<NotificationObject>.self, from: alerts)
            return d!
        }
        
        return []
    }
}
