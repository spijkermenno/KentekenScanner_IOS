//
//  CustomBottomSheetViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 27/12/2023.
//

import Foundation
import UIKit

class CustomBottomSheetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var gekentekendeVoertuig: GekentekendeVoertuig?
    var gekentekendVoertuigItems: [KeyValuePair] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        view.backgroundColor = .white

        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        if let temp = gekentekendeVoertuig?.generateKeyValueArray() {
            gekentekendVoertuigItems = temp
        } else {
            dismiss(animated: true)
        }

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
    
    func showSingleAlert(withMessage message: String) {
        let alertController = UIAlertController(title: "KentekenScanner", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        (parent as? ViewController)?.removeAdsButton.isHidden = true
        
        print(error.localizedDescription)
        
        showSingleAlert(withMessage: message)
    }
}
