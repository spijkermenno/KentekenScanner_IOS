//
//  ViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 15/03/2021.
//

import UIKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import StoreKit
import IntentsUI

class ViewController: UIViewController, UNUserNotificationCenterDelegate, UITextFieldDelegate, GADFullScreenContentDelegate {
    var cameraViewController: VisionViewController!
    
    @IBOutlet var kentekenField: UITextField!
    @IBOutlet var europeStarsImages: UIImageView!
    
    var bannerView: GADBannerView!
    var remoteConfig: RemoteConfig!
    
    var isSpinning = false
    
    var viewModel = ViewModel()
    
    var interstitialShowing = false
    
    var requestInterval: Int = 10
    
    var spinnerView: UIView!
    var ai: UIActivityIndicatorView!
    
    var interstitial: GADInterstitialAd!
    
    var actualKenteken: String!
    
    @IBOutlet var removeAdsButton: UIButton!
    
    @objc func pushNotificationHandler(_ notification : NSNotification) {
        let kenteken = notification.userInfo!["kenteken"]
        checkKenteken(kenteken: kenteken as! String)
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-4928043878967484/8261143212",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            print("Inter loaded")
            
            interstitial = ad!
            interstitial.fullScreenContentDelegate = self
            
        }
        )
        
    }
    
    func showInterstitial() {
        if interstitial != nil {
            self.interstitialShowing = true
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushNotificationHandler(_:)) , name: NSNotification.Name(rawValue: "NewNotification"), object: nil)
        
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        //self.showInter = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.ShowInter)
        
        bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
        
        kentekenField.addTarget(self, action: #selector(runKentekenAPI), for: UIControl.Event.primaryActionTriggered)
        
        europeStarsImages.roundCorners(topLeft: 10, topRight: 0, bottomLeft: 10, bottomRight: 0)
        
        kentekenField.roundCorners(topLeft: 0, topRight: 10, bottomLeft: 0, bottomRight: 10)
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        // checking if Google Ads are enabled in the remote config via Firebase.
        // default value when Firebase does not respond is FALSE
        
        remoteConfig.fetch() { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate() { (changed, error) in
                    if self.remoteConfig.configValue(forKey: "show_ads").stringValue == "true" {
                        DispatchQueue.main.async {
                            self.bannerView.isHidden = false
                            //self.removeAdsButton.isHidden = false
                            
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.bannerView.isHidden = true
                            self.removeAdsButton.isHidden = true
                        }
                    }
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }

        
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
            }
        }
        
        // testNotification()
        
        Analytics.setUserID(UUID().uuidString)
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["notUsedAppNotification"])
        
        let uuid = createNotUsedNotification()
        
        print(uuid)
        
        checkPurchaseUpgrade()
        
    }
    
    func testNotification() -> Void {
        let notificationContent = UNMutableNotificationContent()
        
        let uuid = UUID().uuidString
        var dict = [String: Any]()
        
        dict["kenteken"] = "31SLDL"
        dict["apkdatum"] = "02-12-21"
        dict["notificatiedatum"] = "01-11-21"
        
        // Add the content to the notification content
        notificationContent.title = "test"
        notificationContent.body = "nog een keer"
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        notificationContent.userInfo = dict
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: "test notification", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
    func requestIDFA(bview: GADBannerView) {
     
    }
    
    func checkPurchaseUpgrade() -> Void {
        // check if non consumable was bought.
        
        print("are ads removed? \(viewModel.removedAds)")
        
        if !viewModel.removedAds {
            bannerView.adUnitID = "ca-app-pub-4928043878967484/2516765129"
            bannerView.rootViewController = self
            
            bannerView.isHidden = false
            removeAdsButton.isHidden = false
            
            bannerView.load(GADRequest())
            
            addBannerViewToView(bannerView)
            
            print("INTERSTITIAL")
            loadInterstitial()
        } else {
            bannerView.isHidden = true
            removeAdsButton.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func appMovedToBackground() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func createNotification(title: String, description: String, kenteken: String, apkdatum: Date, apkdatumString: String, notificatiedatum: String, activationTimeFromNow: Double) -> String {
        // Request permission to perform notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        
        // Create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()
        
        let uuid = UUID().uuidString
        var dict = [String: Any]()
        
        dict["kenteken"] = kenteken
        dict["apkdatum"] = apkdatumString
        dict["notificatiedatum"] = notificatiedatum
        
        print(dict)
        
        // Add the content to the notification content
        notificationContent.title = title
        notificationContent.body = description
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        notificationContent.userInfo = dict
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: activationTimeFromNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
        return uuid
    }
    
    func createNotUsedNotification() -> String {
        // Request permission to perform notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        // Create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()
        
        let uuid = "notUsedAppNotification"
        
        // Add the content to the notification content
        notificationContent.title = "Hey autofanaat!"
        notificationContent.body = "Je hebt de app al een tijdje niet gebruikt, heb je geen vette auto's meer gespot?"
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber)
        
        let minute: Double = 60.0
        let hour: Double = 60.0 * minute
        let day: Double = 24.0 * hour
        let week: Double = 7.0 * day
        
        let time: Double = 2.0 * week
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        let request = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
        return uuid
    }
    
    func checkKenteken(kenteken: String) {
        // check if kenteken sidecode is not -2.
        // -2 is the status code for no result.
        
        if KentekenFactory().getSidecode(kenteken) != -2 {
            // Performing the API request.
            NetworkRequestHelper().kentekenRequest(kenteken: kenteken, view: self);
            
            // Logging the request to the firebase analytics.
            AnalyticsHelper().logEvent(eventkey: "search", key: "kenteken", value: kenteken);
        }
    }
    
    @objc func runKentekenAPI() {
        print("request via runKentekenAPI")
        
        let enteredKenteken : String = kentekenField.text!
        //check if valid kenteken
        kentekenField.text = KentekenFactory().format(enteredKenteken)
        
        checkKenteken(kenteken: enteredKenteken)
    }
    
    // Searchfield on text change handler
    @IBAction func KentekenHandler(_ sender: UITextField, forEvent event: UIEvent) {
        print("request via KentekenHandler")
        
        let enteredKenteken : String = sender.text!
        //check if valid kenteken
        sender.text = KentekenFactory().format(enteredKenteken)
        
        checkKenteken(kenteken: enteredKenteken)
    }
    
    @IBAction func RecentButton(_ sender: Any, forEvent event: UIEvent) {
        AnalyticsHelper().logEvent(eventkey: "recent_load", key: "click", value: true)
        
        let dataTableViewObj:kentekenDataTableViewController = kentekenDataTableViewController()
        dataTableViewObj.setContext(ctx_: self)
        dataTableViewObj.setStorageIdentifier(identifier: StorageIdentifier.Recent)
        self.present(dataTableViewObj, animated: true, completion: nil)
    }
    @IBAction func FavoriteButton(_ sender: Any, forEvent event: UIEvent) {
        AnalyticsHelper().logEvent(eventkey: "favorite_load", key: "click", value: true)
        
        let dataTableViewObj:kentekenDataTableViewController = kentekenDataTableViewController()
        dataTableViewObj.setContext(ctx_: self)
        dataTableViewObj.setStorageIdentifier(identifier: StorageIdentifier.Favorite)
        self.present(dataTableViewObj, animated: true, completion: nil)
    }
    
    @IBAction func CameraButton(_ sender: Any, forEvent event: UIEvent) {
        guard let vc = UIStoryboard.load("VisionViewController") as? VisionViewController else {return}
        vc.setContext(ctx_: self)
        cameraViewController = vc
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func notificationButton(_ sender: UIButton) {
        
        let dataTableViewObj:pendingNotificationTableViewController = pendingNotificationTableViewController()
        dataTableViewObj.setContext(ctx_: self)
        self.present(dataTableViewObj, animated: true, completion: nil)
    }
    
    func createAlert(title: String, message: String, dismiss: Bool) {
        print("create alert")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        print(message)
        
        if dismiss {
            print("alert dismissable")
            alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))
        }
        
        self.present(alert, animated: true)
        print("alert is presented")
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
    }
    
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.interstitialShowing = false
        
        NetworkRequestHelper().actualRequest(kenteken: actualKenteken, view: self)
    }
    
    func openPurchaseRequest(_ context: Any) -> Void {
        IAPManager.shared.getProducts { (result) in
            switch result {
            case .success(let products):
                let product = products.first!
                
                let alert = UIAlertController(title: "Oeps!", message: "Wil je advertenties verwijderen, meer dan vijf kentekens opslaan of voor meer dan twee auto's een APK alert instellen? \n\n Dit kan met een premium upgrade voor \(IAPManager.shared.getPriceFormatted(for: product)!).", preferredStyle: .alert)
                
                alert.addAction(
                    UIAlertAction(
                        title: "Sluiten",
                        style: .destructive,
                        handler: {(alert: UIAlertAction!) in
                            return
                        }
                    )
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Aankoop herstellen",
                        style: .default,
                        handler: {(alert: UIAlertAction!) in
                            self.viewModel.restorePurchases(self)
                        }
                    )
                )
                
                alert.addAction(
                    UIAlertAction(
                        title: "Aankopen",
                        style: .default,
                        handler: {(alert: UIAlertAction!) in
                            // starting transaction
                            if !self.viewModel.purchase(product: product, context: self) {
                                self.showSingleAlert(withMessage: "In-App aankopen zijn niet toegestaan op dit apparaat.")
                            } else {
                                self.checkPurchaseUpgrade()
                            }
                        }
                    )
                )
                
                DispatchQueue.main.async {
                    if let ctx = context as? ViewController {
                        ctx.present(alert, animated: true)
                    } else if let ctx = context as? dataTableView {
                        ctx.present(alert, animated: true)
                    }
                }
            case .failure(let error):
                print("IAP ERROR")
                DispatchQueue.main.async {
                    if let ctx = context as? dataTableView {
                        ctx.showIAPRelatedError(error)
                    } else {
                        self.showIAPRelatedError(error)
                    }
                }
            }
        }
    }
    
    @IBAction func removeAdsButton(_ sender: UIButton) {
        openPurchaseRequest(self)
    }
    
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "KentekenScanner", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIStoryboard{
    class func load(_ storyboard: String) -> UIViewController{
        print("ext: load")
        
        return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboard)
    }
}

