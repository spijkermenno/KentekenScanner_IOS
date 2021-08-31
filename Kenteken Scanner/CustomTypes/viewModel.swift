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
    
    fileprivate func updateGameDataWithPurchasedProduct(_ product: SKProduct) {
        // Update the proper game data depending on the keyword the
        // product identifier of the give product contains.
        print("purchase complete: \(product.productIdentifier)")
        if product.productIdentifier.contains("upgrade") {
            model.gameData.removedAds = true
            
            StorageHelper().saveToLocalStorage(bool: true, storageType: StorageIdentifier.IAP)
        }
        
        // Store changes.
        _ = model.gameData.update()
        
        // Ask UI to be updated and reload the table view.
    }
    
    
    fileprivate func restoreRemovedAds() {
        // Mark all maps as unlocked.
        model.gameData.removedAds = true
        
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
        print("request................")
        
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
    
    
    func purchase(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            print("cannot make purchase")
            return false
        } else {
            delegate?.willStartLongProcess()
            
            print("viewmodel purchase()")
            
            IAPManager.shared.buy(product: product) { (result) in
                print("test")
                DispatchQueue.main.async {
                    self.delegate?.didFinishLongProcess()

                    //print(result)
                    
                    switch result {
                    case .success(_): self.updateGameDataWithPurchasedProduct(product)
                    case .failure(let error): self.delegate?.showIAPRelatedError(error)
                    }
                }
            }
        }

        return true
    }
    
    
    func restorePurchases() {
        
        delegate?.willStartLongProcess()
        
        IAPManager.shared.restorePurchases { (result) in
            print("0d0d0d0d0d00d0d0d0dd")
            DispatchQueue.main.async {
                self.delegate?.didFinishLongProcess()

                switch result {
                case .success(let success):
                    if success {
                        self.restoreRemovedAds()
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
