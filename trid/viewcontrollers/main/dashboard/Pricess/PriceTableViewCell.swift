//
//  PriceTableViewCell.swift
//  Snapgroup
//
//  Created by snapmac on 17/01/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit

class PriceTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var priceType: UILabel!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public func makeCell(_ priceObj: PriceObject?,_ indexRow: Int){

        self.priceType.text = priceObj?.type != nil ? (priceObj?.type)! : "price\((indexRow + 1))"
        
        
        let defaults = UserDefaults.standard
        let currentCurrency = defaults.string(forKey: "currentCurrency")
        getCurrencyType(currencyType: currentCurrency!, city: priceObj!)
        
        
        
    }
    func getCurrencyType(currencyType: String, city: PriceObject)  {
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        let current_currency = defaults.float(forKey: "current_currency")
        var price_with_currancy: Float = 1
        
        var flag: Bool = false
        print("currencyType \(currencyType)")
        for currency in (city.currencies)! {
            if currency.type == currencyType {
                flag = true
                self.currencyLbl.isHidden = true
                if (currency.special_price)  != nil{
                    
                    self.price.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                    if currency.price != nil {
                        
                        self.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", (currency.price)!)))))"
                        self.oldPriceView.isHidden = false
                    }else
                    {
                        self.oldPrice.text = ""
                        self.oldPriceView.isHidden = true
                        
                    }
                }else {
                    if currency.price != nil {
                        
                        self.price.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                        self.oldPriceView.isHidden = true
                        self.oldPrice.text = ""
                    }else
                    {
                        self.price.text = ""
                        self.oldPriceView.isHidden = true
                        self.oldPrice.text = ""
                        
                    }
                }
                return
                
            }
        }
        if !flag {
            if currencyType == "gbp" {
                self.currencyLbl.isHidden = true
            }else {
                self.currencyLbl.isHidden = false
            }
            if (city.currencies?[0].special_price)  != nil{
                price_with_currancy = (city.currencies?[0].special_price)! * current_currency
                self.price.text = "£\(((city.currencies?[0].special_price)!))"
                self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy))))"
                if city.currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.currencies?[0].price)!))) * current_currency
                  
                    self.oldPrice.text = "£\(((city.currencies?[0].price)!))"
                    self.oldPriceView.isHidden = false
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    
                }
            }else {
                if city.currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.currencies?[0].price)!))) * current_currency
                    
                    self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy))))))"
                    self.price.text = "£\(((city.currencies?[0].price)!))"
                    self.oldPriceView.isHidden = true
                    self.oldPrice.text = ""
                }else
                {
                    self.price.text = ""
                    self.oldPrice.isHidden = true
                    self.oldPrice.text = ""
                    
                }
            }
            
        }
        
    }
    
    
    

}
