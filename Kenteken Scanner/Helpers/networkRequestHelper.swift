//
//  networkRequestHelper.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 22/03/2021.
//
import UIKit
import StoreKit
import Foundation

class NetworkRequestHelper {
    var filling = false
    var alert = false
    
    func kentekenRequest(kenteken: String, view: ViewController) {
        print("req")
        
        var amountRequests: Int = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.CountRequests)
        var rd: Int = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.RequestsDone)
        if rd == 0 {
            rd = 1
        }
        
        if rd >= 5 {
            rd = 1
        }
        
        print(amountRequests)
        
        if amountRequests >= view.requestInterval * rd {
            amountRequests = 1
            self.alert = true
            
            rd += 1
            
            StorageHelper().saveToLocalStorage(amount: rd, storageType: StorageIdentifier.RequestsDone)

            } else {
                amountRequests += 1
            }
                        
            StorageHelper().saveToLocalStorage(amount: amountRequests, storageType: StorageIdentifier.CountRequests)
        
        
        view.toggleSpinner(onView: view.view) // toggling the spinner on.
        let urlString : String = "https://mennospijker.nl/api/kenteken/" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        let url = URL(string: urlString)!
        
        view.kentekenField.text = KentekenFactory().format(kenteken)
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 7.0
   
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
            
            if error != nil {
                DispatchQueue.main.async {
                    self.backupKentekenRequest(kenteken: kenteken, view: view)
                }
                return
            } else {
            
                guard let data = data else {
                    print("guard err")
                    DispatchQueue.main.async {
                        DispatchQueue.main.async {
                            self.backupKentekenRequest(kenteken: kenteken, view: view)
                        }
                    }
                    return
                }
                
                let decoder = JSONDecoder()
                if let dataObject = try? decoder.decode([kentekenDataObject].self, from: data) {
                    
                    if dataObject.first?.kenteken != nil {
                        DispatchQueue.main.async {
                            self.fillTable(kenteken: kenteken, view: view, dataObject: dataObject, backuprequest: false)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.backupKentekenRequest(kenteken: kenteken, view: view)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func backupKentekenRequest(kenteken: String, view: ViewController) {
        print("BACKUP REQUEST")
        let urlString : String = "https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken=" + kenteken.replacingOccurrences(of: "-", with: "").uppercased()
        let url = URL(string: urlString)!
           
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("back guard error")
                view.toggleSpinner(onView: view.view)
                return
            }
            
            let decoder = JSONDecoder()
            let dataObject = try! decoder.decode([kentekenDataObject].self, from: data)
            
            print(dataObject)
            
            if dataObject.count > 0 {
                print("show data")
                DispatchQueue.main.async {
                    self.fillTable(kenteken: kenteken, view: view, dataObject: dataObject, backuprequest: true)
                }
            } else {
                print("show error")
                // no kenteken found, show dialog.
                DispatchQueue.main.async {
                    view.createAlert(title: "Kenteken niet gevonden", message: "Het kenteken \(KentekenFactory().format(kenteken)) kan niet worden gevonden in de database. \n\n Dit betekent niet direct dat het kenteken niet bestaat. Kentekens welke nog geen datum eerste toelating hebben zijn nog niet toegevoegd aan de database.", dismiss: true)
                    view.kentekenField.text = nil
                    print("error")
                    
                    view.isSpinning = true
                    view.toggleSpinner(onView: view.view)

                }
            }
        }

        task.resume()
    }
    
    func fillTable(kenteken: String, view: ViewController, dataObject: [kentekenDataObject], backuprequest: Bool ) {
        
        if self.alert    {
            let alert = UIAlertController(title: "Wat leuk dat je de app gebruikt!", message: "Support ons door een recensie achter te laten, een suggestie te geven of door eens een kijkje te nemen bij de advertentie!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Recensie plaatsen", style: .default, handler: {
                                            (alert: UIAlertAction!) in
                DispatchQueue.main.async {

                    if let scene = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
                
                self.tableFilling(kenteken: kenteken, view: view, dataObject: dataObject, backuprequest: backuprequest)

            }))
            
            alert.addAction(UIAlertAction(title: "Doorgaan", style: .cancel, handler: {
                                            (alert: UIAlertAction!) in
                self.tableFilling(kenteken: kenteken, view: view, dataObject: dataObject, backuprequest: backuprequest)
            }))

            view.present(alert, animated: true)
            print("presented alert")
            
            self.alert = false
        } else {
            tableFilling(kenteken: kenteken, view: view, dataObject: dataObject, backuprequest: backuprequest)
        }
        // need to close spinner
        view.isSpinning = true
       view.toggleSpinner(onView: view.view)
//
    }
    
    func tableFilling(kenteken: String, view: ViewController, dataObject: [kentekenDataObject], backuprequest: Bool ) -> Void {
        var recents: [String] = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent);

        if recents.contains(kenteken.replacingOccurrences(of: "-", with: "").uppercased()) {
            recents.remove(at: recents.firstIndex(of: kenteken.replacingOccurrences(of: "-", with: "").uppercased())!)
        }

        recents.insert(kenteken.replacingOccurrences(of: "-", with: "").uppercased(), at: 0);

        StorageHelper().saveToLocalStorage(arr: recents, storageType: StorageIdentifier.Recent)

        view.kentekenField.text = KentekenFactory().format(kenteken)

        let dataTableViewObj:dataTableView = dataTableView()

        if backuprequest {
            dataTableViewObj.isBackupRequest()
        }

        dataTableViewObj.loadData(object: dataObject.first!)
        dataTableViewObj.setKenteken(kenteken_: kenteken)
        dataTableViewObj.setContext(context_: view)
        view.present(dataTableViewObj, animated: true, completion: nil)
        print("filltable")
    }
}
