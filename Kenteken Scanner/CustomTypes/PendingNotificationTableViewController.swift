//
//  kentekenDataTableViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import UIKit
import UserNotifications

class pendingNotificationTableViewController: UITableViewController {
    var ctx: ViewController?
    var alerts: [UNNotificationContent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // UI
        tableView.backgroundColor = .systemGroupedBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = 88
        tableView.estimatedRowHeight = 88

        // Ophalen van pending requests
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            // Filter interne reminder
            let filtered = requests.filter { $0.identifier != "notUsedAppNotification" }

            if filtered.isEmpty {
                DispatchQueue.main.async {
                    self.dismiss(animated: true) {
                        self.ctx?.createAlert(title: "Geen data",
                                              message: "Er zijn nog geen notificaties ingesteld.",
                                              dismiss: true)
                    }
                }
                return
            }

            var hadError = false
            var contents: [UNNotificationContent] = []
            for r in filtered {
                if r.content.userInfo["notificatiedatum"] != nil {
                    contents.append(r.content)
                } else {
                    // Oude notificatie zonder userInfo: we tonen 'm ook,
                    // maar markeren dat de data onvolledig is.
                    contents.append(r.content)
                    hadError = true
                }
            }

            DispatchQueue.main.async {
                self.alerts = contents
                self.tableView.reloadData()

                if hadError {
                    let kentekens = filtered.map {
                        $0.content.body
                            .replacingOccurrences(of: "De APK van kenteken ", with: "")
                            .replacingOccurrences(of: " verloopt bijna!", with: "")
                            .replacingOccurrences(of: "Je hebt de app al een tijdje niet gebruikt, heb je geen vette auto's meer gespot?", with: "")
                    }.joined(separator: "\n")

                    self.dismiss(animated: true) {
                        self.ctx?.createAlert(
                            title: "Er heeft zich een fout voorgedaan",
                            message:
"""
Er is iets misgegaan tijdens het ophalen van de geplande notificaties.

De data kan niet volledig weergegeven worden.
Om dit te voorkomen moeten de APK-alerts opnieuw worden ingesteld.

Dit betreft de volgende kentekens:

\(kentekens)
""",
                            dismiss: true
                        )
                    }
                }
            }
        }
    }

    func setContext(ctx_: ViewController){
        self.ctx = ctx_
    }

    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        alerts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Gebruik .subtitle stijl -> niet registeren, maar zelf aanmaken indien nodig
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cellid")

        let content = alerts[indexPath.row]

        // Data
        let kenteken = (content.userInfo["kenteken"] as? String) ?? {
            // Fallback: parse uit body als userInfo ontbreekt
            let body = content.body
            if body.contains("De APK van kenteken ") && body.contains(" verloopt bijna!") {
                return body
                    .replacingOccurrences(of: "De APK van kenteken ", with: "")
                    .replacingOccurrences(of: " verloopt bijna!", with: "")
            }
            return "Onbekend"
        }()

        let notificatieDatumRaw = (content.userInfo["notificatiedatum"] as? String)
        let notificatieDatum: String = {
            guard let raw = notificatieDatumRaw,
                  let date = DateFormatter.yyyyMMdd.date(from: raw) else {
                return notificatieDatumRaw ?? ""
            }
            return DateFormatter.display.string(from: date)
        }()

        // Styling: "kaartje" feel
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .systemBackground
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true

        // Teksten
        cell.textLabel?.text = KentekenFactory().format(kenteken)
        cell.textLabel?.font = UIFont(name: "GillSans-Bold", size: 28) ?? UIFont.boldSystemFont(ofSize: 28)
        cell.textLabel?.textColor = .label
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.numberOfLines = 1

        cell.detailTextLabel?.text = notificatieDatum.isEmpty ? "—" : "Notificatie: \(notificatieDatum)"
        cell.detailTextLabel?.font = .systemFont(ofSize: 15)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.textAlignment = .center
        cell.detailTextLabel?.numberOfLines = 1

        // Schaduw / card look (optioneel, licht)
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 6
        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
        cell.layer.masksToBounds = false

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)

        guard let ctx = self.ctx else { return }

        let content = alerts[indexPath.row]
        // Probeer userInfo, fallback naar body
        let kenteken: String? = (content.userInfo["kenteken"] as? String) ?? {
            let body = content.body
            if body.contains("De APK van kenteken ") && body.contains(" verloopt bijna!") {
                return body
                    .replacingOccurrences(of: "De APK van kenteken ", with: "")
                    .replacingOccurrences(of: " verloopt bijna!", with: "")
            }
            return nil
        }()

        if let kenteken = kenteken {
            ctx.checkKenteken(kenteken: kenteken)
        }
    }
}

fileprivate extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        df.locale = Locale(identifier: "nl_NL")
        return df
    }()

    static let display: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        df.locale = Locale(identifier: "nl_NL")
        return df
    }()
}
