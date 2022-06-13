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
    var model = Model()
    
    var customCells = 0
    var customCellsFilled = 0
    var totalCells = 0
    
    var backupRequest = false
    
    let cellIdentifier = "cellid"
    
    lazy var favoriteButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.66)
        button.addTarget(self, action: #selector(favoriteTap(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .init(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.66)
        button.addTarget(self, action: #selector(cameraTap(_:)), for: .touchUpInside)
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
    
    func isBackupRequest() {
        backupRequest = true
    }
    
    func openPurchaseRequest(_ context: dataTableView) -> Void {
        self.context.openPurchaseRequest(context)
    }
    
    func showSingleAlert(withMessage message: String) {
            let alertController = UIAlertController(title: "KentekenScanner", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        self.context.removeAdsButton.isHidden = true
        
        print(error.localizedDescription)
        
        showSingleAlert(withMessage: message)
    }
    
    @objc func favoriteTap(_ button: UIButton) {
        var favorites: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Favorite);
        
        if favorites.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased())
        {
            // finding the index of the item that should be removed.
            let index = favorites.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())
            
            // removing the favorite item with index
            favorites.remove(at: index!)
            
            // saving the edited list of favorites to the localstorage
            StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
            
            // removing active star image
            button.setImage(UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            context.toggleSpinner(onView: view)
            if context.viewModel.removedAds == false {
                
                if favorites.count == 5 {
                    // None premium users can only safe 5 kentekens.
                    // Request them to buy premium
                    openPurchaseRequest(self)
                    context.isSpinning = true
                    context.toggleSpinner(onView: view)
                } else {
                // adding new favorite to the kenteken list
                favorites.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                   
                // saving the edited list with the new favorite added.
                StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
                
                // activating the star button
                button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    
                    context.isSpinning = true
                    context.toggleSpinner(onView: view)
            }
            } else {
                // adding new favorite to the kenteken list
                favorites.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                   
                // saving the edited list with the new favorite added.
                StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
                
                // activating the star button
                button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                
                context.isSpinning = true
                context.toggleSpinner(onView: view)
            }
        }
    }
    
    
    
    @objc func shareTap(_ button: UIButton) {
        let items = [URL(string: String("https://www.kenteken-scanner.nl/api/kenteken/" + kenteken))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func cameraTap(_ button: UIButton) {
        print("show image screen")
    }
    
    func createAPKAlert(_ button: UIButton) -> Void {
        var inArray = false
        var notification: NotificationObject!
        var i = 0
        var location = 0
        var timeInSeconds: Int = 0
        var date: Date!
        var notificationdate: Date!
        
        if let olddate = kentekenData?.vervaldatum_apk {
            //print("old date")
            //print(olddate)
            let dateFormatter = DateFormatter()
            //dateFormatter.dateFormat = "yyyyMMdd"
            
            if backupRequest {
                dateFormatter.dateFormat = "yyyyMMdd"
            } else {
                dateFormatter.dateFormat = "dd-MM-yy"
            }
            date = dateFormatter.date(from:olddate)!
             
            let timeInDays = 0 - (60 * 60 * 24 * 30.5)
            notificationdate = date.advanced(by: TimeInterval(timeInDays))
            timeInSeconds = Int(Date().distance(to: notificationdate))
        }
        
        //print(StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert) as [NotificationObject])
        
        var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert);
        for alert in alerts {
            //print(alert.kenteken)
            //print(kenteken.replacingOccurrences(of: "-", with: "").uppercased())
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
            let alert = UIAlertController(title: "Notificatie verwijderen", message: "Weet je zeker dat je de APK alert voor \(KentekenFactory().format(kenteken)) wilt verwijderen?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(
                title: "Annuleer",
                style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            
            let confirmAction = UIAlertAction(
                title: "Verwijder",
                style: .destructive) { (action)
                in
                    // delete notification
                //print("remove from alerts")
                alerts.remove(at: location)
                StorageHelper().saveToLocalStorage(arr: alerts, storageType: StorageIdentifier.Alert)
                button.setImage(UIImage(systemName: "bell")?.withRenderingMode(.alwaysOriginal), for: .normal)
                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.uuid])
            }
            
            alert.addAction(cancelAction)
            alert.addAction(confirmAction)
            
            self.present(alert, animated: true)
        } else {
            let ctx = self
            let alert: UIAlertController!

            if timeInSeconds < 0 {
                // les than 30 days.
                alert = UIAlertController(title: "Notificatie instellen niet mogelijk", message: "Het is helaas niet mogelijk om een APK alert in te stellen voor kenteken \(KentekenFactory().format(kenteken)). \n\n De APK verloopt binnen 30 dagen.", preferredStyle: .alert)
                
                
                let cancelAction = UIAlertAction(
                    title: "Annuleer",
                    style: .destructive) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                
                alert.addAction(cancelAction)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy hh:mm"
                
                let dateFormatter2 = DateFormatter()
                
                if backupRequest {
                    dateFormatter2.dateFormat = "yyyyMMdd"
                } else {
                    dateFormatter2.dateFormat = "dd-MM-yy"
                }
                
                var dict = [String: String]()
                dict["kenteken"] = kenteken
                dict["notificationDate"] = dateFormatter.string(from: notificationdate)
                
                //print(dict)
            
                AnalyticsHelper().logEventMultipleItems(eventkey: "apk_alert", items: dict);
                    
                alert = UIAlertController(title: "Notificatie instellen", message: "Weet je zeker dat je een APK alert aan wilt zetten voor kenteken \(KentekenFactory().format(kenteken))? \n\n Deze functie zal 30 dagen voor de vervaldatum van de APK om 12:00 uur een melding geven.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(
                    title: "Annuleer",
                    style: .destructive) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }

                let confirmAction = UIAlertAction(
                    title: "Aanmaken",
                    style: .default) { (action)
                    in
                    let uuid = ctx.context.createNotification(title: "APK Alert", description: "De APK van kenteken \(KentekenFactory().format(ctx.kenteken)) verloopt bijna!", kenteken: self.kenteken, apkdatum: date, apkdatumString: dateFormatter2.string(from:date), notificatiedatum: dateFormatter2.string(from: notificationdate), activationTimeFromNow: Double(timeInSeconds))
                        alerts.append(NotificationObject(kenteken: ctx.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), uuid: uuid))
                        StorageHelper().saveToLocalStorage(arr: alerts, storageType: StorageIdentifier.Alert)
                        button.setImage(UIImage(systemName: "bell.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                }
                
                alert.addAction(cancelAction)
                alert.addAction(confirmAction)
            }

            self.present(alert, animated: true)
        }
    }
    
    @objc func notificationTap(_ button: UIButton) {
        context.toggleSpinner(onView: view)
        
        var inArray = false

        let notifications: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert)
        
        for alert in notifications {
            //print(kenteken.replacingOccurrences(of: "-", with: "").uppercased())
            if alert.kenteken == kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
                // kenteken allready in list.
                inArray = true
            }
        }
        
        if context.viewModel.removedAds == false && !inArray {
            if notifications.count >= 2 {
                openPurchaseRequest(self)
                context.isSpinning = true
                context.toggleSpinner(onView: view)
            } else {
                createAPKAlert(button)
                context.isSpinning = true
                context.toggleSpinner(onView: view)
            }
        } else {
            createAPKAlert(button)
            context.isSpinning = true
            context.toggleSpinner(onView: view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let view = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first {
            view.addSubview(favoriteButton)
            view.addSubview(notificationButton)
            view.addSubview(cameraButton)
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                view.addSubview(shareButton)
            }
            
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
                        //print(request.identifier)
                        //print(notification.uuid)
                        //print(request.identifier == notification.uuid)
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
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                self.createButton(button: shareButton, icon: UIImage(systemName: "square.and.arrow.up")!)
            }
            
            self.createButton(button: cameraButton, icon: UIImage(systemName: "camera")!)

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
        totalCells = keys.count + customCells + 2
        return totalCells
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        favoriteButton.removeFromSuperview()
        shareButton.removeFromSuperview()
        notificationButton.removeFromSuperview()
        cameraButton.removeFromSuperview()
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
                    if backupRequest {
                        dateFormatter.dateFormat = "yyyyMMdd"
                    } else {
                        dateFormatter.dateFormat = "dd-MM-yy"
                    }
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
                    if backupRequest {
                        dateFormatter.dateFormat = "yyyyMMdd"
                    } else {
                        dateFormatter.dateFormat = "dd-MM-yy"
                    }
                    date = dateFormatter.date(from:olddate)!
                    
                    if date < Date() {
                        let alert = UIAlertController(title: "Tachograaf verlopen", message: "De Tachograaf van dit voertuig is verlopen.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: nil))

                        self.present(alert, animated: true)
                    }
                }
            }
        } else if (indexPath.row == keys.count){
            _ = tableView.cellForRow(at: indexPath)! as UITableViewCell

            let dateFormatter = DateFormatter()
            if backupRequest {
                dateFormatter.dateFormat = "yyyyMMdd"
            } else {
                dateFormatter.dateFormat = "dd-MM-yy"
            }
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
        } else if keys[indexPath.row] == "imageURL" {
            let imageURL = values[indexPath.row]!
            if imageURL == "" {return 0}
            return 160
        } else {
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!

        if keys[indexPath.row] == "kenteken" {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellId")
        } else {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        }
                
        switch keys[indexPath.row] {
            
        case "imageURL" :
            let imageURL = values[indexPath.row]!
            
                do {
                    let url = URL(string: "https://" + imageURL)!
                    let data = try Data(contentsOf : url)
                    let image = UIImage(data : data)
                    
                    let bounds = UIScreen.main.bounds
                    let width = bounds.size.width - 20

                    let view = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: 160))
                    view.image = image
                    view.contentMode = .scaleAspectFit
                    
                    cell.backgroundColor = .lightGray
                    cell.addSubview(view)
                } catch {
                    print(error)
                }
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
            //let img = UIImage(named: "kenteken-full-border.png")!
            let img = UIImage(named: "kentekenplaat")!

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

            
            if backupRequest || keys[index] == "vervaldatum tachograaf" {
                print("backup")
                dateFormatter.dateFormat = "yyyyMMdd"
                date = dateFormatter.date(from:olddate)!
            } else {
                print("normal")
                dateFormatter.dateFormat = "dd-MM-yy"
                date = dateFormatter.date(from:olddate)!
            }
                        
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
        if backupRequest {
            dateFormatter.dateFormat = "yyyyMMdd"
        } else {
            dateFormatter.dateFormat = "dd-MM-yy"
        }
        _ = dateFormatter.date(from:kentekenData.datum_eerste_toelating)
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "yyyy"
                
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
