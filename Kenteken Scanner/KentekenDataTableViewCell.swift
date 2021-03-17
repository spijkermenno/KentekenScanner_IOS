//
//  KentekenDataTableViewCell.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 16/03/2021.
//

import UIKit

class KentekenDataTableViewCell: UITableViewCell {
        
    @IBOutlet var titlefield: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
         
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
