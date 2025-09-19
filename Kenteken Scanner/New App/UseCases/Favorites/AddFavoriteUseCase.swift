//
//  AddFavoriteUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

struct AddFavoriteUseCase {
    func execute(licensePlate: String) {
        var favorites: [String] = StorageHelper().retrieveFromLocalStorage(storageType: .Favorite)

        let cleaned = licensePlate.replacingOccurrences(of: "-", with: "").uppercased()

        if !favorites.contains(cleaned) {
            favorites.insert(cleaned, at: 0)
            StorageHelper().saveToLocalStorage(arr: favorites, storageType: .Favorite)
        }
    }
}   