var vSpinner : UIView?

extension ViewController {
    
    func toggleSpinner(onView: UIView) {
        
        print("Is spinning: \(self.isSpinning)")
        
        if self.isSpinning {
            // remove spinner
            DispatchQueue.main.async {
                vSpinner?.removeFromSuperview()
                vSpinner = nil
                self.kentekenField.isEnabled = true
                self.isSpinning = false
            }
        } else {
            // place spinner
            self.spinnerView = UIView.init(frame: onView.bounds)
            self.spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            self.ai = UIActivityIndicatorView.init(style: .large)
            self.ai.startAnimating()
            self.ai.center = self.spinnerView.center
            
            DispatchQueue.main.async {
                self.kentekenField.isEnabled = false
                self.spinnerView.addSubview(self.ai)
                onView.addSubview(self.spinnerView)
                self.isSpinning = true
            }
            vSpinner = self.spinnerView
        }
    }
}

extension ViewController: ViewModelDelegate {
    func toggleOverlay(shouldShow: Bool) {
        isSpinning = !shouldShow
        toggleSpinner(onView: view)
    }
    
    func willStartLongProcess() {
        isSpinning = false
        toggleSpinner(onView: view)
    }
    
    func didFinishLongProcess() {
        isSpinning = true
        toggleSpinner(onView: view)
    }
    
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        removeAdsButton.isHidden = true
        
