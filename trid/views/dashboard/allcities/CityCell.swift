//
//  CityCell.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage
import SwipeCellKit

class CityCell: SwipeTableViewCell {

    static let className = "CityCell"
    
    
     @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var imgBackground: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelVisitor: UILabel!
    @IBOutlet weak var imgState: UIImageView!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var labelComingSoon: UILabel!
    
    /// pprice stack
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var viewPrice: UIStackView!
    
    var openVideoIntro : (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func makeCity(_ city: GroupItemObject){
        self.labelName.text = (city.translations?[0].title)!
        self.labelVisitor.text = (city.translations?[0].destination)!
        if city.images != nil && (city.images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (city.images?[0].path)!
            self.imgBackground.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            if city.image != nil {
                let urlPhotot  = ApiRouts.Media + (city.image)!

                self.imgBackground.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
            }else {
            self.imgBackground.image = UIImage(named: "img-default")
            }
        }
        
        let defaults = UserDefaults.standard
        let currentCurrency = defaults.string(forKey: "currentCurrency")
        if city.prices != nil && (city.prices?.count)! > 0 {
            self.currencyLbl.text = ""
            self.viewPrice.isHidden = false
            getCurrencyType(currencyType: currentCurrency!, city: city)
        }else {
            self.currencyLbl.text =  ""
            self.viewPrice.isHidden = true
        }
        
        
    }
    func getCurrencyType(currencyType: String, city: GroupItemObject)  {
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        let current_currency = defaults.float(forKey: "current_currency")
        var price_with_currancy: Float = 1
        
        var flag: Bool = false
        //print("currencyType \(currencyType)")
        for currency in (city.prices?[0].currencies)! {
            
            if currency.type == currencyType {
                flag = true
                if (currency.special_price)  != nil{
                    
                    self.newPrice.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                   
                }else {
                    if currency.price != nil {
                        
                        self.newPrice.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                    }else
                    {
                        self.currencyLbl.text = ""
                        self.oldPriceView.isHidden = true
                        self.newPrice.text = ""
                        
                    }
                }
                return
                
            }
        }
        if !flag {
            if currencyType == "gbp" {
                self.currencyLbl.text = ""
            }else {
                self.currencyLbl.text = ""
            }
            if (city.prices?[0].currencies?[0].special_price)  != nil{
                price_with_currancy = (city.prices?[0].currencies?[0].special_price)! * current_currency
                self.newPrice.text = "£\(((city.prices?[0].currencies?[0].special_price)!))"
                self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy))))"

            }else {
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    
                    self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy))))))"
                    self.newPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                  
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    self.currencyLbl.text = ""
                    
                }
            }
            
        }
        
    }
    
    func setCityState(_ state: FCityState){
        if state == .Paid {
            imgState.image = UIImage(named: "icon-locked")
        }
        else if state == .Offline {
            imgState.image = UIImage(named: "icon-available-offline")
        }
        else {
            imgState.image = nil
        }
    }
    
    @IBAction func actionPlayVideo(_ sender: Any) {
        if openVideoIntro != nil {
            openVideoIntro!()
        }
    }
    
    static func cellHeight() -> CGFloat {
        return 200
    }
}
