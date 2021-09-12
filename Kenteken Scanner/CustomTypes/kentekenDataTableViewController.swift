//
//  kentekenDataTableViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import UIKit

class kentekenDataTableViewController: UITableViewController {
    var kentekens: [String] = [];
    var ctx: ViewController?
    
    var storageType: StorageIdentifier!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = 100
        self.tableView.separatorStyle = .none

        kentekens = StorageHelper().retrieveFromLocalStorage(storageType: storageType)
        
        print(kentekens)
        print(kentekens.count)
        
        if kentekens.count == 0 {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: {
                         self.ctx?.createAlert(title: "Geen data", message: "Er zijn nog geen kentekens opgeslagen.", dismiss: true)
                    }
                )
            }
        }
    }
    
    func setStorageIdentifier(identifier: StorageIdentifier) {
        self.storageType = identifier
    }
    
    func setContext(ctx_: ViewController){
        self.ctx = ctx_
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kentekens.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cellId")
        
        let img = UIImage(named: "kentekenplaat")!
        
        let imgFrame = UIImageView(image: img)
    
        imgFrame.contentMode = .scaleAspectFit
        
        cell.backgroundView = imgFrame
        
        cell.textLabel!.textAlignment = NSTextAlignment.center
        cell.textLabel!.font = UIFont(name: "GillSans", size: 42)
        cell.textLabel!.text = "   " + KentekenFactory().format(kentekens[indexPath.row].uppercased())
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click")
        dismiss(animated: true, completion: nil)
        
        NetworkRequestHelper().kentekenRequest(kenteken: kentekens[indexPath.row], view: ctx!)
        
        if storageType == StorageIdentifier.Favorite {
            AnalyticsHelper().logEvent(eventkey: "favorite_search", key: "kenteken", value: kentekens[indexPath.row])
        } else {
            AnalyticsHelper().logEvent(eventkey: "recent_search", key: "kenteken", value: kentekens[indexPath.row])
        }
    }
}