        print(error.localizedDescription)
        
        showSingleAlert(withMessage: message)
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.")
    }
    
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!")
    }
}

extension UIView{
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0) {//(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

extension UIBezierPath {
    convenience init(shouldRoundRect rect: CGRect, topLeftRadius: CGSize = .zero, topRightRadius: CGSize = .zero, bottomLeftRadius: CGSize = .zero, bottomRightRadius: CGSize = .zero){
        
        self.init()
        
        let path = CGMutablePath()
        
        let topLeft = rect.origin
        let topRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.maxY)
        
        if topLeftRadius != .zero{
            path.move(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.move(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        if topRightRadius != .zero{
            path.addLine(to: CGPoint(x: topRight.x-topRightRadius.width, y: topRight.y))
            path.addCurve(to:  CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height), control1: CGPoint(x: topRight.x, y: topRight.y), control2:CGPoint(x: topRight.x, y: topRight.y+topRightRadius.height))
        } else {
            path.addLine(to: CGPoint(x: topRight.x, y: topRight.y))
        }
        
        if bottomRightRadius != .zero{
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y-bottomRightRadius.height))
            path.addCurve(to: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y), control1: CGPoint(x: bottomRight.x, y: bottomRight.y), control2: CGPoint(x: bottomRight.x-bottomRightRadius.width, y: bottomRight.y))
        } else {
            path.addLine(to: CGPoint(x: bottomRight.x, y: bottomRight.y))
        }
        
        if bottomLeftRadius != .zero{
            path.addLine(to: CGPoint(x: bottomLeft.x+bottomLeftRadius.width, y: bottomLeft.y))
            path.addCurve(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height), control1: CGPoint(x: bottomLeft.x, y: bottomLeft.y), control2: CGPoint(x: bottomLeft.x, y: bottomLeft.y-bottomLeftRadius.height))
        } else {
            path.addLine(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y))
        }
        
        if topLeftRadius != .zero{
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y+topLeftRadius.height))
            path.addCurve(to: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y) , control1: CGPoint(x: topLeft.x, y: topLeft.y) , control2: CGPoint(x: topLeft.x+topLeftRadius.width, y: topLeft.y))
        } else {
            path.addLine(to: CGPoint(x: topLeft.x, y: topLeft.y))
        }
        
        path.closeSubpath()
        cgPath = path
    }
}
