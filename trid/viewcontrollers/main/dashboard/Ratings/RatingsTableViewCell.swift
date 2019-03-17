//
//  RatingsTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 05/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import FloatRatingView

class RatingsTableViewCell: UITableViewCell {
   
    
    
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var reviewLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    func updateCell(rate:RatingModel)  {
        self.fullNameLbl.text = "\((rate.fullname) != nil ? (rate.fullname)! : "")"
        self.reviewLbl.text = "\((rate.review)!) "
        self.floatRatingView.rating = Float((rate.rating)!)
        self.floatRatingView.backgroundColor = UIColor.clear
        self.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        
    }
  

}
