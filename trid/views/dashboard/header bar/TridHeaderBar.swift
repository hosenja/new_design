//
//  TridHeaderBar.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit

protocol TridHeaderBarProtocol: class {
    func headerBarGoback()
    func headerBarSearch()
    func headerBarFilter()
    func headerBarReset()
}

class TridHeaderBar: UIView {
    
    @IBOutlet weak var viewheader: UIView!
    var isMark: Bool = false
    @IBOutlet weak var groupToolHeader: UIView!
    @IBOutlet public var headerView: UIView!
    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var imgLogo: UIImageView!
    @IBOutlet weak var btnSearch: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var labelCategoryName: UILabel!
    @IBOutlet weak var constraintFilterWidth: NSLayoutConstraint!
    @IBOutlet weak var shareHeader: UIButton!
    @IBOutlet weak var markGroups: UIButton!

    var delegate: TridHeaderBarProtocol?
    let filterWidth = CGFloat(36.0)
    
    
    // favorite- iamge and view
    
    override func awakeFromNib() {
       // self.backgroundColor = UIColor(netHex: AppSetting.Color.blue) // AppState.shared.currentCategoryColor
        // hidden some button
        btnBack.isHidden = true
        labelCategoryName.isHidden = true
        constraintFilterWidth.constant = 0
    }
    
    @IBOutlet weak var label: UILabel!
    public func hideAll(){
        btnSetting.isHidden = true
        shareHeader.isHidden = true
        markGroups.isHidden = true
        imgLogo.isHidden = true
        btnSearch.isHidden = true
        btnBack.isHidden = true
        btnFilter.isHidden = true
        shareHeader.isHidden = true
        markGroups.isHidden = true
        groupToolHeader.isHidden = true
        labelCategoryName.isHidden = true
        constraintFilterWidth.constant = 0
    }
    func setToUserDefaults(value: Any?, key: String){
        if value != nil {
            let defaults = UserDefaults.standard
            defaults.set(value!, forKey: key)
        }
        else{
            let defaults = UserDefaults.standard
            defaults.set("no value", forKey: key)
        }
    }
    func makeHeaderClear() {
        hideAll()
        //self.headerView.backgroundColor = .clear
        // left
        self.viewheader.backgroundColor = UIColor.clear
      self.headerView.backgroundColor = UIColor.clear
    }
    
    @IBAction func markGroup(_ sender: Any) {
        let defaults = UserDefaults.standard
        var array = defaults.array(forKey: "GroupsId")  as? [Int] ?? [Int]()
        if markGroups.imageView?.image == UIImage(named: "favorite-off") {
            array.append((AppState.currentGroup?.id)!)
            setToUserDefaults(value: array, key: "GroupsId")
            markGroups.setImage(UIImage(named: "favorite-on"), for: .normal)

        }else {
            let farray = array.filter {$0 != (AppState.currentGroup?.id)!}
            setToUserDefaults(value: farray, key: "GroupsId")
            markGroups.setImage(UIImage(named: "favorite-off"), for: .normal)

        }
        if AppState.isSelecctionGroups {
         NotificationCenter.default.post(name: NotificationKey.my_selection, object: false)
        }
    }
    @IBAction func shareGroup(_ sender: Any) {
    }
    
    // MARK: - make ui
    func makeHeaderWeather(name: String) {
        hideAll()
        //self.headerView.backgroundColor = .clear
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
    }
    
