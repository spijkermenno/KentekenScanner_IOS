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
            
            if data.count > 0 {
                var recents: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent);
                
                if recents.contains(kenteken) {
                    recents.remove(at: recents.firstIndex(of: kenteken)!)
                }
            
                recents.insert(kenteken, at: 0);

                StorageHelper().saveToLocalStorage(arr: recents, storageType: StorageIdentifier.Recent)
                
                print("Currently saved kentekens: ")
                print(StorageHelper().retrieveFromLocalStorage(storageType:StorageIdentifier.Recent))
            }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            DispatchQueue.main.async {
                let dataTableViewObj:dataTableView = dataTableView()
                dataTableViewObj.loadData(object: dataObject.first!)
                view.present(dataTableViewObj, animated: true, completion: nil)
            }
        }
        task.resume()
    }
}
