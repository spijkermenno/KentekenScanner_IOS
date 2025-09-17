//
//  CustomBottomSheetViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation
import UIKit
import Kingfisher
import GoogleMobileAds

class CustomBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var gekentekendeVoertuig: GekentekendeVoertuig
    var gekentekendVoertuigItems: [KeyValuePair] = []
    var context: ViewController

    var imagePicker: ImagePicker!

    // MARK: - Ads (multiple, even spread)
    private var nativeAds: [NativeAd] = []
    private var adLoaders: [AdLoader] = [] // keep strong refs while loading
    
    private let adUnitID = "ca-app-pub-4928043878967484/4553803466"
    
    //private let adUnitID = "ca-app-pub-3940256099942544/3986624511" // test ad unit

    // Toon maximaal 4 advertenties
    private let maxAdsToShow = 4

    init(gekentekendeVoertuig: GekentekendeVoertuig, context: ViewController) {
        self.gekentekendeVoertuig = gekentekendeVoertuig
        self.context = context
        self.gekentekendVoertuigItems = gekentekendeVoertuig.generateKeyValueArray()
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    var buttonOrder: CGFloat = 0

    // MARK: - Buttons
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

    // MARK: - Button Actions
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
                    favorites.insert(gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0)
                    StorageHelper().saveToLocalStorage(arr: favorites, storageType: StorageIdentifier.Favorite)
                    button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
                    context.isSpinning = true
                    context.toggleSpinner(onView: view)
                }
            } else {
                favorites.insert(gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0)
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
        let items = [URL(string: "https://www.kenteken-scanner.nl/api/kenteken/" + gekentekendeVoertuig.kenteken)!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    @objc func notificationTap(_ button: UIButton) {
        context.toggleSpinner(onView: view)
        var inArray = false
        let notifications: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Alert)
        for alert in notifications {
            if alert.kenteken == gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased() {
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
        let trailing: CGFloat = clearance - (buttonOrder * width) - (buttonOrder * padding)
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
        tableView.register(NativeAdTableViewCell.self, forCellReuseIdentifier: "NativeAdCell")
        updateUI()

        // Meerdere losse requests (stabieler dan numberOfAds > 1)
        if context.viewModel.removedAds == false {
            loadNativeAds(count: maxAdsToShow)
        }
    }

    deinit {
        adLoaders.removeAll()
    }

    private func updateUI() {
        tableView.reloadData()
    }

    // MARK: - Ad position helpers (even spread)
    /// Bereken de data-indexen (in `gekentekendVoertuigItems`) waar we advertenties invoegen,
    /// gelijkmatig verdeeld. We plaatsen een ad **voor** het data-item met index `p`.
    private func computeAdInsertionDataIndexes(baseCount: Int, maxAds: Int) -> [Int] {
        guard baseCount > 0, maxAds > 0 else { return [] }

        // Hoeveel ads kunnen we tonen? Niet meer dan baseCount (en niet meer dan maxAds)
        let adsToPlace = min(maxAds, baseCount) // als je 3 regels data hebt, heeft 4 ads geen zin

        // Verdeel in (adsToPlace + 1) segmenten en zet ads aan segmentgrenzen.
        // p ligt in 1...baseCount (p==baseCount betekent ad aan het einde, na alle data).
        var result: [Int] = []
        let segment = Double(baseCount) / Double(adsToPlace + 1)

        var lastP: Int = -1
        for i in 1...adsToPlace {
            var p = Int(round(Double(i) * segment))

            // Clamp en voorkom duplicaten
            p = max(1, min(baseCount, p))
            if p == lastP { p = min(baseCount, p + 1) }
            if p > baseCount { p = baseCount }

            if result.contains(p) == false {
                result.append(p)
                lastP = p
            }
        }

        // Safety: strictly increasing en binnen 1...baseCount
        let cleaned = Array(Set(result)).sorted().filter { $0 >= 1 && $0 <= baseCount }
        return cleaned
    }

    /// Table row index voor elke ad-row, gegeven de data-insert-indexen.
    /// Ad op dataIndex `p` komt op tableRow `p + k` (k = aantal eerdere ads).
    private func computeTableAdRowIndexes(baseCount: Int, adsToRender: Int) -> [Int] {
        guard baseCount > 0, adsToRender > 0 else { return [] }
        let insertionDataIdxs = Array(computeAdInsertionDataIndexes(baseCount: baseCount, maxAds: maxAdsToShow).prefix(adsToRender))
        var rows: [Int] = []
        for (k, p) in insertionDataIdxs.enumerated() {
            rows.append(p + k)
        }
        return rows
    }

    private var showAds: Bool { context.viewModel.removedAds == false }

    /// Is dit een ad-row?
    private func isAdRow(_ row: Int, baseCount: Int) -> (Bool, Int?) {
        guard showAds else { return (false, nil) }
        let adCount = min(nativeAds.count, maxAdsToShow)
        guard adCount > 0 else { return (false, nil) }
        let adRows = computeTableAdRowIndexes(baseCount: baseCount, adsToRender: adCount)
        if let idx = adRows.firstIndex(of: row) {
            return (true, idx) // idx == index in nativeAds om te gebruiken
        }
        return (false, nil)
    }

    /// Aantal ads vóór een bepaalde table row.
    private func adsBefore(row: Int, baseCount: Int) -> Int {
        let adCount = min(nativeAds.count, maxAdsToShow)
        guard adCount > 0 else { return 0 }
        let adRows = computeTableAdRowIndexes(baseCount: baseCount, adsToRender: adCount)
        return adRows.filter { $0 < row }.count
    }

    /// Map table row -> data index (corrigeer voor reeds ingevoegde ads).
    private func dataIndex(for row: Int, baseCount: Int) -> Int {
        return row - adsBefore(row: row, baseCount: baseCount)
    }

    // MARK: - Ads loading (meerdere losse loaders)
    private func loadNativeAds(count: Int) {
        let requests = max(1, min(count, maxAdsToShow))
        print("▶️ Requesting up to \(requests) native ads…")
        for _ in 0..<requests {
            let loader = AdLoader(
                adUnitID: adUnitID,
                rootViewController: self,
                adTypes: [.native],
                options: nil
            )
            loader.delegate = self
            adLoaders.append(loader)
            loader.load(Request())
        }
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let base = gekentekendVoertuigItems.count
        guard showAds else { return base }
        let adCount = min(nativeAds.count, maxAdsToShow)
        let adRows = computeTableAdRowIndexes(baseCount: base, adsToRender: adCount)
        return base + adRows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let base = gekentekendVoertuigItems.count

        // Ad row?
        let (isAd, adIdx) = isAdRow(indexPath.row, baseCount: base)
        if isAd, let adIndex = adIdx, adIndex < nativeAds.count {
            let ad = nativeAds[adIndex]
            let cell = tableView.dequeueReusableCell(withIdentifier: "NativeAdCell") as? NativeAdTableViewCell
                ?? NativeAdTableViewCell(style: .default, reuseIdentifier: "NativeAdCell")
            cell.configure(with: ad)
            return cell
        }

        // Normal data row
        let realIndex = dataIndex(for: indexPath.row, baseCount: base)
        let item = gekentekendVoertuigItems[realIndex]

        var cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")

        let key = item.key
        let value = item.value

        if key == "kenteken" {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
            let img = UIImage(named: "kentekenplaat")!
            let imgFrame = UIImageView(image: img)
            imgFrame.contentMode = .scaleAspectFit
            cell.backgroundView = imgFrame
            cell.textLabel!.textColor = .black
            cell.textLabel!.textAlignment = .center
            cell.textLabel!.font = UIFont(name: "GillSans", size: 36)
            cell.textLabel!.text = "   " + KentekenFactory().format(value.uppercased())
        } else if key == "imageURL" {
            // Maak image-cellen schoon zodat we niet stapelen op reuse
            cell.contentView.subviews.forEach { if $0 is UIImageView { $0.removeFromSuperview() } }
            let imageURLs = gekentekendeVoertuig.getImageURLs()
            for urlString in imageURLs {
                if let url = URL(string: urlString.replacingOccurrences(of: "http://", with: "https://")) {
                    let imageView = UIImageView()
                    imageView.kf.setImage(with: url)
                    imageView.contentMode = .scaleAspectFill
                    imageView.clipsToBounds = true
                    let bounds = UIScreen.main.bounds
                    let width = bounds.size.width
                    var height = 160
                    if self.imageRowHeightBig { height = 320 }
                    imageView.frame = CGRect(x: 0, y: 0, width: Int(width), height: height)
                    cell.backgroundColor = .lightGray
                    cell.contentView.addSubview(imageView)
                }
            }
        } else {
            cell.textLabel!.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel!.textColor = .systemBlue
            cell.detailTextLabel!.font = UIFont.systemFont(ofSize: 15)
            cell.textLabel!.text = "\(item.key)"
            cell.detailTextLabel!.text = "\(item.value)"
        }
        return cell
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let base = gekentekendVoertuigItems.count
        if isAdRow(indexPath.row, baseCount: base).0 { return } // ignore taps on ads

        let realIndex = dataIndex(for: indexPath.row, baseCount: base)
        if gekentekendVoertuigItems[realIndex].key == "imageURL" {
            imageRowHeightBig.toggle()
            tableView.reloadData()
        }
    }

    private var imageRowHeightBig = false

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let base = gekentekendVoertuigItems.count
        if isAdRow(indexPath.row, baseCount: base).0 {
            return 300 // native ad height
        }
        let realIndex = dataIndex(for: indexPath.row, baseCount: base)
        let item = gekentekendVoertuigItems[realIndex]
        if item.key == "kenteken" {
            return 80
        } else if item.key == "imageURL" {
            let imageURL = item.value
            if imageURL == "" { return 0 }
            return imageRowHeightBig ? 320 : 160
        } else {
            return 60
        }
    }

    func showSingleAlert(withMessage message: String, title: String = "KentekenScanner") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }

    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        (parent as? ViewController)?.removeAdsButton.isHidden = true
        print(error.localizedDescription)
        showSingleAlert(withMessage: message)
    }

    // MARK: - APK Alerts (ongewijzigd)
    func createAPKAlert(_ button: UIButton) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        guard let oldDate = gekentekendeVoertuig.vervaldatum_apk.flatMap({ String($0) }),
              let date = dateFormatter.date(from: oldDate) else { return }

        let timeInDays = -60 * 60 * 24 * 30.5
        let notificationDate = date.addingTimeInterval(TimeInterval(timeInDays))
        let timeInSeconds = Int(Date().distance(to: notificationDate))

        var inArray = false
        var notification: NotificationObject!
        var location = 0
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
            showCreateNotificationAlert(timeInSeconds: timeInSeconds,
                                        notificationDate: notificationDate,
                                        apkDatum: date)
        }
    }

    private func showDeleteConfirmationAlert(for button: UIButton, at location: Int, notification: NotificationObject) {
        let alert = UIAlertController(title: "Notificatie verwijderen",
                                      message: "Weet je zeker dat je de APK alert voor \(KentekenFactory().format(gekentekendeVoertuig.kenteken)) wilt verwijderen?",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Annuleer", style: .default)
        let confirmAction = UIAlertAction(title: "Verwijder", style: .destructive) { _ in
            var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: .Alert)
            alerts.remove(at: location)
            StorageHelper().saveToLocalStorage(arr: alerts, storageType: .Alert)
            button.setImage(UIImage(systemName: "bell")?.withRenderingMode(.alwaysOriginal), for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notification.uuid])
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        present(alert, animated: true)
    }

    private func showCreateNotificationAlert(timeInSeconds: Int, notificationDate: Date, apkDatum: Date) {
        let alert: UIAlertController
        if timeInSeconds < 0 {
            alert = UIAlertController(title: "Notificatie instellen niet mogelijk",
                                      message: "Het is helaas niet mogelijk om een APK alert in te stellen voor kenteken \(KentekenFactory().format(gekentekendeVoertuig.kenteken)). \n\n De APK verloopt binnen 30 dagen.",
                                      preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive))
        } else {
            alert = createNotificationConfirmationAlert(notificationDate: notificationDate,
                                                        apkDatum: apkDatum,
                                                        timeInSeconds: timeInSeconds)
        }
        present(alert, animated: true)
    }

    private func createNotificationConfirmationAlert(notificationDate: Date,
                                                     apkDatum: Date,
                                                     timeInSeconds: Int) -> UIAlertController {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let alert = UIAlertController(
            title: "Notificatie instellen",
            message: "Weet je zeker dat je een APK alert aan wilt zetten voor kenteken \(KentekenFactory().format(gekentekendeVoertuig.kenteken))? \n\n Deze functie zal 30 dagen voor de vervaldatum van de APK om 12:00 uur een melding geven.",
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Annuleer", style: .destructive)
        let confirmAction = UIAlertAction(title: "Aanmaken", style: .default) { _ in
            if let uuid = self.context.createNotification(
                title: "APK Alert",
                description: "De APK van kenteken \(KentekenFactory().format(self.gekentekendeVoertuig.kenteken)) verloopt bijna!",
                kenteken: self.gekentekendeVoertuig.kenteken,
                apkdatum: apkDatum,
                apkdatumString: dateFormatter.string(from: apkDatum),
                notificatiedatum: dateFormatter.string(from: notificationDate),
                activationTimeFromNow: Double(timeInSeconds)
            ) {
                var alerts: [NotificationObject] = StorageHelper().retrieveFromLocalStorage(storageType: .Alert)
                alerts.append(NotificationObject(
                    kenteken: self.gekentekendeVoertuig.kenteken.replacingOccurrences(of: "-", with: "").uppercased(),
                    uuid: uuid
                ))
                StorageHelper().saveToLocalStorage(arr: alerts, storageType: .Alert)
                self.notificationButton.setImage(UIImage(systemName: "bell.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                self.showSingleAlert(withMessage: "Het instellen van de APK-alert is mislukt. Controleer of meldingen zijn toegestaan in Instellingen en probeer opnieuw.",
                                     title: "Foutmelding")
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        return alert
    }
}

// MARK: - NativeAdLoaderDelegate
extension CustomBottomSheetViewController: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        print("✅ Native ad loaded: \(nativeAd.headline ?? "no headline")")
        nativeAds.append(nativeAd)
        // verwijder de loader-referentie zodat deze kan dealloceren
        if let idx = adLoaders.firstIndex(where: { $0 === adLoader }) {
            adLoaders.remove(at: idx)
        }
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        let ns = error as NSError
        print("""
        ❌ Failed to load native ad
           • domain: \(ns.domain)
           • code: \(ns.code)
           • desc: \(ns.localizedDescription)
           • userInfo: \(ns.userInfo)
        """)
        if let idx = adLoaders.firstIndex(where: { $0 === adLoader }) {
            adLoaders.remove(at: idx)
        }
    }

    func adLoaderDidFinishLoading(_ adLoader: AdLoader) {
        print("ℹ️ AdLoader finished. Loaded so far: \(nativeAds.count). Remaining loaders: \(adLoaders.count)")
    }
}

// MARK: - ImagePickerDelegate
extension CustomBottomSheetViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image = image else { return }
        let request = ImageUploader(uploadImage: image, number: 1, kentekenID: gekentekendeVoertuig.id)
        request.uploadImage { result in
            switch result {
            case .success(let value):
                assert(value.statusCode == 200)
                DispatchQueue.main.async {
                    self.showSingleAlert(withMessage: "De afbeelding is verstuurd en zal na controle worden toegevoegd. (Dit proces kan even duren)", title: "Gelukt!")
                }
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.showSingleAlert(withMessage: "De ontwikkelaar is op de hoogte gesteld, probeer het later nog eens.", title: "Er is iets fout gegaan")
                }
            }
        }
    }
}
