//
//  LoadRecentsUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

struct LoadRecentsUseCase {
    private let storage = StorageHelper()
    
    func callAsFunction() -> [String] {
        storage.retrieveFromLocalStorage(storageType: StorageIdentifier.Recent)
    }
}
