//
//  SearchGroupTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 05/03/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit

class SearchGroupTableViewCell: UITableViewCell {

    @IBOutlet weak var groupImg: UIImageView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    
    public func makeCity(_ city: SearchStruct){
        if city.type != nil && (city.type)! == "companies" {
            self.groupTitleLbl.text = (city.name != nil ? city.name : "")!

        }else {
        self.groupTitleLbl.text = (city.title != nil ? city.title : "")!
        }
//        if city.image != nil {
//            let urlPhotot  = ApiRouts.Media + (city.image)!
//            self.groupImg.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
//        }else {
//            self.groupImg.image = UIImage(named: "img-default")
//        }
    }
    static func cellHeight() -> CGFloat {
        return 50
    }
    
}
