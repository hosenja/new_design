//
//  SearchCell.swift
//  Snapgroup
//
//  Created by snapmac on 22/01/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var googlePlaceText: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
