//
//  CustomBottomSheetViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation
import UIKit

class CustomBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var gekentekendeVoertuig: GekentekendeVoertuig
    var gekentekendVoertuigItems: [KeyValuePair] = []
    var context: ViewController
    
    var imagePicker: ImagePicker!
    
    init(gekentekendeVoertuig: GekentekendeVoertuig, context: ViewController) {
        self.gekentekendeVoertuig = gekentekendeVoertuig
        self.context = context
        
        self.gekentekendVoertuigItems = gekentekendeVoertuig.generateKeyValueArray()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var buttonOrder: CGFloat = 0
    
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
    
    @objc func favoriteTap(_ button: UIButton) {
        var favorites: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Favorite)
        
        if favorites.contains(gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased()){
            let index = favorites.firstIndex(of: gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased())
            favorites.remove(at: index!)
            
            StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
            
            button.setImage(UIImage(systemName: "star")?.withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            context.toggleSpinner(onView: view)
            if context.viewModel.removedAds == false {
                
                if favorites.count == 5 {
                    self.context.openPurchaseRequest(self)
                    context.isSpinning = true
                    context.toggleSpinner(onView: view)
                } else {
                    favorites.insert(gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                    
                    StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
                    
                    button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    
                    context.isSpinning = true
                    context.toggleSpinner(onView: view)
                }
            } else {
                favorites.insert(gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                
                StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
                
                button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                
                context.isSpinning = true
                context.toggleSpinner(onView: view)
            }
        }
    }
    
    @objc func cameraTap(_ button: UIButton) {
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        self.imagePicker.present(from: button)
    }
    
    @objc func shareTap(_ button: UIButton) {
        let items = [URL(string: String("https://www.kenteken-scanner.nl/api/kenteken/" + gekentekendeVoertuig.kenteken))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    @objc func notificationTap(_ button: UIButton) {
        context.toggleSpinner(onView: view)
        
        var inArray = false
        
        let notifications: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert)
        
        for alert in notifications {
            //print(kenteken.replacingOccurrences(of: "-", with: "").uppercased())
            if alert.kenteken == gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
                // kenteken allready in list.
                inArray = true
            }
        }
        
        if context.viewModel.removedAds == false && !inArray {
            if notifications.count >= 2 {
                context.openPurchaseRequest(self)
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
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        favoriteButton.removeFromSuperview()
        shareButton.removeFromSuperview()
        notificationButton.removeFromSuperview()
        cameraButton.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let kenteken = gekentekendeVoertuig.kenteken
        
        if let view =
            UIApplication.shared.connectedScenes
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
                        if request.identifier == notification.uuid {
                            DispatchQueue.main.async {
                                ctx.notificationButton.setImage(UIImage(systemName: "bell.fill")!.withRenderingMode(.alwaysOriginal), for: .normal)
                            }
                        }
                    }
                })
            }
            
            if gekentekendeVoertuig.vervaldatum_apk == nil {
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
        
        view.addSubview(tableView)
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            view.addSubview(shareButton)
        }
        
        view.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        
        updateUI()
    }
    
    private func updateUI() {
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gekentekendVoertuigItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        let item = gekentekendVoertuigItems[indexPath.row]
        
        let key = item.key
        let value = item.value
        
        if key == "kenteken" {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
            let img = UIImage(named: "kentekenplaat")!
            
            let imgFrame = UIImageView(image: img)
            
            imgFrame.contentMode = .scaleAspectFit
            
            cell.backgroundView = imgFrame
            
            cell.textLabel!.textColor = .black
            
            cell.textLabel!.textAlignment = NSTextAlignment.center
            cell.textLabel!.font = UIFont(name: "GillSans", size: 36)
            cell.textLabel!.textAlignment = .center
            cell.textLabel!.text = "   " + KentekenFactory().format(value.uppercased())
        } else {
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel!.textColor = .systemBlue
            
            cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 15)
            
            cell.textLabel!.text = "\(item.key)"
            cell.detailTextLabel!.text = "\(item.value)"
        }
        
        
        return cell
    }
    
    
    private var imageRowHeightBig = false
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if gekentekendVoertuigItems[indexPath.row].key == "kenteken" {
            return 80
        } else if gekentekendVoertuigItems[indexPath.row].key == "imageURL" {
            let imageURL = gekentekendVoertuigItems[indexPath.row].value
            if imageURL == "" {return 0}
            if imageRowHeightBig {return 320}
            return 160
        } else {
            return 60
        }
    }
    
    func showSingleAlert(withMessage message: String, title: String = "KentekenScanner") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        (parent as? ViewController)?.removeAdsButton.isHidden = true
        
        print(error.localizedDescription)
        
        showSingleAlert(withMessage: message)
    }
    
    func createAPKAlert(_ button: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        guard let oldDate = gekentekendeVoertuig.vervaldatum_apk.flatMap({ String($0) }),
              let date = dateFormatter.date(from: oldDate)
        else { return }
        
        let timeInDays = -60 * 60 * 24 * 30.5
        let notificationDate = date.addingTimeInterval(TimeInterval(timeInDays))
        let timeInSeconds = Int(Date().distance(to: notificationDate))
        
        var inArray = false
        var notification: NotificationObject!
        var location = 0
        var i = 0
        
        let alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: .Alert)
        
        for (index, alert) in alerts.enumerated() {
            if alert.kenteken == gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
                inArray = true
                notification = alert
                location = index
            }
        }
        
        if inArray {
            showDeleteConfirmationAlert(for: button, at: location, notification: notification)
        } else {
            showCreateNotificationAlert(timeInSeconds: timeInSeconds, notificationDate: notificationDate, apkDatum: date)
        }
    }
    
    private func showDeleteConfirmationAlert(for button: UIButton, at location: Int, notification: NotificationObject) {
        let alert = UIAlertController(title: "Notificatie verwijderen", message: "Weet je zeker dat je de APK alert voor \(KentekenFactory().format(gekentekendeVoertuig.kenteken)) wilt verwijderen?", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Annuleer", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let confirmAction = UIAlertAction(title: "Verwijder", style: .destructive) { _ in
            var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: .Alert)
            alerts.remove(at: location)
            StorageHelper().saveToLocalStorage(arr: alerts, storageType: .Alert)
            button.setImage(UIImage(systemName: "bell")?.withRenderingMode(.alwaysOriginal), for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.uuid])
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        self.present(alert, animated: true)
    }
    
    private func showCreateNotificationAlert(timeInSeconds: Int, notificationDate: Date, apkDatum: Date) {
        let alert: UIAlertController
        
        if timeInSeconds < 0 {
            alert = UIAlertController(title: "Notificatie instellen niet mogelijk", message: "Het is helaas niet mogelijk om een APK alert in te stellen voor kenteken \(KentekenFactory().format(gekentekendeVoertuig.kenteken)). \n\n De APK verloopt binnen 30 dagen.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Annuleer", style: .destructive) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
        } else {
            alert = createNotificationConfirmationAlert(notificationDate: notificationDate, apkDatum: apkDatum, timeInSeconds: timeInSeconds)
        }
        
        self.present(alert, animated: true)
    }
    
    private func createNotificationConfirmationAlert(notificationDate: Date, apkDatum: Date, timeInSeconds: Int) -> UIAlertController {
        let alert: UIAlertController
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let dict = ["kenteken": gekentekendeVoertuig.kenteken, "notificationDate": dateFormatter.string(from: notificationDate)]
        AnalyticsHelper().logEventMultipleItems(eventkey: "apk_alert", items: dict)
        
        alert = UIAlertController(
            title: "Notificatie instellen",
            message: "Weet je zeker dat je een APK alert aan wilt zetten voor kenteken \(KentekenFactory().format(gekentekendeVoertuig.kenteken))? \n\n Deze functie zal 30 dagen voor de vervaldatum van de APK om 12:00 uur een melding geven.",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Annuleer", style: .destructive) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let confirmAction = UIAlertAction(title: "Aanmaken", style: .default) { _ in
            let uuid = 
            self.context.createNotification(
                title: "APK Alert",
                description: "De APK van kenteken \(KentekenFactory().format(self.gekentekendeVoertuig.kenteken)) verloopt bijna!",
                kenteken: self.gekentekendeVoertuig.kenteken,
                apkdatum: apkDatum,
                apkdatumString: dateFormatter.string(from: apkDatum),
                notificatiedatum: dateFormatter.string(from: notificationDate),
                activationTimeFromNow: Double(timeInSeconds)
            )
            
            var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: .Alert)
            alerts.append(NotificationObject(kenteken: self.gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), uuid: uuid))
            StorageHelper().saveToLocalStorage(arr: alerts, storageType: .Alert)
            self.notificationButton.setImage(UIImage(systemName: "bell.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        
        return alert
    }
    
}

extension CustomBottomSheetViewController: ImagePickerDelegate {
    
    func didSelect(image: UIImage?) {
        print("image selected.")
        
        let request = ImageUploader(uploadImage: image!, number: 1, kentekenID: gekentekendeVoertuig.id)
        request.uploadImage { (result) in
            switch result {
            case .success(let value):
                assert(value.statusCode == 200)
                DispatchQueue.main.async {
                    self.showSingleAlert(withMessage: "De afbeelding is verstuurd en zal na controle worden toegevoegd. (Dit process kan even duren)", title: "Gelukt!")
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.showSingleAlert(withMessage: "De ontwikkelaar is op de hoogte gesteld, probeer het later nog eens.", title: "Er is iets fout gegaan")
            }
        }
    }
}
