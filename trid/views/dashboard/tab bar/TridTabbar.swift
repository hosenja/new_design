//
//  TridTabbar.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import PureLayout

protocol TridTabbarProtocol {
    func tabbarShowAllCities()
    func tabbarShowGuide()
    func tabbarShowFavorite()
    func tabbarAdd()
    func tabbarShowAskAndShare()
}

class TridTabbar: UIView {
    // delegate
    var delegate : TridTabbarProtocol?
    
    // outlet
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var oldPriceView: UIView!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var interyView: UIView!
    @IBOutlet weak var footerInterry: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnAddTip: UIButton!
    
    //var btnAllCities: TabbarButton!
    var btnGuide: TabbarButton!
    var btnFavorite: TabbarButton!
    var btnAskShare: TabbarButton!
    
    class func createTabbar() -> TridTabbar{
        let tab = UINib(nibName: "TridTabbar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? TridTabbar
        return tab!;
    }
    public func getViewHeight () -> CGFloat{
        return self.viewContent.frame.height
    }
    override func awakeFromNib() {
        // calculate
        var tabwidth : CGFloat = (AppSetting.App.screenSize.width)/5
        if tabwidth < 80 {
            tabwidth = 70
        }
        else if tabwidth > 90 {
            tabwidth = 90
        }
        
        // Add TIP
        btnAddTip.setTitle(Localized.Ask, for: .normal)
        btnAddTip.layer.cornerRadius = btnAddTip.bounds.height/2.0
        btnAddTip.layer.shadowRadius = 2
        btnAddTip.layer.shadowColor = UIColor(hex6: UInt32(AppSetting.Color.veryLightGray), alpha: 0.3).cgColor
        

        self.btnGuide = TabbarButton.initWithTitle(Localized.Explore, image: "Artboard 2", imageSelected: "footerItinerary-1")
        btnGuide.backgroundColor = .clear
        self.viewContent.addSubview(self.btnGuide)
        
        // ask and share
        self.btnAskShare = TabbarButton.initWithTitle(Localized.AskShare, image: "footerservices", imageSelected: "Artboard 2 copy 5")
        btnAskShare.backgroundColor = .clear
        self.viewContent.addSubview(self.btnAskShare)
        
        
        // fav
        self.btnFavorite = TabbarButton.initWithTitle(Localized.Saved, image: "footerterms-1", imageSelected: "Artboard 2 copy 3")
        btnFavorite.backgroundColor = .clear
        self.viewContent.addSubview(self.btnFavorite)
        

        // guide
        btnGuide.addTarget(self, action: #selector(TridTabbar.actionTabGuide), for: UIControl.Event.touchUpInside)
        btnGuide.isSelected = true
        btnGuide.tag = 0
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.leading, withInset: 5)
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.top)
        btnGuide.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnGuide.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        
        // fav
        btnFavorite.addTarget(self, action: #selector(TridTabbar.actionFavorite), for: UIControl.Event.touchUpInside)
        btnFavorite.tag = 1
        self.btnFavorite.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: self.btnAskShare)
        self.btnFavorite.autoPinEdge(toSuperviewEdge: ALEdge.top)
        self.btnFavorite.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnFavorite.autoSetDimension(ALDimension.width, toSize: tabwidth)
        
        // ask
      
        btnAskShare.addTarget(self, action: #selector(TridTabbar.actionAskAndShare), for: UIControl.Event.touchUpInside)
        btnAskShare.tag = 2
        self.btnAskShare.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: self.btnGuide)
        self.btnAskShare.autoPinEdge(toSuperviewEdge: ALEdge.top)
        self.btnAskShare.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        btnFavorite.autoSetDimension(ALDimension.width, toSize: tabwidth)
        if AppState.currentGroup?.group_conditions == nil {
            self.btnFavorite.isHidden = true
        }else {
            if AppState.currentGroup?.has_services != nil &&  (AppState.currentGroup?.has_services)! == false {
                self.btnAskShare.isHidden = true
                self.btnFavorite.autoPinEdge(ALEdge.leading, to: ALEdge.trailing, of: self.btnGuide)
            }
        }
        if AppState.currentGroup?.has_services != nil &&  (AppState.currentGroup?.has_services)! == false {
            print("Im insedddddd")
            self.btnAskShare.isHidden = true
        }

        // set selected tab
      //  selectedOnTab(index: AppState.shared.selectedTab)
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
    
    func setTripTimeDuration(startDate: String, endDate: String){
        
        
        let startMonth: String = self.getMonthName(month: startDate[5..<7])
        let endMonth: String = self.getMonthName(month: endDate[5..<7])
        let startDay: String = startDate[8..<10]
        let endDay: String = endDate[8..<10]
        print("endMonth date = \(endMonth)")
        print("startDate = \(startDate), startMonth date = \(startDate[5..<7])")
        print("startDay date = \(startDay)")
        print("endDay date = \(endDay)")
        if startMonth == endMonth
        {
            if startDay == endDay{
                dateLbl.text = startDay + " " + endMonth
            }
            else{
                dateLbl.text = startDay+"-" + endDay+" "+endMonth + " | \((AppState.currentGroup?.days_count)!) Days"
            }
            
        }else{
            
            dateLbl.text = startDay+" "+startMonth + " - " + endDay+" "+endMonth + " | \((AppState.currentGroup?.days_count)!) Days"
        }
        
        
        
        
    }

