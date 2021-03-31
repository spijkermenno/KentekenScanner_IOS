//
//  dataTableView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import UIKit
import Firebase

class dataTableView: UITableViewController {
    var kentekenData: kentekenDataObject!
    var keys = [Int: String]()
    var values = [Int: String]()
    var buttonOrder: CGFloat = 0
    var kenteken: String!
    var context: ViewController!
    
    let cellIdentifier = "cellid"
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.66)
        button.addTarget(self, action: #selector(favoriteTap(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.66)
        button.addTarget(self, action: #selector(shareTap(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var notificationButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.66)
        button.addTarget(self, action: #selector(notificationTap(_:)), for: .touchUpInside)
        return button
    }()
    
    func setKenteken(kenteken_: String) {
        self.kenteken = kenteken_
    }
    
    func setContext(context_: ViewController) {
        self.context = context_
    }
    
    @objc func favoriteTap(_ button: UIButton) {
        var favorites: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Favorite);
        print(favorites.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()))
        if favorites.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()) {
            print("remove from favorites")
            let index = favorites.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())
            favorites.remove(at: index!)
            StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
            button.setImage(UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            favorites.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                                
            StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
            
            button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @objc func shareTap(_ button: UIButton) {
        let items = [URL(string: String("https://www.mennospijker.nl/api/kenteken/" + kenteken))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func notificationTap(_ button: UIButton) {
            var inArray = false
            var notification: NotificationObject!
            var i = 0
            var location = 0
            var timeInSeconds: Int = 0
        var date: Date
                    
            if let olddate = kentekenData?.vervaldatum_apk {
                print(olddate)
                let dateFormatter = DateFormatter()
                //dateFormatter.dateFormat = "yyyyMMdd"
                dateFormatter.dateFormat = "dd-MM-yy"
                date = dateFormatter.date(from:olddate)!
                 
                let timeInDays = 0 - (60 * 60 * 24 * 30.5)
                let notificationdate = date.advanced(by: TimeInterval(timeInDays))
                timeInSeconds = Int(Date().distance(to: notificationdate))
            }
            
            print(StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert) as [NotificationObject])
            
            var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert);
            for alert in alerts {
                print(alert.kenteken)
                print(kenteken.replacingOccurrences(of: "-", with: "").uppercased())
                if alert.kenteken == kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
                    // kenteken allready in list.
                    inArray = true
                    notification = alert
                    location = i
                }
                i += 1
            }
            
            if inArray {
                // remove from array and remove from notifcationcenter
                
                print("remove from alerts")
                alerts.remove(at: location)
                StorageHelper().saveToLocalStorage(arr: alerts, storageType: StorageIdentifier.Alert)
                button.setImage(UIImage(systemName: "bell")?.withRenderingMode(.alwaysOriginal), for: .normal)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.uuid])
            } else {
                let ctx = self
                let alert = UIAlertController(title: "Notificatie instellen", message: "Weet je zeker dat je een APK alert aan wilt zetten voor kenteken \(KentekenFactory().format(kenteken))? \n\n Deze functie zal 30 dagen voor de vervaldatum van de APK een melding geven.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(
                    title: "Annuleer",
                    style: .destructive) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }

                let confirmAction = UIAlertAction(
                    title: "Aanmaken",
                    style: .default) { (action)
                    in
                        if timeInSeconds > 0 {
                            let uuid = ctx.context.createNotification(title: "APK Alert", description: "De APK van kenteken \(KentekenFactory().format(ctx.kenteken)) verloopt bijna!", activationTimeFromNow: Double(timeInSeconds))
                            alerts.append(NotificationObject(kenteken: ctx.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), uuid: uuid))
                            StorageHelper().saveToLocalStorage(arr: alerts, storageType: StorageIdentifier.Alert)
                            button.setImage(UIImage(systemName: "bell.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    }
            }
                
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)

            self.present(alert, animated: true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(favoriteButton)
            view.addSubview(notificationButton)
            view.addSubview(shareButton)
            
            let alerts = StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Alert) as [NotificationObject]
            
            var inArray = false
            var notification: NotificationObject!
            
            for alert in alerts {
                if alert.kenteken == kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
                    // kenteken allready in list.
                    inArray = true
                    notification = alert
                }
            }
            
            if inArray {
                let ctx = self
                UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { requests in
                    for request in requests {
                        if request.identifier == notification.uuid {
                            DispatchQueue.main.async {
                                ctx.notificationButton.setImage(UIImage(systemName: "bell.fill")!.withRenderingMode(.alwaysOriginal), for: .normal)
                            }
                        }
                    }
                })
            }
            
            if kentekenData.vervaldatum_apk == nil {
                notificationButton.isHidden = true
            } else {
                self.createButton(button: notificationButton, icon: UIImage(systemName: "bell")!)
            }
            
            if StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Favorite).contains(kenteken.replacingOccurrences(of: "-", with: "")) {
                self.createButton(button: favoriteButton, icon: UIImage(systemName: "star.fill")!)
            } else {
                self.createButton(button: favoriteButton, icon: UIImage(systemName: "star")!)
            }
            
            self.createButton(button: shareButton, icon: UIImage(systemName: "square.and.arrow.up")!)
        }
        buttonOrder = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
    }
    
    func createButton(button: UIButton, icon: UIImage) {
        let clearance: CGFloat = -36
        let width: CGFloat = 50
        let padding: CGFloat = 10
        
        let trailing: CGFloat = CGFloat(clearance - CGFloat(buttonOrder * width) - CGFloat(buttonOrder * padding))
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailing),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -36),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalToConstant: 50)
                ])
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.setImage(icon.withRenderingMode(.alwaysOriginal), for: .normal)
        
        buttonOrder += 1
    }
    
    func loadData(object: kentekenDataObject) {
        kentekenData = object
        
        let mir = Mirror(reflecting: kentekenData!)
        
        var i: Int = 0
        mir.children.forEach{child in
            let key: String = child.label ?? "Geen data beschikbaar"
            var value: String = "Geen data beschikbaar"
            
            if let val: String = child.value as? String {
                value = val
            }
        
            if value != "Geen data beschikbaar" {
                keys[i] = key.replacingOccurrences(of: "_", with: " ")
                values[i] = value
                i += 1
            }
            
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        favoriteButton.removeFromSuperview()
        shareButton.removeFromSuperview()
        notificationButton.removeFromSuperview()
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = keys[indexPath.row]
        cell.detailTextLabel?.text = values[indexPath.row]
                
        return cell
    }
}
