//
//  ViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 15/03/2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var cameraViewController: VisionViewController!
    @IBOutlet var kentekenField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
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
        //let recentKentekens: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent)
        
        let dataTableViewObj:kentekenDataTableViewController = kentekenDataTableViewController()
        dataTableViewObj.setContext(ctx_: self)
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
    }
}

extension UIStoryboard{
   class func load(_ storyboard: String) -> UIViewController{
      return UIStoryboard(name: storyboard, bundle: nil).instantiateViewController(withIdentifier: storyboard)
   }
}
