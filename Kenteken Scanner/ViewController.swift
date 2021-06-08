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

class ViewController: UIViewController, UNUserNotificationCenterDelegate, UITextFieldDelegate {
    var cameraViewController: VisionViewController!
    @IBOutlet var kentekenField: UITextField!
    
    var bannerView: GADBannerView!
    var remoteConfig: RemoteConfig!
    
    var isSpinning = false
    
    var viewModel = ViewModel()
    
    var spinnerView: UIView!
    var ai: UIActivityIndicatorView!
     
    func requestIDFA(bview: GADBannerView) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        // Tracking authorization completed. Start loading ads here.
      })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        print("are ads removed? \(viewModel.removedAds)")
        
        if !viewModel.removedAds {
            bannerView = GADBannerView(adSize: kGADAdSizeLargeBanner)
            
            bannerView.adUnitID = "ca-app-pub-4928043878967484/2516765129"
            bannerView.rootViewController = self
                    
            bannerView.isHidden = false
            
            requestIDFA(bview: bannerView)
            
            bannerView.load(GADRequest())
            
            addBannerViewToView(bannerView)
        }
        
        kentekenField.addTarget(self, action: #selector(runKentekenAPI), for: UIControl.Event.primaryActionTriggered)
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        remoteConfig.fetch() { (status, error) -> Void in
          if status == .success {
            print("Config fetched!")
            self.remoteConfig.activate() { (changed, error) in
                if self.remoteConfig.configValue(forKey: "show_ads").stringValue == "true" {
                    DispatchQueue.main.async {
                        self.bannerView.isHidden = false
                    }
                }
            }
          } else {
            print("Config not fetched")
            print("Error: \(error?.localizedDescription ?? "No error available.")")
          }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.viewDidSetup()
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
            } else {
                print("aaaaaaaaaaaaa")
            }
        }
        
        // Create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()

        let uuid = UUID().uuidString
        var dict = [String: Any]()
        
        dict["kenteken"] = kenteken
        dict["apkdatum"] = apkdatumString
        dict["notificatiedatum"] = notificatiedatum

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
    
    @objc func runKentekenAPI() {
        let enteredKenteken : String = kentekenField.text!
        //check if valid kenteken
        kentekenField.text = KentekenFactory().format(enteredKenteken)
        
        if KentekenFactory().getSidecode(enteredKenteken) != -2 {
            NetworkRequestHelper().kentekenRequest(kenteken: enteredKenteken, view: self);
            AnalyticsHelper().logEvent(eventkey: "search", key: "kenteken", value: enteredKenteken);
        }
    }
    
    // Searchfield on text change handler
    @IBAction func KentekenHandler(_ sender: UITextField, forEvent event: UIEvent) {
        let enteredKenteken : String = sender.text!
        //check if valid kenteken
        sender.text = KentekenFactory().format(enteredKenteken)
        
        if KentekenFactory().getSidecode(enteredKenteken) != -2 {
            NetworkRequestHelper().kentekenRequest(kenteken: enteredKenteken, view: self);
            AnalyticsHelper().logEvent(eventkey: "search", key: "kenteken", value: enteredKenteken);
        }
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
//        isSpinning = true
//        toggleSpinner(onView: self.view)

        print("create alert")

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if dismiss {
            print("alert dismiss true")
            alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))
        }

        self.present(alert, animated: true)
        print("presented alert")
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
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
    @IBAction func removeAdsButton(_ sender: UIButton) {
        showAlert(for: viewModel.getProductForItem(at: 0)!)
    }
    
    func showSingleAlert(withMessage message: String) {
            let alertController = UIAlertController(title: "KentekenScanner", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    
    func showAlert(for product: SKProduct) {
        guard let price = IAPManager.shared.getPriceFormatted(for: product) else { return }
        let alertController = UIAlertController(title: product.localizedTitle,
                                                message: product.localizedDescription,
                                                preferredStyle: .alert)
     
        alertController.addAction(UIAlertAction(title: "Koop nu voor \(price)", style: .default, handler: { (_) in
            if !self.viewModel.purchase(product: product) {
                self.showSingleAlert(withMessage: "In-App aankopen zijn niet toegestaan op dit apparaat.")
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Aankoop herstellen", style: .default, handler: { (_) in
            print("restoring")
            if SKPaymentQueue.canMakePayments() {
                self.viewModel.restorePurchases()
            } else {
                self.showSingleAlert(withMessage: "In-App aankopen zijn niet toegestaan op dit apparaat.")
            }
        }))
     
        alertController.addAction(UIAlertAction(title: "Annuleren", style: .destructive, handler: nil))
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
        print("Toggle spinner: \(isSpinning)")
        
        if isSpinning {
            // remove spinner
            DispatchQueue.main.async {
                vSpinner?.removeFromSuperview()
                vSpinner = nil
                self.kentekenField.isEnabled = true
                self.isSpinning = false
            }
        } else {
            // place spinner
            spinnerView = UIView.init(frame: onView.bounds)
            spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            ai = UIActivityIndicatorView.init(style: .large)
            ai.startAnimating()
            ai.center = spinnerView.center
            
            DispatchQueue.main.async {
                self.kentekenField.isEnabled = false
                self.spinnerView.addSubview(self.ai)
                onView.addSubview(self.spinnerView)
                self.isSpinning = true
            }
            vSpinner = spinnerView
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
        
        // In a real app you might want to check what exactly the
        // error is and display a more user-friendly message.
        // For example:
        /*
        switch error {
        case .noProductIDsFound: message = NSLocalizedString("Unable to initiate in-app purchases.", comment: "")
        case .noProductsFound: message = NSLocalizedString("Nothing was found to buy.", comment: "")
        // Add more cases...
        default: message = ""
        }
        */
        
        showSingleAlert(withMessage: message)
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "There are no purchased items to restore.")
    }
    
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "All previous In-App Purchases have been restored!")
    }
}