    func setBarHide() {
        self.btnAskShare.isHidden = true
        self.btnFavorite.isHidden = true
        self.btnGuide.isHidden = true
        let defaults = UserDefaults.standard
        let currentCurrency = defaults.string(forKey: "currentCurrency")
        if AppState.currentGroup?.prices != nil && (AppState.currentGroup?.prices?.count)! > 0 {
            
            getCurrencyType(currencyType: currentCurrency!, city: AppState.currentGroup!)
        }else {
            self.currencyLbl.text =  ""
            self.oldPriceView.isHidden = true
            self.newPrice.text = ""
        }
        

        self.interyView.isHidden = false
        if AppState.currentGroup?.rotation != nil && (AppState.currentGroup?.rotation)! == "reccuring"
        {
            dateLbl.text = "\(AppState.currentGroup?.frequency != nil ? "\((AppState.currentGroup?.frequency)!.capitalizingFirstLetter()) Tour ": "")"
        }else {
            setTripTimeDuration(startDate: (AppState.currentGroup?.start_date)!, endDate: (AppState.currentGroup?.end_date)!)
        }
    }
    func getCurrencyType(currencyType: String, city: TourGroup)  {
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        let current_currency = defaults.float(forKey: "current_currency")
        var price_with_currancy: Float = 1
        
        var flag: Bool = false
        print("currencyType \(currencyType)")
        for currency in (city.prices?[0].currencies)! {
            if currency.type == currencyType {
                flag = true
                self.currencyLbl.isHidden = true
                
                if (currency.special_price)  != nil{
                    
                    self.newPrice.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                   
                    if currency.price != nil {
                        
                        self.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", (currency.price)!)))))"
                       
                        self.oldPriceView.isHidden = false
                    }else
                    {
                        self.oldPriceView.isHidden = true
                        self.oldPrice.text = ""
                       
                        
                    }
                }else {
                    if currency.price != nil {
                        
                        self.newPrice.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                        
                        self.oldPriceView.isHidden = true
                        self.oldPrice.text = ""
                    }else
                    {
                        
                        self.oldPrice.text = ""
                        self.newPrice.text = ""
                        self.oldPriceView.isHidden = true
                        
                        
                    }
                }
                return
                
            }
        }
        if !flag {
            if currencyType == "gbp" {
                self.currencyLbl.isHidden = true
                self.currencyLbl.isHidden = false
                self.currencyLbl.text = ""
            }else {
                self.currencyLbl.text = ""
                self.currencyLbl.isHidden = false
                self.currencyLbl.isHidden = false
            }
            if (city.prices?[0].currencies?[0].special_price)  != nil{
                price_with_currancy = (city.prices?[0].currencies?[0].special_price)! * current_currency
                
                self.newPrice.text = "£\(((city.prices?[0].currencies?[0].special_price)!))"
                self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy))))"
                
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    self.oldPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.oldPriceView.isHidden = false
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    
                }
            }else {
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    
                    
                    self.newPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy))))))"
                    
                    
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    
                }else
                {
                    self.oldPrice.text = ""
                    self.oldPriceView.isHidden = true
                    self.newPrice.text = ""
                    
                    
                }
            }
            
        }
        
    }
    
    // Actions
    @IBAction func actionAddTip(_ sender: Any) {
        if delegate != nil {
           delegate?.tabbarAdd()
        }
    }
    
    
    @objc func actionTabGuide(_ sender: AnyObject) {
        print("Hi im here in tab ask and Intery")
        

        selectedOnTab(index: btnGuide.tag)
        delegate?.tabbarShowGuide()
    }
    
    @objc func actionFavorite(_ sender: AnyObject) {
        selectedOnTab(index: btnFavorite.tag)
        delegate?.tabbarShowFavorite()
    }
    
    func actionAllCities(_ sender: AnyObject) {
        delegate?.tabbarShowAllCities()
    }
    
    @objc func actionAskAndShare(_ sender: AnyObject) {
        selectedOnTab(index: btnAskShare.tag)
        delegate?.tabbarShowAskAndShare()
    }
    
    func selectedOnTab(index: Int){
        AppState.shared.selectedTab = index
        btnGuide.isSelected = index == btnGuide.tag
        btnFavorite.isSelected = index == btnFavorite.tag
        btnAskShare.isSelected = index == btnAskShare.tag
    }
    
    public func checkSelectedTab(){
        // set selected tab
        selectedOnTab(index: AppState.shared.selectedTab)
    }
    
}
