//
//  networkRequestHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//

import Foundation

class NetworkRequestHelper {
    func kentekenRequest(kenteken: String, view: ViewController) {
        view.showSpinner(onView: view.view)
        //let urlString : String = "https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken=" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        let urlString : String = "https://mennospijker.nl/api/kenteken/" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        let url = URL(string: urlString)!
        
        view.kentekenField.text = KentekenFactory().format(kenteken)
   
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                view.removeSpinner()
                return
            }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            if dataObject.first?.kenteken != nil {
                DispatchQueue.main.async {
                    self.fillTable(kenteken: kenteken, view: view, dataObject: dataObject)
                }
            } else {
                DispatchQueue.main.async {
                    self.backupKentekenRequest(kenteken: kenteken, view: view)
                }
            }
        }
        print("end task")
        task.resume()
    }
    
    func backupKentekenRequest(kenteken: String, view: ViewController) {
        print("BACKUP REQUEST")
        let urlString : String = "https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken=" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        let url = URL(string: urlString)!
           
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                view.removeSpinner()
                return
            }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            print(dataObject)
            
            if dataObject.count > 0 {
                print("show data")
                DispatchQueue.main.async {
                    self.fillTable(kenteken: kenteken, view: view, dataObject: dataObject)
                }
            } else {
                print("show error")
                // no kenteken found, show dialog.
                DispatchQueue.main.async {
                    view.createAlert(title: "Kenteken niet gevonden", message: "het kenteken \(KentekenFactory().format(kenteken)) kan niet worden gevonden in de database.", dismiss: true)
                    view.kentekenField.text = nil
                    view.removeSpinner()
                }
                print("show error finish")
            }
        }
        print("end backup task")

        task.resume()
    }
    
    func fillTable(kenteken: String, view: ViewController, dataObject: [kentekenDataObject]) {
        var recents: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent);
        
        if recents.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()) {
            recents.remove(at: recents.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())!)
        }
    
        recents.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);
                            
        StorageHelper().saveToLocalStorage(arr: recents, storageType: StorageIdentifier.Recent)
        
        view.kentekenField.text = KentekenFactory().format(kenteken)
        
        let dataTableViewObj:dataTableView = dataTableView()
        dataTableViewObj.loadData(object: dataObject.first!)
        dataTableViewObj.setKenteken(kenteken_: kenteken)
        dataTableViewObj.setContext(context_: view)
        view.removeSpinner()
        view.present(dataTableViewObj, animated: true, completion: nil)
    }

}
