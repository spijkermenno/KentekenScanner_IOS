//
//  ViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 15/03/2021.
//

import UIKit
import Firebase
import GoogleMobileAds

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    var cameraViewController: VisionViewController!
    @IBOutlet var kentekenField: UITextField!
    
    var bannerView: GADBannerView!
    var remoteConfig: RemoteConfig!

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        
        bannerView.load(GADRequest())
        
        bannerView.isHidden = true
        
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
        notificationContent.badge = NSNumber(value: 1)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: activationTimeFromNow, repeats: false)
        
        let request = UNNotificationRequest(identifier: uuid, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
        return uuid
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
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if dismiss {
            alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))
        }

        self.present(alert, animated: true)
        AnalyticsHelper().logError(eventkey: "failed_search");
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
      return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboard)
   }
}
