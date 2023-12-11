import Foundation
import StoreKit

protocol ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool)
    func willStartLongProcess()
    func didFinishLongProcess()
    func showIAPRelatedError(_ error: Error)
    func didFinishRestoringPurchasesWithZeroProducts()
    func didFinishRestoringPurchasedProducts()
}


class ViewModel {
    
    // MARK: - Properties
    
    var delegate: ViewModelDelegate?
    
    private let model = Model()
    
    var removedAds: Bool {
        return StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.IAP)
    }
    
    
    // MARK: - Init
        
    init() {

    }
    
    
    // MARK: - Fileprivate Methods
    
    fileprivate func updateGameDataWithPurchasedProduct(_ product: SKProduct, _ context: ViewController) {
        // Update the proper game data depending on the keyword the
        // product identifier of the give product contains.
        
        if product.productIdentifier.contains("premiumUpgrade") {
            model.gameData.removedAds = true
            
            StorageHelper().saveToLocalStorage(bool: true, storageType: StorageIdentifier.IAP)
            
            let temp: Bool = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.IAP)
            
            AnalyticsHelper().logEvent(eventkey: "boughtPremiumUpgrade", key: "version", value: 1);
            
            context.checkPurchaseUpgrade()
        }
        
        // Store changes.
        _ = model.gameData.update()
        
        // Ask UI to be updated and reload the table view.
    }
    
    
    fileprivate func restoreRemovedAds(_ context: ViewController) {
        // Mark all maps as unlocked.
        model.gameData.removedAds = true
        
        StorageHelper().saveToLocalStorage(bool: true, storageType: StorageIdentifier.IAP)
        
        let temp: Bool = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.IAP)
        
        AnalyticsHelper().logEvent(eventkey: "restoredPremiumUpgrade", key: "version", value: 1);
        
        context.checkPurchaseUpgrade()
        
        // Save changes and update the UI.
        _ = model.gameData.update()
    }
    
    
    
    // MARK: - Internal Methods
    
    func getProductForItem(at index: Int) -> SKProduct? {
        // Search for a specific keyword depending on the index value.
        let keyword: String
                
        switch index {
        case 0: keyword = "remove_ads"
        default: keyword = ""
        }
        
        // Check if there is a product fetched from App Store containing
        // the keyword matching to the selected item's index.
        guard let product = model.getProduct(containing: keyword) else { return nil }
        return product
    }
    
    // MARK: - Methods To Implement
    
    func viewDidSetup() {
        delegate?.willStartLongProcess()
        
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()
                                
                switch result {
                    case .success(let products): self.model.products = products
                    case .failure(let error): self.delegate?.showIAPRelatedError(error)
                }
            }
        }
    }
    
    
    func purchase(product: SKProduct, context: ViewController) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            delegate?.willStartLongProcess()
                        
            IAPManager.shared.buy(product: product) { (result) in
                DispatchQueue.main.async {
                    self.delegate?.didFinishLongProcess()
                    
                    switch result {
                    case .success(_): self.updateGameDataWithPurchasedProduct(product, context)
                    case .failure(let error): self.delegate?.showIAPRelatedError(error)
                    }
                }
            }
        }

        return true
    }
    
    
    func restorePurchases(_ context: ViewController) {
        
        delegate?.willStartLongProcess()
        
        IAPManager.shared.restorePurchases { (result) in
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()

                switch result {
                case .success(let success):
                    if success {
                        self.restoreRemovedAds(context)
                        self.delegate?.didFinishRestoringPurchasedProducts()
                    } else {
                        self.delegate?.didFinishRestoringPurchasesWithZeroProducts()
                    }

                case .failure(let error):
                    self.delegate?.showIAPRelatedError(error)
                    self.delegate?.didFinishLongProcess()
                }
            }
        }
    }
}
