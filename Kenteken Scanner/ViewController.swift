//
//  ViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 15/03/2021.
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController, UNUserNotificationCenterDelegate, UITextFieldDelegate {
    var cameraViewController: VisionViewController!
    @IBOutlet var kentekenField: UITextField!
    
    var bannerView: GADBannerView!
    var remoteConfig: RemoteConfig!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willEnterForegroundNotification, object: nil)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
        
        bannerView.isHidden = true
        
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
    
    @objc func appMovedToBackground() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }


    func createNotification(title: String, description: String, activationTimeFromNow: Double) -> String {
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

        // Add the content to the notification content
        notificationContent.title = title
        notificationContent.body = description
        notificationContent.badge = NSNumber(value: UIApplication.shared.applicationIconBadgeNumber + 1)
        
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
    
    func createAlert(title: String, message: String, dismiss: Bool) {
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

}

extension UIStoryboard{
   class func load(_ storyboard: String) -> UIViewController{
    print("ext: load")

      return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboard)
   }
}

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        print("set spinner")

        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .large)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        print("remove spinner")
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
            print("spinner fixed")
        }
        print("spinner removed")

    }
}
 