    // MARK: - make ui
    func makeHeaderWeather2(isFlaged: Bool,isprovider: Bool) {
        
        if isFlaged {
            
            if label.isHidden {
                UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                    //self.label.slideInFromLeft(type: "down")
                    self.headerView.slideInFromLeft(type: "down")
                    
                }) { (success) in
                    
                    UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                        self.label.isHidden = false
                        
                    }, completion: nil)
                }
            }else {
            label.isHidden = false
            headerView.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
            }
        }else {
            if !label.isHidden {
                UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                 //   self.label.slideInFromLeft(type: "top")
                    self.headerView.slideInFromLeft(type: "top")
                    
                }) { (success) in
                    
                    UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear, animations: {
                        self.label.isHidden = true
                        
                    }, completion: nil)
                }
            }
            else {

               // UIApplication.
           headerView.backgroundColor = UIColor.clear
            label.isHidden = true
            }
        }
    }
    func makeHeaderAllCity() {
        hideAll()
        // left
        btnSetting.isHidden = false
        // center
        imgLogo.isHidden = false
        // right
        btnSearch.isHidden = false
    }
    
    public func makeHeaderHomeGuide(){
        label.isHidden = true
        labelCategoryName.isHidden = true
        imgLogo.isHidden = true
        if AppState.currentGroup?.translations?.count != 0 {
            label.text = AppState.currentGroup?.translations?[0].title
        }else{
            if AppState.currentGroup?.title != nil {
                label.text = AppState.currentGroup?.title
            }
        }
       headerView.backgroundColor = UIColor.clear
        hideAll()
        
        groupToolHeader.isHidden = false

        shareHeader.isHidden = false
        markGroups.isHidden = false
        // bg
        //self.backgroundColor = UIColor.clear
        // left
        //btnSetting.isHidden = false
        btnBack.isHidden = false
        // right
    }
    public func makeHeaderGroupLeader(){
        hideAll()
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Agent"
        btnBack.isHidden = false
        // right
    }
    public func makeHeaderServices(){
        hideAll()
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Services"
        btnBack.isHidden = false
        // right
    }
    public func makeHeaderSetteings(){
        hideAll()
        imgLogo.isHidden = false
        btnBack.isHidden = false
        // right
    }
    public func makeHeaderRates(){
        hideAll()
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Ratings"
        btnBack.isHidden = false
        // right
    }
    public func makeHeaderProvider(){
        hideAll()
        label.text = (ProviderInfo.nameProvider)!
        headerView.backgroundColor = UIColor.clear
        labelCategoryName.isHidden = false
        labelCategoryName.text = ""
        btnBack.isHidden = false
        // right
    }
    
    public func makeHeaderTerms(){
        hideAll()
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Terms"
        btnBack.isHidden = false
        // right
    }
    
    func makeHeaderAskShare() {
        hideAll()
        // title
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Itinerary"
        // left
        btnBack.isHidden = false
        // right
        //btnSearch.isHidden = false
    }
    
    func makeHeaderBooking() {
        hideAll()
        // title
        labelCategoryName.isHidden = false
        labelCategoryName.text = "Booking"
        // left
        btnBack.isHidden = false
        // right
        //btnSearch.isHidden = false
    }
    func makeHeaderFavorite() {
        hideAll()
        // bg
       // self.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = Localized.favorite
    }
    
    public func makeHeaderCategory(name: String){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
        // right
        btnSearch.isHidden = false
        btnFilter.isHidden = false
        constraintFilterWidth.constant = filterWidth
    }
    
    public func makeHeaderDetail(title: String){
        hideAll()
        // bg
      //  self.headerView.backgroundColor = UIColor.clear
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = title
        labelCategoryName.alpha = 0
        
        // left
        btnBack.isHidden = false
    }
    
    func makeHeaderWebview(title: String?){
        hideAll()
        // bg
       // self.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = title
        // left
        btnBack.isHidden = false
    }
    public func makeHeaderDetailReadmorePlace(name: String){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = name
    }
    
    func makeHeaderFilter(){
        hideAll()
        // left
        btnBack.isHidden = false
        // center
        labelCategoryName.isHidden = false
        labelCategoryName.text = Localized.filter
        // right
        //btnReset.isHidden = false
    }
    
    // MARK: - actions
    @IBAction func actionOpenSetting(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NotificationKey.openSettingMenu, object: nil)
    }
    

    @IBAction func actionBack(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.headerBarGoback()
        }
    }
    
    @IBAction func actionFilter(_ sender: AnyObject) {
        if delegate != nil {
            delegate?.headerBarFilter()
        }
    }
    
    @IBAction func actionReset(_ sender: Any) {
        if delegate != nil {
            delegate?.headerBarReset()
        }
    }
    
    
}
extension UIView {
    // Name this function in a way that makes sense to you...
    // slideFromLeft, slideRight, slideLeftToRight, etc. are great alternative names
    func slideInFromLeft(type: String, duration: TimeInterval = 0.4, completionDelegate: AnyObject? = nil) {
        // Create a CATransition animation
        let slideInFromLeftTransition = CATransition()
        
        // Set its callback delegate to the completionDelegate that was provided (if any)
        if let delegate: AnyObject = completionDelegate {
            slideInFromLeftTransition.delegate = delegate as? CAAnimationDelegate
        }
        if type == ""{
            slideInFromLeftTransition.subtype = CATransitionSubtype.fromRight
            
        }else{
            if type == "down" {
                slideInFromLeftTransition.subtype = CATransitionSubtype.fromBottom
            }else {
                if type == "top" {
                    slideInFromLeftTransition.subtype = CATransitionSubtype.fromTop
                }else {
                    slideInFromLeftTransition.subtype = CATransitionSubtype.fromLeft
                }
            }
            
        }
        // Customize the animation's properties
        slideInFromLeftTransition.type = CATransitionType.push
        slideInFromLeftTransition.duration = duration
        slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        slideInFromLeftTransition.fillMode = CAMediaTimingFillMode.removed
        
        // Add the animation to the View's layer
        self.layer.add(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
    }
}


