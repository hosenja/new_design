//
//  GroupMediaCell.swift
//  Snapgroup
//
//  Created by snapmac on 25/12/2018.
//  Copyright © 2018 Black. All rights reserved.
//

import UIKit

class GroupMediaCell: UITableViewCell {

    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .red
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var daysCount: UILabel!
    @IBOutlet weak var group_label: UILabel!
    @IBOutlet weak var group_image: UIImageView!
    @IBOutlet weak var group_date: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var slashImage: UIImageView!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var viewPrice: UIStackView!


    public func makeCity(_ city: GroupItemObject){
        
        if city.images != nil && (city.images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (city.images?[0].path)!
            self.group_image.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            if city.image != nil {
                let urlPhotot  = ApiRouts.Media + (city.image)!
                
                self.group_image.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
            }else {
                self.group_image.image = UIImage(named: "img-default")
            }
           // self.group_image.image = UIImage(named: "img-default")
        }
        if city.translations != nil && (city.translations?.count)! >  0 {
            self.group_label.text = (city.translations?[0].title)!
            
        }
        if city.rotation != nil && (city.rotation)! == "reccuring"
        {
          self.daysCount.text = ""
            self.group_date.text = city.frequency != nil ? "\((city.frequency)!.capitalizingFirstLetter()) Tour": ""
        }else
        {
            self.daysCount.text = "\((city.days)!) Days"
            self.group_date.text = "\(city.start_date!.split(separator: "-")[2]) \(getMonthName(month: String(city.start_date!.split(separator: "-")[1]))) \(city.start_date!.split(separator: "-")[0]) "
            
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
                self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy)))"
                
            }else {
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    
                    self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
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
    func getMonthName(month: String) -> String{
        switch month {
        case "01":
            return "Jan"
        case "02":
            return "Feb"
        case "03":
            return "Mar"
        case "04":
            return "Apr"
        case "05":
            return "May"
        case "06":
            return "Jun"
        case "07":
            return "Jul"
        case "08":
            return "Aug"
        case "09":
            return "Sep"
        case "10":
            return "Oct"
        case "11":
            return "Nov"
        case "12":
            return "Dec"
        default:
            return "null"
        }
    }
    
    func setCityState(_ state: FCityState){
//        if state == .Paid {
//            imgState.image = UIImage(named: "icon-locked")
//        }
//        else if state == .Offline {
//            imgState.image = UIImage(named: "icon-available-offline")
//        }
//        else {
//            imgState.image = nil
//        }
    }
    
    
    static func cellHeight() -> CGFloat {
        return 140
    }
}
