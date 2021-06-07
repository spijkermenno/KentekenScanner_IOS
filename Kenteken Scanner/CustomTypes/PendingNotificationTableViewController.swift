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
            for request in requests {
                    self.alerts.append(request.content)
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
