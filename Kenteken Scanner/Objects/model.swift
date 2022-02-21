import Foundation
import StoreKit

class Model {
    
    struct GameData: Codable, SettingsManageable {
        
        var removedAds = false
    }
    
    var gameData = GameData()
    
    var products = [SKProduct]()
    
    
    init() {
        _ = gameData.load()
    }
    
    
    func getProduct(containing keyword: String) -> SKProduct? {
        return products.filter { $0.productIdentifier.contains(keyword) }.first
    }
}
