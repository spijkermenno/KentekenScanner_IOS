//
//  kentekenDataTableViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import UIKit

class pendingNotificationTableViewController: UITableViewController {
    var ctx: ViewController?
    
    var alerts: [UNNotificationContent] = [UNNotificationContent]()
    var alertsMirror: Mirror!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = 100
        self.tableView.separatorStyle = .singleLine
        
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests(completionHandler: { requests in
            var error: Bool = false
            
            if (requests.count == 0) {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: {
                             self.ctx?.createAlert(title: "Geen data", message: "Er zijn nog geen notificaties ingesteld.", dismiss: true)
                        }
                    )
                }
            } else {

                for request in requests {
                                
                    if request.content.userInfo["notificatiedatum"] != nil {
                        self.alerts.append(request.content)
                    } else {
                        error = true
                    }
                }
                    
                if error {
                    var kentekens: String = ""
                    for request in requests {
                        let string = request.content.body.replacingOccurrences(of: "De APK van kenteken ", with: "").replacingOccurrences(of: " verloopt bijna!", with: "")
                        kentekens += "\(string) \n"
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: {() -> Void in
                        
                            
                            self.ctx?.createAlert(title: "Er heeft zich een fout voorgedaan", message: "Er is iets misgegaan tijdens het ophalen van de geplande notificaties. \n\n De data kan niet volledig weergegeven worden. \n\n Om deze fout in de toekomst te voorkomen moeten de APK-alerts opnieuw worden ingesteld. \n\n Dit betreft de volgende kentekens: \n\n \(kentekens)", dismiss: true)
                        })
                    }
                }
            }
        })
    }
    
    func setContext(ctx_: ViewController){
        self.ctx = ctx_
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }
     
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")

        
        cell.textLabel!.textAlignment = NSTextAlignment.center
        cell.textLabel!.font = UIFont(name: "GillSans", size: 36)

        cell.textLabel!.text = KentekenFactory().format(alerts[indexPath.row].userInfo["kenteken"] as! String)

        cell.detailTextLabel!.text = "\(alerts[indexPath.row].userInfo["notificatiedatum"] as! String)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click")
        dismiss(animated: true, completion: nil)
        
        NetworkRequestHelper().kentekenRequest(kenteken: alerts[indexPath.row].userInfo["kenteken"] as! String, view: ctx!)
    }
}
