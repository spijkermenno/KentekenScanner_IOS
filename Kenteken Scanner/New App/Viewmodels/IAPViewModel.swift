//
//  IAPViewModel.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 18/09/2025.
//

import Foundation
import StoreKit

@MainActor
final class IAPViewModel: ObservableObject {
    @Published var removedAds: Bool
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var products: [SKProduct] = []

    init() {
        removedAds = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.IAP)
    }

    func loadProducts() {
        isLoading = true
        IAPManager.shared.getProducts { result in
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let products):
                    self.products = products
                case .failure(let error):
                    self.errorMessage = "Failed to load products: \(error.localizedDescription)"
                }
            }
        }
    }

    func purchase(_ product: SKProduct) {
        guard IAPManager.shared.canMakePayments() else {
            errorMessage = "In-App Purchases are not allowed on this device."
            return
        }

        isLoading = true
        IAPManager.shared.buy(product: product) { result in
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success:
                    self.completePurchase(for: product)
                case .failure(let error):
                    self.errorMessage = "Purchase failed: \(error.localizedDescription)"
                }
            }
        }
    }

    func restorePurchases() {
        isLoading = true
        IAPManager.shared.restorePurchases { result in
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let restored):
                    if restored {
                        self.removedAds = true
                        StorageHelper().saveToLocalStorage(bool: true, storageType: StorageIdentifier.IAP)
                    } else {
                        self.errorMessage = "There are no previous purchases to restore."
                    }
                case .failure(let error):
                    self.errorMessage = "Restore failed: \(error.localizedDescription)"
                }
            }
        }
    }

    private func completePurchase(for product: SKProduct) {
        if product.productIdentifier.contains("premiumUpgrade") {
            removedAds = true
            StorageHelper().saveToLocalStorage(bool: true, storageType: StorageIdentifier.IAP)
            GoogleAnalyticsHelper().logEvent(eventkey: "boughtPremiumUpgrade", key: "version", value: 1)
        }
    }
}
