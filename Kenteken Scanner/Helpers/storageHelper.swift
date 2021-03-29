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
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func saveToLocalStorage(arr: [String], storageType: StorageIdentifier) {
        if storageType == StorageIdentifier.Favorite {
            defaults.set(arr, forKey: favoriteStorageIdentifier)
        } else if storageType == StorageIdentifier.Recent {
            defaults.set(arr, forKey: recentStorageIdentifier)
        }
    }
    
    func saveToLocalStorage(arr: [NotificationObject], storageType: StorageIdentifier) {
        print(arr)
        print(storageType)
        if storageType == StorageIdentifier.Alert {
            defaults.set(try? PropertyListEncoder().encode(arr), forKey: alertStorageIdentifier)
        }
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
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> [NotificationObject] {
        if let alerts = defaults.object(forKey: alertStorageIdentifier) as? Data {
            let d = try? PropertyListDecoder().decode(Array<NotificationObject>.self, from: alerts)
            return d!
        }
        
        return []
    }
}
