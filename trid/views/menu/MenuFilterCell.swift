//
//  MenuFilterCell.swift
//  Snapgroup
//
//  Created by snapmac on 26/12/2018.
//  Copyright © 2018 Black. All rights reserved.
//

import UIKit

class MenuFilterCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var gridView: UIView!
    @IBOutlet weak var instaView: UIView!
    @IBOutlet weak var listView: UIView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
