//
//  dataTableView.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import UIKit
import Firebase

class dataTableView: UITableViewController {
    var kentekenData: kentekenDataObject?
    var keys = [Int: String]()
    var values = [Int: String]()
    var buttonOrder: CGFloat = 0
    var kenteken: String!
    
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
    
    @objc func favoriteTap(_ button: UIButton) {
        var favorites: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Favorite);
        print(favorites)
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
            
            print("Currently saved kentekens: ")
            print(StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Favorite))
            
            button.setImage(UIImage(systemName: "star.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
    }
    
    @objc func shareTap(_ button: UIButton) {
        let items = [URL(string: String("https://www.mennospijker.nl/kenteken/?kenteken=" + kenteken))!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(favoriteButton)
            view.addSubview(shareButton)
            
            if StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Favorite).contains(kenteken) {
                self.createButton(button: favoriteButton, icon: UIImage(systemName: "star.fill")!)
            } else {
                self.createButton(button: favoriteButton, icon: UIImage(systemName: "star")!)
            }
            self.createButton(button: shareButton, icon: UIImage(systemName: "square.and.arrow.up")!)
        }
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
    
    func setKenteken(kenteken_: String) {
        self.kenteken = kenteken_
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
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cellId")
        
        cell.textLabel?.text = keys[indexPath.row]
        cell.detailTextLabel?.text = values[indexPath.row]
                
        return cell
    }
}
