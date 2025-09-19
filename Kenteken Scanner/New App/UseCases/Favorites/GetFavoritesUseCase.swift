//
//  GetFavoritesUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

import Foundation

struct GetFavoritesUseCase {
    func execute() -> [String] {
        StorageHelper().retrieveFromLocalStorage(storageType: .Favorite)
    }
}
