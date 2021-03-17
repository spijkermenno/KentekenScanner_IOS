//
//  dataTableView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import UIKit

class dataTableView: UITableViewController {
    var kentekenData: kentekenDataObject?
    var keys = [Int: String]()
    var values = [Int: String]()
    
    let cellIdentifier = "cellid"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
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
        
            keys[i] = key.replacingOccurrences(of: "_", with: " ")
            values[i] = value
            
            i += 1
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = keys[indexPath.row]
        cell.detailTextLabel?.text = values[indexPath.row]
                
        return cell
    }
}
