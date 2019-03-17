//
//  SearchPlaceTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 05/03/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit

class SearchPlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var groupTitleLbl: UILabel!
    
    public func makeCity(_ city: SearchStruct){
        self.groupTitleLbl.text = (city.description != nil ? city.description : "")!
    }
    static func cellHeight() -> CGFloat {
        return 50
    }

}
