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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellid")
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = 80

        kentekens = StorageHelper().retrieveFromLocalStorage(storageType: StorageIdentifier.Recent)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        
        let padding: CGFloat = 20
        
        let img = UIImage(named: "kenteken-full.png")!
        img.withAlignmentRectInsets(UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        
        let imgFrame = UIImageView(image: img)
        imgFrame.contentMode = .scaleAspectFit
        
        cell.backgroundView = imgFrame
        
        cell.textLabel!.textAlignment = NSTextAlignment.center
        cell.textLabel!.font = UIFont(name: "GillSans", size: 36)
        cell.textLabel!.text = "   " + KentekenFactory().format(kentekens[indexPath.row].uppercased())
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("click")
        dismiss(animated: true, completion: nil)
        
        NetworkRequestHelper().kentekenRequest(kenteken: kentekens[indexPath.row], view: ctx!)
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}