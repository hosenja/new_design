//
//  ItemViewController.swift
//  Snapgroup
//
//  Created by snapmac on 3/12/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import GoneVisible
class ItemViewController: DashboardBaseViewController {
    
    
    
   
    
    // views

    @IBOutlet weak var bottomConstarate: NSLayoutConstraint!
    @IBOutlet weak var dayTitleLb: UILabel!
    @IBOutlet weak var dayNumberLbl: UILabel!
    @IBOutlet weak var dayImageView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var readMoreBt: UILabel!
    @IBOutlet weak var collectionServices: UICollectionView!
    @IBOutlet weak var scrolViewInterry: UIScrollView!
    // variabls
    public var number: Int = 0
    public var daynNumber: Int = 0
    public var dayImagePath: String =  ""
    public var date: String = ""
    public var dayDescription: String = ""
    public var dayTitle: String = ""
    
    @IBOutlet weak var todayServicesLbl: UILabel!
    public var currentDay: DayInterry?
    
//
//    fileprivate func viewsClicked() {
//        restaurantView.addTapGestureRecognizer {
//            //
//
//            ProviderInfo.currentProviderName =  "Restaurants"
//
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.restaurants?.count)!)")
//            //self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            //showServiceModalSeque
//            if  (self.currentDay?.restaurants?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.restaurants?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//                //                let vc = ServiceModalViewController()
//                //                self.present(vc, animated: true, completion: nil)
//
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.restaurants)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//
//
//        }
//        hotelsView.addTapGestureRecognizer {
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.hotels?.count)!)")
//
//            ProviderInfo.currentProviderName =  "Hotels"
//            if  (self.currentDay?.hotels?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.hotels?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.hotels)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//        }
//        activitiesView.addTapGestureRecognizer {
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.activities?.count)!)")
//
//            ProviderInfo.currentProviderName =  "Activities"
//            if   (self.currentDay?.activities?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.activities?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.activities)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//        }
//        placesViews.addTapGestureRaecognizer {
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.places?.count)!)")
//
//            ProviderInfo.currentProviderName =  "Places"
//            if   (self.currentDay?.places?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.places?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.places)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//        }
//        transportsView.addTapGestureRecognizer {
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.transports?.count)!)")
//            ProviderInfo.currentProviderName =  "Transport"
//            if  (self.currentDay?.transports?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.transports?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.transports)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//        }
//        tourGuideView.addTapGestureRecognizer {
//            print("current day = \((self.currentDay?.day_number)!) and the array size is \((self.currentDay?.tour_guides?.count)!)")
//
//            ProviderInfo.currentProviderName =  "Tourguides"
//            if   (self.currentDay?.tour_guides?.count)! == 1
//            {
//                ProviderInfo.currentProviderId =  self.currentDay?.tour_guides?[0].id
//                self.performSegue(withIdentifier: "showServiceProvider", sender: self)
//            }
//            else
//            {
//                ProviderInfo.currentServiceDay = (self.currentDay?.tour_guides)!
//                self.performSegue(withIdentifier: "showServiceModalSeque", sender: self)
//            }
//        }
//    }
//
    override func viewDidLoad() {
        super.viewDidLoad()
        //dayNumberLbl.text = "\(number)"
        print("im here item veiw")
        self.tabbar.isHidden = true
        header.makeHeaderClear()
        descriptionLbl.setHtmlText(dayDescription)
//        if self.descriptionLbl.calculateMaxLines() > 3 {
//            self.readMoreBt.isHidden = false
//            self.descriptionLbl.numberOfLines = 4
//
//        }
//        else{
//            self.readMoreBt.isHidden = true
//        }
        collectionServices.register(UINib(nibName: "ServiceView", bundle: nil), forCellWithReuseIdentifier: "ServiceView")
        dateLbl.text = date
        dayTitleLb.text = dayTitle
       // print(self.currentDay!)
        readMoreBt.addTapGestureRecognizer(action: {
            if self.readMoreBt.text == "Read More"
            {
                self.descriptionLbl.numberOfLines = 0
                self.descriptionLbl.sizeToFit()
                self.readMoreBt.text = "Read Less"
            }else {
                self.descriptionLbl.numberOfLines = 3
                self.descriptionLbl.sizeToFit()
                self.readMoreBt.text = "Read More"
            }
            UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        })
        
        if AppState.currentGroup?.rotation != nil && (AppState.currentGroup?.rotation)! == "reccuring"
        {
            dateLbl.isHidden = true
            // MyVriables.currentGroup.reg
        }else{
            dateLbl.isHidden = false
        }
        if dayImagePath == nil || (dayImagePath != nil && dayImagePath == "") {
            dayImageView.image = UIImage(named: "img-default")
        }
        else{
            //img-default
            var urlString = ApiRouts.Media + dayImagePath
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            var url = URL(string: urlString)
            //print("URL STRING \(url!)")
            //            do{
            //                try dayImageView.downloadedFrom(url: url!)
            //            }
            //            catch let error{
            //                print(error)
            //            }
            if url != nil{
                dayImageView.sd_setShowActivityIndicatorView(true)
                dayImageView.sd_setIndicatorStyle(UIActivityIndicatorView.Style.gray)
                dayImageView.sd_setImage(with: url!, completed: nil)
            }
        }
        //viewsClicked()
        setServicesFunc()
    }
    func setServicesFunc()  {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print("bottomConstarate \(tabbar.frame.height)")
        bottomConstarate.constant = tabbar.frame.height + 20
    }
    
