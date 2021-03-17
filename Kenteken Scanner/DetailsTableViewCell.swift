//
//  DetailsTableViewCell.swift
//  Kenteken Scanner
//
//  Created by Menno Spijker on 17/03/2021.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {

    @IBOutlet var titlefield: UILabel!
    @IBOutlet var valuefield: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
