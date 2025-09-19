//
//  AddToRecentsUseCase.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 19/09/2025.
//

struct AddToRecentsUseCase {
    private let storage = StorageHelper()
    
    func callAsFunction(_ plate: String) {
        var items: [String] = storage.retrieveFromLocalStorage(storageType: StorageIdentifier.Recent)
        let normalized = plate.replacingOccurrences(of: "-", with: "").uppercased()
        
        if let idx = items.firstIndex(of: normalized) {
            items.remove(at: idx)
        }
        items.insert(normalized, at: 0)
        
        storage.saveToLocalStorage(arr: items, storageType: StorageIdentifier.Recent)
    }
}