//    func setHiddenServices() {
//        let hotelInStack = stackServices.arrangedSubviews[0]
//        let resturantInStack = stackServices.arrangedSubviews[1]
//        let activitiesInStack = stackServices.arrangedSubviews[2]
//        let placesInStack = stackServices.arrangedSubviews[3]
//        let transportsInStack = stackServices.arrangedSubviews[4]
//        let tourInStack = stackServices.arrangedSubviews[5]
//
//        if self.currentDay?.activities?.count == 0 {
//            activitiesInStack.isHidden = true
//        }
//        else{
//            var str: String = ""
//            for act in (self.currentDay?.activities!)! {
//                str.append("\((describing: act.name!)) ")
//            }
//            activitiesLbl.text = str
//        }
//        if self.currentDay?.restaurants?.count == 0 {
//            resturantInStack.isHidden = true
//        }else{
//            var str: String = ""
//            for (i,act) in (self.currentDay?.restaurants!)!.enumerated() {
//                if i !=  ((self.currentDay?.restaurants!)!.count - 1) {
//                    str.append("\((act.translations?[0].name!)!) ,")
//                }else{
//                    str.append("\((act.translations?[0].name!)!)")
//                }
//            }
//            restLabel.text = str
//        }
//        if self.currentDay?.hotels?.count == 0 {
//            hotelInStack.isHidden = true
//        }else{
//            var str: String = ""
//            for (i,act) in (self.currentDay?.hotels!)!.enumerated() {
//                if i !=  ((self.currentDay?.hotels!)!.count - 1) {
//                    str.append("\((act.translations?[0].name!)!) ,")
//                }else{
//                    str.append("\((act.translations?[0].name!)!)")
//                }
//
//
//            }
//            hotelsLabel.text = str
//        }
//        if self.currentDay?.places?.count == 0 {
//            placesInStack.isHidden = true
//        }else{
//            var str: String = ""
//            for (i,act) in (self.currentDay?.places!)!.enumerated() {
//                if i !=  ((self.currentDay?.places!)!.count - 1) {
//                    str.append("\((describing: act.name!)) ,")
//
//                }else{
//                    str.append("\((describing: act.name!))")
//                }
//
//            }
//            placesLbl.text = str
//        }
//        if self.currentDay?.tour_guides?.count == 0 {
//            tourInStack.isHidden = true
//        }else{
//            var str: String = ""
//            for (i,act) in (self.currentDay?.tour_guides!)!.enumerated() {
//
//                if i !=  ((self.currentDay?.tour_guides!)!.count - 1) {
//                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!) ,")
//
//                }else{
//                    str.append("\((act.translations?[0].first_name!)!) \((act.translations?[0].last_name!)!)")
//                }
//
//            }
//            toursLbl.text = str
//        }
//        if self.currentDay?.transports?.count == 0 {
//            transportsInStack.isHidden = true
//        }else{
//            var str: String = ""
//            for (i,act) in (self.currentDay?.transports!)!.enumerated() {
//                if i !=  ((self.currentDay?.transports!)!.count - 1) {
//                    str.append("\((describing: act.company_name!)) ,")
//
//                }else{
//                    str.append("\((describing: act.company_name!))")
//                }
//            }
//            transportsLbl.text = str
//        }
//
//    }
    
    
    
}

