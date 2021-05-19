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
    var switchCells = [UITableViewCell: String]()
    var buttonOrder: CGFloat = 0
    var kenteken: String!
    var context: ViewController!
    
    var customCells = 0
    var customCellsFilled = 0
    var totalCells = 0
    
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
        if ["personenauto", "bedrijfsauto"].contains(kentekenData.voertuigsoort!.lowercased()) {
            customCells = 1
        }
        totalCells = keys.count + customCells + 1
        return keys.count + customCells + 1
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        favoriteButton.removeFromSuperview()
        shareButton.removeFromSuperview()
        notificationButton.removeFromSuperview()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt
         indexPath: IndexPath) {
        if keys.count > indexPath.row {
            if keys[indexPath.row]!.contains("brandstofverbruik") {
                let value = values[indexPath.row]!
                let temp = value.split(separator: "\n")
                
                let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
                
                if temp[0] == currentCell.detailTextLabel!.text! {
                    currentCell.detailTextLabel!.text = String(temp[1])
                } else {
                    currentCell.detailTextLabel!.text = String(temp[0])
                }

            }
            
            if keys[indexPath.row] == "vervaldatum apk" {
                var date: Date
                            
                if let olddate = kentekenData?.vervaldatum_apk {
                    let dateFormatter = DateFormatter()
                    //dateFormatter.dateFormat = "yyyyMMdd"
                    dateFormatter.dateFormat = "dd-MM-yy"
                    date = dateFormatter.date(from:olddate)!
                    
                    if date < Date() {
                        let alert = UIAlertController(title: "APK Verlopen", message: "De APK van dit voertuig is verlopen.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))

                        self.present(alert, animated: true)
                    }
                }
            }
            
            if keys[indexPath.row] == "vervaldatum tachograaf" {
                var date: Date
                            
                if let olddate = kentekenData?.vervaldatum_tachograaf {
                    let dateFormatter = DateFormatter()
                    //dateFormatter.dateFormat = "yyyyMMdd"
                    dateFormatter.dateFormat = "dd-MM-yy"
                    date = dateFormatter.date(from:olddate)!
                    
                    if date < Date() {
                        let alert = UIAlertController(title: "Tachograaf verlopen", message: "De Tachograaf van dit voertuig is verlopen.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))

                        self.present(alert, animated: true)
                    }
                }
            }
        } else {
            let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy"
            let date = dateFormatter.date(from:kentekenData.datum_eerste_toelating)
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "yyyy"
            
            let year = dateFormatterPrint.string(from: date!)
            
            let name = kentekenData.handelsbenaming!.replacingOccurrences(of: kentekenData.merk, with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
            
            let carsUrl = "https://www.gaspedaal.nl/\(kentekenData.merk!)/\(name)/\(kentekenData.brandstof_omschrijving!)?bmax=\(year)&bmin=\(year)"
            //let carsUrl = "https://www.autoscout24.nl/lst/\(kentekenData.merk!)/\(name)?desc=0&size=20&cy=NL&fregto=\(year)&fregfrom=\(year)";
            
            guard let url = URL(string: carsUrl) else {
                return
            }
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
      }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if keys[indexPath.row] == "kenteken" {
            return 80
        } else {
            return 60
        }
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if keys[indexPath.row] == "kenteken" {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellId")
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        }
                
        switch keys[indexPath.row] {
        case "datum eerste toelating":
             dateCell(cell: cell, index: indexPath.row)
        case "datum eerste afgifte nederland":
             dateCell(cell: cell, index: indexPath.row)
        case "datum tenaamstelling":
             dateCell(cell: cell, index: indexPath.row)
        case "vervaldatum apk":
             dateCell(cell: cell, index: indexPath.row)
        case "vervaldatum tachograaf":
             dateCell(cell: cell, index: indexPath.row)
        case "brandstofverbruik buiten":
            let value = values[indexPath.row]!
            let temp = value.split(separator: "\n")
            
            cell.textLabel?.text = keys[indexPath.row]?.capitalizingFirstLetter()
            cell.detailTextLabel!.text = String(temp[0]).capitalizingFirstLetter()
        case "brandstofverbruik stad":
            let value = values[indexPath.row]!
            let temp = value.split(separator: "\n")
            
            cell.textLabel?.text = keys[indexPath.row]?.capitalizingFirstLetter()
            cell.detailTextLabel!.text = String(temp[0]).capitalizingFirstLetter()
        case "brandstofverbruik gecombineerd":
            let value = values[indexPath.row]!
            let temp = value.split(separator: "\n")
            
            cell.textLabel?.text = keys[indexPath.row]?.capitalizingFirstLetter()
            cell.detailTextLabel!.text = String(temp[0]).capitalizingFirstLetter()
        case "kenteken":
            let img = UIImage(named: "kenteken-full-border.png")!
            
            let imgFrame = UIImageView(image: img)
        
            imgFrame.contentMode = .scaleAspectFit
        
            cell.backgroundView = imgFrame
            
            cell.textLabel!.textAlignment = NSTextAlignment.center
            cell.textLabel!.font = UIFont(name: "GillSans", size: 36)
            cell.textLabel!.textAlignment = .center
            cell.textLabel!.text = "   " + KentekenFactory().format(values[indexPath.row]!.uppercased())
        default:
            if indexPath.row >= keys.count && customCellsFilled < customCells && kentekenData.datum_tenaamstelling != nil{
                if ["personenauto", "bedrijfsauto"].contains(kentekenData.voertuigsoort!.lowercased()) {
                    customCells(cell: cell, index: indexPath.row)
                    customCellsFilled += 1
                } else {
                    cell.isHidden = true
                    cell.removeFromSuperview()
                }
                
            } else {
                cell.textLabel?.text = keys[indexPath.row]?.capitalizingFirstLetter()
                cell.detailTextLabel?.text = values[indexPath.row]?.capitalizingFirstLetter()
            }
        }
        
        return cell
    }
    
    
    // format the cell to a date related cell
    func dateCell(cell: UITableViewCell, index: Int) {
        var date: Date
                    
        if let olddate = values[index] {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yy"
            date = dateFormatter.date(from:olddate)!
            
            if keys[index] == "vervaldatum apk" && date < Date() {
                cell.textLabel?.textColor = UIColor.red
            }
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"

            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM yyyy"
            
            cell.detailTextLabel?.text = dateFormatterPrint.string(from: date)
            
            cell.textLabel?.text = keys[index]?.capitalizingFirstLetter()
        }
    }
    
    func customCells(cell: UITableViewCell, index: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        let date = dateFormatter.date(from:kentekenData.datum_eerste_toelating)
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy"
        
        let year = dateFormatterPrint.string(from: date!)
        
        let name = kentekenData.handelsbenaming!.replacingOccurrences(of: kentekenData.merk, with: "").trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: " ", with: "-")
        
        let carsUrl = "https://www.gaspedaal.nl/\(kentekenData.merk!)/\(name)";

        cell.textLabel?.text = "Vergelijkbare auto's"
        cell.detailTextLabel?.textColor = UIColor.link
        cell.detailTextLabel?.text = carsUrl
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
