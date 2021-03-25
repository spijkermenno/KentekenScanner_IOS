//
//  networkRequestHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation

class NetworkRequestHelper {
    func kentekenRequest(kenteken: String, view: ViewController) {
        let urlString : String = "https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken=" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        
        print(urlString)
   
        let url = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            if dataObject.count > 0 {
                DispatchQueue.main.async {
                    var recents: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent);
                    
                    if recents.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()) {
                        recents.remove(at: recents.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())!)
                    }
                
                    recents.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                                        
                    StorageHelper().saveToLocalStorage(arr: recents, storageType: StorageIdentifier.Recent)
                    
                    print("Currently saved kentekens: ")
                    print(StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Recent))
                    
                    view.kentekenField.text = KentekenFactory().format(kenteken)
                    
                    let dataTableViewObj:dataTableView = dataTableView()
                    dataTableViewObj.loadData(object: dataObject.first!)
                    dataTableViewObj.setKenteken(kenteken_: kenteken)
                    view.present(dataTableViewObj, animated: true, completion: nil)
                }
            } else {
                // no kenteken found, show dialog.
                DispatchQueue.main.async {
                    view.createAlert(title: "Kenteken niet gevonden", message: "het kenteken \(kenteken) kan niet worden gevonden in de database.", dismiss: true)
                }
            }
        }
        task.resume()
    }
}