extension UIView {
    
    func goAway() {
        // set the width constraint to 0
        let widthConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        superview!.addConstraint(widthConstraint)
        
        // set the height constraint to 0
        let heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        superview!.addConstraint(heightConstraint)
    }
    
}
extension UILabel {
    func calculateMaxLines() -> Int {
        //print("view width is \(frame.size.width)")
        let maxSize = CGSize(width: UIScreen.main.bounds.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
    func setHtmlText(_ html: String) {
        let modifiedFont = NSString(format:"<span style=\"font-family: \(self.font!.fontName); font-size: \(self.font!.pointSize)\">%@</span>" as NSString, html)
        
        let attrStr = try! NSAttributedString(
            data: modifiedFont.data(using: String.Encoding.unicode.rawValue, allowLossyConversion: true)!,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
            documentAttributes: nil)
        
        self.attributedText = attrStr
        //        if let attributedText = html.attributedHtmlString {
        //            self.attributedText = attributedText
        //        }
    }
}

extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countServices: Int = (self.currentDay?.services?.count)!
        if countServices == 0 {
            todayServicesLbl.isHidden = true
            collectionServices.isHidden = true
            return 0
        }else {
            todayServicesLbl.isHidden = false
            collectionServices.isHidden = false
        return countServices
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionServices.dequeueReusableCell(withReuseIdentifier: "ServiceView", for: indexPath) as! ServiceView
        if self.currentDay?.services?[indexPath.row].image != nil {
            var urlString = ApiRouts.Media + (self.currentDay?.services?[indexPath.row].image)!
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            let url = URL(string: urlString)
            if url != nil{
                cell.serviceImg.sd_setImage(with: url!, completed: nil)
            }else {
                 cell.serviceImg.image = UIImage(named: "img-default")
            }
        }
        else{
            cell.serviceImg.image = UIImage(named: "img-default")

        }
        switch (self.currentDay?.services?[indexPath.row].service_type)! {
        case "places":
            cell.imageiCON.image = UIImage(named: "placeicon")
        case "hotels":
            cell.imageiCON.image = UIImage(named: "hotelicon")
        case "restaurants":
            cell.imageiCON.image = UIImage(named: "restauranticon")
        case "tour_guides":
            cell.imageiCON.image = UIImage(named: "tourguideicon")
        case "transports":
            cell.imageiCON.image = UIImage(named: "transportationicon")
        case "activities":
            cell.imageiCON.image = UIImage(named: "activityicon")
        default:
            break
        }
        cell.serviceLbl.text = self.currentDay?.services?[indexPath.row].name != nil ? (self.currentDay?.services?[indexPath.row].name)! : ""
        return cell
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ProviderInfo.model_id = (self.currentDay?.services?[indexPath.row].service_id)!
        ProviderInfo.model_type = (self.currentDay?.services?[indexPath.row].service_type) != nil ? (self.currentDay?.services?[indexPath.row].service_type)! : ""
        ProviderInfo.nameProvider = (self.currentDay?.services?[indexPath.row].name) != nil ? (self.currentDay?.services?[indexPath.row].name)! : ""
        let provider = ProviderViewController()
        self.navigationController?.pushViewController(provider, animated: true)
    }
    
    
}
