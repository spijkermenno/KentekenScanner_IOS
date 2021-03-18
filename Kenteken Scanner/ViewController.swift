//
//  ViewController.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 15/03/2021.
//

import UIKit

enum StorageIdentifier {
    case Favorite, Recent
}

class ViewController: UIViewController {
    let favoriteStorageIdentifier: String = "Favorite"
    let recentStorageIdentifier: String = "Recent"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func KentekenHandler(_ sender: UITextField, forEvent event: UIEvent) {
        let enteredKenteken : String = sender.text!
        //check if valid kenteken
        sender.text = (formatKenteken(enteredKenteken))
        
        if getSidecode(enteredKenteken) != -2 {
            apiCall(kenteken: enteredKenteken);
        }
    }
    
    func saveToLocalStorage(string: String, storageType: StorageIdentifier) {
        let defaults = UserDefaults.standard
        
        if storageType == StorageIdentifier.Favorite {
            defaults.set(string, forKey: favoriteStorageIdentifier)
        } else if storageType == StorageIdentifier.Recent {
            defaults.set(string, forKey: recentStorageIdentifier)
        }
    }
    
    func retrieveFromLocalStorage(storageType: StorageIdentifier) -> String {
        let defaults = UserDefaults.standard
        if storageType == StorageIdentifier.Favorite {
            if let result = defaults.string(forKey: favoriteStorageIdentifier) {
                return result
            }
        } else if storageType == StorageIdentifier.Recent {
            if let result = defaults.string(forKey: recentStorageIdentifier) {
                return result
            }
        }
        return "Error: storage indentifier invalid"
    }
    
    func apiCall(kenteken: String) -> Bool {
        let urlString : String = "https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken=" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        
        print(urlString)
   
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            
            if data.count > 0 {
                self.saveToLocalStorage(string: kenteken, storageType: StorageIdentifier.Recent)
                print(self.retrieveFromLocalStorage(storageType: StorageIdentifier.Recent))
            }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            DispatchQueue.main.async {
                let dataTableViewObj:dataTableView = dataTableView()
                dataTableViewObj.loadData(object: dataObject.first!)
                self.present(dataTableViewObj, animated: true, completion: nil)
            }
        }
        task.resume()
    
        return false;
    }
    
    func formatKenteken(_ kenteken: String) -> String {
        let sidecode = getSidecode(kenteken);
        
        var fixedkenteken = kenteken.uppercased()
        fixedkenteken = fixedkenteken.replacingOccurrences(of: "-", with: "")
        
        // Not a valid kenteken
        if (sidecode == -2) {
            return fixedkenteken;
        }
        
        let kenteken = Array(fixedkenteken);
        
        if (sidecode <= 6) {
            return String(kenteken[0..<2]) + "-" + String(kenteken[2..<4]) + "-" + String(kenteken[4..<6])
        }
        
        if (sidecode == 7 || sidecode == 9) {
            return String(kenteken[0..<2]) + "-" + String(kenteken[2..<5]) + "-" + String(kenteken[5..<6])
        }
        
        if (sidecode == 8 || sidecode == 10) {
            return String(kenteken[0..<1]) + "-" + String(kenteken[1..<4]) + "-" + String(kenteken[4..<6])
        }
        
        if (sidecode == 11 || sidecode == 14) {
            return String(kenteken[0..<3]) + "-" + String(kenteken[3..<5]) + "-" + String(kenteken[5..<6])
        }
        
        if (sidecode == 12 || sidecode == 13) {
            return String(kenteken[0..<1]) + "-" + String(kenteken[1..<3]) + "-" + String(kenteken[3..<6])
        }
        
        return fixedkenteken
    }
    
    func getSidecode(_ kenteken: String) -> Int {
        let kenteken = kenteken.replacingOccurrences(of: "-", with: "")
        
        let patterns: [Int: String] = [
            0: "^[a-zA-Z]{2}[0-9]{2}[0-9]{2}$", // 1 XX-99-99
            1: "^[0-9]{2}[0-9]{2}[a-zA-Z]{2}$", // 2 99-99-XX
            2: "^[0-9]{2}[a-zA-Z]{2}[0-9]{2}$", // 3 99-XX-99
            3: "^[a-zA-Z]{2}[0-9]{2}[a-zA-Z]{2}$", // 4 XX-99-XX
            4: "^[a-zA-Z]{2}[a-zA-Z]{2}[0-9]{2}$", // 5 XX-XX-99
            5: "^[0-9]{2}[a-zA-Z]{2}[a-zA-Z]{2}$", // 6 99-XX-XX
            6: "^[0-9]{2}[a-zA-Z]{3}[0-9]{1}$", // 7 99-XXX-9
            7: "^[0-9]{1}[a-zA-Z]{3}[0-9]{2}$", // 8 9-XXX-99
            8: "^[a-zA-Z]{2}[0-9]{3}[a-zA-Z]{1}$", // 9 XX-999-X
            9: "^[a-zA-Z]{1}[0-9]{3}[a-zA-Z]{2}$", // 10 X-999-XX
            10: "^[a-zA-Z]{3}[0-9]{2}[a-zA-Z]{1}$", // 11 XXX-99-X
            11: "^[a-zA-Z]{1}[0-9]{2}[a-zA-Z]{3}$", // 12 X-99-XXX
            12: "^[0-9]{1}[a-zA-Z]{2}[0-9]{3}$", // 13 9-XX-999
            13: "^[0-9]{3}[a-zA-Z]{2}[0-9]{1}$" // 14 999-XX-9
        ]
        
        let range = NSRange(location: 0, length: kenteken.utf16.count)
        
        for (key, regpattern) in patterns {
            let regex = try! NSRegularExpression(pattern: regpattern)
            if (regex.firstMatch(in: kenteken, options: [], range: range) != nil) {
                return key + 1
            }
        }
        
        return -2;
    }
    
}

