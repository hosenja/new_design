//
//  GroupInfoViewControler.swift
//  Snapgroup
//
//  Created by snapmac on 31/12/2018.
//  Copyright © 2018 Black. All rights reserved.
//

import UIKit
import GSKStretchyHeaderView
import SwiftHTTP
import GoogleMaps
import GooglePlaces
import SwiftShareBubbles
import FBSDKShareKit
import GoogleSignIn
import TTGSnackbar
import MessageUI
import FacebookShare

class GroupInfoViewControler: DashboardBaseViewController, GMSMapViewDelegate, CLLocationManagerDelegate,SwiftShareBubblesDelegate, MFMailComposeViewControllerDelegate {
    

    
    @IBOutlet weak var backView: UIView!
    var bubbles: SwiftShareBubbles?
 @IBOutlet weak var currencyLbl: UILabel!
    var currentPhone: String = ""
    var bounds = GMSCoordinateBounds()
    var fullMapBounds = GMSCoordinateBounds()
    @IBOutlet weak var fullGoogleMap: GMSMapView!
    var originalHeight: CGFloat!
    var isShowTableView: Bool = false
    var lastContentOffset: CGFloat = 0
    var viewExamp: GSKStretchyHeaderView!
    let duration : Double = 0.25
    var height: CGFloat = 0
    /// google map
    var planDays: [Day] = []
    var locationManager =  CLLocationManager()
    //var locationSelected = Location.startLocation
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var markcon: UIImage = UIImage()
    var markerList : [GMSMarker] = []
    var markerListFullMap : [GMSMarker] = []
    var mapDays: [Day] = []

    //constrate
    @IBOutlet weak var mapHight: NSLayoutConstraint!
    let mapHeightDefault : CGFloat = 170
    let size = AppSetting.App.screenSize

    
    
    // group map
    @IBOutlet weak var viewClick: UIView!
    @IBOutlet weak var googleMaps: GMSMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var viewTop: NSLayoutConstraint!
    @IBOutlet weak var viewHieght: NSLayoutConstraint!
    @IBOutlet var headerview: UIView!
    var isMapExpanded = false

    @IBOutlet weak var fullMap: GMSMapView!
    var currentGroup: TourGroup?
    var images2: [SDWebImageSource] = []
    
    // payments Types
    @IBOutlet weak var availbleDatesLbl: UILabel!
    @IBOutlet weak var call_nowBt: UIButton!
    @IBOutlet weak var pricesTableView: UITableView!
    @IBOutlet weak var hTableView: NSLayoutConstraint!
    
    
    // group image and title
    @IBOutlet weak var catgoresView: UIView!
    @IBOutlet weak var readMoreLbl: UIButton!
    @IBOutlet weak var descrptionTitle: UILabel!
    var labelString = ""
    @IBOutlet weak var groupImages: ImageSlideshow!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var intrestedMembers: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var dayNumbers: UILabel!
    @IBOutlet weak var categoriesLbl: UILabel!
    @IBOutlet weak var datesGroup: UILabel!
    @IBOutlet weak var watchingLbl: UILabel!
    
    //pricess
    @IBOutlet weak var priceUiView: UIView!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var specialPrice: UILabel!
    @IBOutlet weak var specialView: UIView!
    @IBOutlet weak var showAllPrices: UILabel!
    
    // Group Leader / Company
    @IBOutlet weak var agentView: UIView!
    @IBOutlet weak var companyProfile: UILabel!
    @IBOutlet weak var groupLeaderProfile: UIView!
    @IBOutlet weak var agencyName: UILabel!
    @IBOutlet weak var agencyImage: UIImageView!
    
    @IBOutlet weak var fullMapTop: NSLayoutConstraint!
    
    override func viewWillAppear(_ animated: Bool) {
        if #available(iOS 11.0, *) {
            fullGoogleMap.preservesSuperviewLayoutMargins = false
            googleMaps.preservesSuperviewLayoutMargins = false
        } else {
            fullGoogleMap.preservesSuperviewLayoutMargins = true

            googleMaps.preservesSuperviewLayoutMargins = true
        }
        header.makeHeaderHomeGuide()

        fullMap.isHidden = true
        googleMaps.settings.myLocationButton = false
        googleMaps.isMyLocationEnabled = false
        self.googleMaps.delegate = self
        self.googleMaps.settings.accessibilityLanguage = "en"
        self.googleMaps.settings.compassButton = true
        self.googleMaps.settings.zoomGestures = true
        self.googleMaps.isUserInteractionEnabled = false
        
        fullGoogleMap.settings.myLocationButton = false
        fullGoogleMap.isMyLocationEnabled = false
        self.fullGoogleMap.delegate = self
        self.fullGoogleMap.settings.accessibilityLanguage = "en"
        self.fullGoogleMap.settings.compassButton = true
        self.fullGoogleMap.settings.zoomGestures = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
  
    fileprivate func agentFunc() {
        if self.currentGroup?.is_company != nil && (self.currentGroup?.is_company)! == 1 {
            print("company is  \((self.currentGroup?.is_company)!)")
        }else {
            print("leader is  \((self.currentGroup?.is_company)!)")
            
        }
         setTabbarIndex(4)
    }
    override func viewDidAppear(_ animated: Bool) {
     botomFoter.constant = tabbar.frame.height
        fullMapTop.constant = header.frame.height
    }
    @IBOutlet weak var topScrollView: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        currentGroup = AppState.currentGroup!
        backView.addTapGestureRecognizer {
            self.fullMap.isHidden = true
            
        }
       // print("Number float is \(num)")
        let defaults = UserDefaults.standard
        let array = defaults.array(forKey: "GroupsId")  as? [Int] ?? [Int]()
        if array.count > 0
        {
        if array.contains((currentGroup?.id)!) {
            
            header.markGroups.setImage(UIImage(named: "favorite-on"), for: .normal)
        }
        }
        setGroupInfo()
        availbleDatesLbl.addTapGestureRecognizer {
            setCheckTrue(type: "book_now", groupID: (AppState.currentGroup?.id)!)
            let bookingController = BookingViewController()
            self.navigationController?.pushViewController(bookingController, animated: true)
        }
        self.view.backgroundColor = .clear
        self.pricesTableView.register(UINib(nibName: "PriceTableViewCell", bundle: nil), forCellReuseIdentifier: "PriceTableViewCell")
        pricesTableView.delegate = self
        pricesTableView.dataSource = self
        
        bubbles = SwiftShareBubbles(point: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2), radius: 100, in: view)
        bubbles?.showBubbleTypes = [Bubble.facebook, Bubble.whatsapp, Bubble.google]
        
        //        let customAttribute = ShareAttirbute(bubbleId: customBubbleId, icon: UIImage(named: "Custom")!, backgroundColor: UIColor.white)
        //bubbles?.customBubbleAttributes = [customAttribute]
        
        bubbles?.delegate = self
        call_nowBt.addTarget(self, action:#selector(GroupInfoViewControler.callNow), for: .touchUpInside)
        header.shareHeader.addTarget(self, action:#selector(GroupInfoViewControler.actionWithParam), for: .touchUpInside)
        getGroupImages()
        getDays()
        pricesTableView.isScrollEnabled = false
        companyProfile.addTapGestureRecognizer {
            AppState.isGroupLeader = false
            self.agentFunc()
            

        }
        groupLeaderProfile.addTapGestureRecognizer {
             AppState.isGroupLeader = true
            self.agentFunc()

        }
        agentView.addTapGestureRecognizer {
            if self.currentGroup?.is_company != nil && self.currentGroup?.is_company == 0 {
                AppState.isGroupLeader = true
            }else {
                AppState.isGroupLeader = false
            }
            self.agentFunc()
        }
        showAllPrices.addTapGestureRecognizer {
            
            if self.showAllPrices.text == "Hide prices" {
                self.view.layoutIfNeeded() // force any pending operations to finish
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.pricesTableView.isHidden = true
                    self.hTableView.constant = 0
                    self.view.layoutIfNeeded()
                })
                self.showAllPrices.text = "Full pricing list"
            }else {
                self.view.layoutIfNeeded() // force any pending operations to finish
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.pricesTableView.isHidden = false
                    self.hTableView.constant = self.height
                    
                    self.view.layoutIfNeeded()
                })
                self.showAllPrices.text = "Hide prices"
            }
           
            
            
        }
        viewClick.addTapGestureRecognizer {
            print("Im clcked in ggole maps")
            self.expandMap(animate: true)
        }
        let radius : CGFloat = call_nowBt.bounds.height/2
        // facebook
        self.call_nowBt.layer.cornerRadius = radius
        originalHeight = viewHieght.constant
        scrollView.delegate = self
        groupImages.activityIndicator = DefaultActivityIndicator()
        setTableViewHeigh()
        setMap()

    }
   
    
    @objc func callNow(){
        currentPhone.makeAColl()
        
    }
    @objc func actionWithParam(){
        self.bubbles?.show()

    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("MFMailComposeViewController \(result)")
        controller.dismiss(animated: false, completion: nil)
    }
    
    func bubblesTapped(bubbles: SwiftShareBubbles, bubbleId: Int) {
        if let bubble = Bubble(rawValue: bubbleId) {
            print("\(bubble)")
            var urlGroup: String = "https://www.snapgroup.co/shareGroup.php?group=\((currentGroup?.id)!)"
            urlGroup = urlGroup.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
            switch bubble {
            case .facebook:
//                let content = FBSDKShareLinkContent()
//                content.contentURL =  URL(string: urlGroup)
//                let dialog : FBSDKShareDialog = FBSDKShareDialog()
//                dialog.fromViewController = self
//                dialog.shareContent = content
//                dialog.mode = FBSDKShareDialogMode.native
//                dialog.show()
                let content:LinkShareContent = LinkShareContent.init(url: URL.init(string: urlGroup) ?? URL.init(fileURLWithPath: urlGroup), quote: "Share This Content")
                
                let shareDialog = ShareDialog(content: content)
                shareDialog.failsOnInvalidData = true
                if  UIApplication.shared.canOpenURL(URL(string: "fb://")!){
                    shareDialog.mode = .native
                }
                else {
                    shareDialog.mode = .automatic
                }
                
                
                shareDialog.completion = { result in
                    // Handle share results
                }
                do
                {
                    try shareDialog.show()
                }
                catch
                {
                    print("Exception")
                    
                }
            case .whatsapp:
                
                let url  = URL(string: "whatsapp://send?text=\(urlGroup)")
                
                if UIApplication.shared.canOpenURL(url! as URL)
                {
                    UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                }else {
                    let snackbar = TTGSnackbar(message: "There are problem , please try later", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
            case .google:
                if MFMailComposeViewController.canSendMail() {
                    let mailComposerVC = MFMailComposeViewController()
                    mailComposerVC.mailComposeDelegate = self
                    mailComposerVC.setSubject("Check out ( \((currentGroup?.translations?[0].title)!) ) on Snapgroup")
                    mailComposerVC.setMessageBody(urlGroup, isHTML: false)
                    self.present(mailComposerVC, animated: true, completion: nil)
                }else {
                    let email = ""
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }
                
            default:
                break
            }
        } else {
            
        }
    }
    fileprivate func setTableViewHeigh() {
        if (self.currentGroup?.prices) == nil || ( ((self.currentGroup?.prices) != nil) && (self.currentGroup?.prices?.count == 0) ) {
            print("Im here and prices count  0")
            self.showAllPrices.isHidden = true
            self.hTableView.constant = 0
            self.isShowTableView = false

        }
        else
        {
            if ((self.currentGroup?.prices?.count)! > 1) {
                print("Im here and prices count  > 1")
                self.height = self.pricesTableView.contentSize.height
                self.height = CGFloat((self.currentGroup?.prices?.count)! * 50)
                self.isShowTableView = true
                self.hTableView.constant = height
                //self.showAllPrices.isHidden = false
                
            }else {
                print("Im here and prices count  = 1")

                self.isShowTableView = false
                self.hTableView.constant = 0
                self.showAllPrices.isHidden = true
            }
        }
        self.hTableView.constant = 0
        self.pricesTableView.isHidden = true
        
    }
    func setGroupInfo()  {
        
        
        dayNumbers.text = "\((currentGroup?.days_count)!) Days"

        if currentGroup?.categories != nil && (currentGroup?.categories.count)! > 0 {
            var catgoresLabel: String = ""
            for catgory in (currentGroup?.categories)! {
                catgoresLabel = catgoresLabel + "\((catgory.title)!) | "
            }
            catgoresLabel = String(catgoresLabel.dropLast())
            catgoresLabel = String(catgoresLabel.dropLast())

            categoriesLbl.text = catgoresLabel
        }
        else {
            catgoresView.isHidden = true
        }
        if currentGroup?.rotation != nil && (currentGroup?.rotation)! == "reccuring"
        {
            availbleDatesLbl.isHidden = false
            datesGroup.text = "\(currentGroup?.frequency != nil ? "\((currentGroup?.frequency)!.capitalizingFirstLetter()) Tour ": "")"
            dayNumbers.text = ""
        }else {
             availbleDatesLbl.isHidden = true
        setTripTimeDuration(startDate: (currentGroup?.start_date)!, endDate: (currentGroup?.end_date)!)
        }

        descrptionTitle.text = "Description"
        if currentGroup?.translations?.count != 0 {
            groupTitle.text = currentGroup?.translations?[0].title
            destination.text = currentGroup?.translations?[0].destination
            descriptionLbl.text = currentGroup?.translations?[0].description
            
        }else{
            if currentGroup?.title != nil {
                groupTitle.text = currentGroup?.title
            }
            if currentGroup?.description != nil {
                descriptionLbl.text = currentGroup?.description
            }
        }

      
        if currentGroup?.is_company != nil && (currentGroup?.is_company)! == 1 {
            companyProfile.isHidden = false
            if (currentGroup?.group_leader?.company?.phone) != nil {
                call_nowBt.isHidden = false
                currentPhone = (currentGroup?.group_leader?.company?.phone)!
            }else {
                if (currentGroup?.group_leader?.phone) != nil {
                    call_nowBt.isHidden = false
                    currentPhone = (currentGroup?.group_leader?.phone)!
                }
            }
            agencyName.text = (currentGroup?.group_leader?.company?.name) != nil ? (currentGroup?.group_leader?.company?.name!)! : ""
            
            if currentGroup?.group_leader?.company?.images != nil && (currentGroup?.group_leader?.company?.images?.count)! > 0 {
                var urlString =  ApiRouts.Media + (currentGroup?.group_leader?.company?.images?[0].path)!
                print("Url string is \(urlString)")
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                let url = URL(string: urlString)
                if url != nil {
                    self.agencyImage.sd_setImage(with: url!, completed: nil)
                }
            }
            else
            {
                self.agencyImage.image = UIImage(named: "img-default")
            }
        }else {
            if currentGroup?.group_leader?.images != nil && (currentGroup?.group_leader?.images?.count)! > 0 {
                var urlString =  ApiRouts.Media + (currentGroup?.group_leader?.images?[0].path)!
                print("Url string is \(urlString)")
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                let url = URL(string: urlString)
                if url != nil {
                    self.agencyImage.sd_setImage(with: url!, completed: nil)
                }
            }
            else
            {
                self.agencyImage.image = UIImage(named: "img-default")
            }
            if (currentGroup?.group_leader?.phone) != nil {
                call_nowBt.isHidden = false
                currentPhone = (currentGroup?.group_leader?.phone)!
            }else {
                if (currentGroup?.group_leader?.company?.phone) != nil {
                    call_nowBt.isHidden = false
                    currentPhone = (currentGroup?.group_leader?.company?.phone)!
                }
            }
            companyProfile.isHidden = true
            let groupLeaderFirstName: String = (currentGroup?.group_leader?.profile?.first_name) != nil ? "\((currentGroup?.group_leader?.profile?.first_name!)!) " : ""
            let groupLeaderLastName: String = (currentGroup?.group_leader?.profile?.last_name) != nil ? "\((currentGroup?.group_leader?.profile?.last_name!)!) " : ""
            agencyName.text = groupLeaderFirstName + groupLeaderLastName
            
        }
        if AppState.currentGroup?.phone != nil {
            currentPhone = (AppState.currentGroup?.phone)!
            call_nowBt.isHidden = false
            
        }
        let defaults = UserDefaults.standard
        let currentCurrency = defaults.string(forKey: "currentCurrency")
        if currentGroup?.prices != nil && (currentGroup?.prices?.count)! > 0 {
//            self.currencyLbl.text = ""
//            self.viewPrice.isHidden = false
            self.priceUiView.isHidden = false
            self.specialView.isHidden = false
            getCurrencyType(currencyType: currentCurrency!, city: currentGroup!)
        }else {
            self.currencyLbl.text =  ""
            self.priceUiView.isHidden = true
            self.specialView.isHidden = true
        }
        
        
        if currentGroup?.interested != nil && currentGroup?.interested != 0 {
            
            intrestedMembers.text = "\((currentGroup?.interested)!) interested"
        }else {
            intrestedMembers.text = "25 interested"
        }
        
    }
    
    /// must clean
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
                    
                    self.tabbar.newPrice.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                    self.priceLbl.text = "\(String(describing: (currency_type)!))\((String(format: "%.2f", currency.special_price!)))"
                    if currency.price != nil {
                        
                        self.tabbar.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", (currency.price)!)))))"
                        self.specialPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", (currency.price)!)))))"
                        self.tabbar.oldPriceView.isHidden = false
                        self.specialView.isHidden = false
                    }else
                    {
                        self.tabbar.oldPriceView.isHidden = true
                        self.tabbar.oldPrice.text = ""
                        self.specialPrice.text = ""
                        self.specialView.isHidden = true
                        
                    }
                }else {
                    if currency.price != nil {
                        
                        self.tabbar.newPrice.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                        self.priceLbl.text = "\(String(describing: (currency_type)!))\(((((String(format: "%.2f", (currency.price)!))))))"
                        self.specialView.isHidden = true
                        self.specialPrice.text = ""
                        self.tabbar.oldPriceView.isHidden = true
                        self.tabbar.oldPrice.text = ""
                    }else
                    {
                        
                         self.tabbar.oldPrice.text = ""
                         self.tabbar.newPrice.text = ""
                         self.tabbar.oldPriceView.isHidden = true
                        self.specialPrice.text = ""
                        self.specialView.isHidden = true
                        self.priceLbl.text = ""
                        
                    }
                }
                return
                
            }
        }
        if !flag {
            if currencyType == "gbp" {
                self.currencyLbl.isHidden = true
                self.tabbar.currencyLbl.isHidden = false
                 self.tabbar.currencyLbl.text = ""
            }else {
                self.tabbar.currencyLbl.text = ""
               self.tabbar.currencyLbl.isHidden = false
                self.currencyLbl.isHidden = false
            }
            if (city.prices?[0].currencies?[0].special_price)  != nil{
                price_with_currancy = (city.prices?[0].currencies?[0].special_price)! * current_currency
                self.priceLbl.text = "£\(((city.prices?[0].currencies?[0].special_price)!))"
                self.tabbar.newPrice.text = "£\(((city.prices?[0].currencies?[0].special_price)!))"
                self.tabbar.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy))))"
                self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((String(format: "%.2f", price_with_currancy))))"
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    self.tabbar.oldPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
                    self.specialPrice.text = "\(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy)))))"
                    self.specialPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.tabbar.oldPriceView.isHidden = false
                    self.specialView.isHidden = false
                }else
                {
                    self.tabbar.oldPrice.text = ""
                    self.tabbar.oldPriceView.isHidden = true
                    
                    self.specialPrice.text = ""
                    self.specialView.isHidden = true
                    
                }
            }else {
                if city.prices?[0].currencies?[0].price != nil {
                    price_with_currancy = 1
                    price_with_currancy = ((Float((city.prices?[0].currencies?[0].price)!))) * current_currency
                    
                    self.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy))))))"
                    self.tabbar.newPrice.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                     self.tabbar.currencyLbl.text = "(Approx . \(String(describing: (currency_type)!))\((((String(format: "%.2f", price_with_currancy))))))"
                    self.priceLbl.text = "£\(((city.prices?[0].currencies?[0].price)!))"
                    self.specialView.isHidden = true
                    self.specialPrice.text = ""
                    self.tabbar.oldPrice.text = ""
                    self.tabbar.oldPriceView.isHidden = true
                    
                }else
                {
                    self.tabbar.oldPrice.text = ""
                    self.tabbar.oldPriceView.isHidden = true
                    self.tabbar.newPrice.text = ""
                    self.specialPrice.text = ""
                    self.priceUiView.isHidden = true
                    self.priceLbl.text = ""
                    
                }
            }
            
        }
        
    }
    
    
    
    @IBAction func readMoreClick(_ sender: Any) {
        if self.readMoreLbl.titleLabel?.text == "Read More"
        {
            self.descriptionLbl.numberOfLines = 0
            self.descriptionLbl.sizeToFit()
            self.readMoreLbl.setTitle("Read Less", for: .normal)
        }else {
            self.descriptionLbl.numberOfLines = 3
            self.descriptionLbl.sizeToFit()
            self.readMoreLbl.setTitle("Read More", for: .normal)

        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
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
                datesGroup.text = startDay + " " + endMonth
            }
            else{
                datesGroup.text = startDay+"-" + endDay+" "+endMonth
            }

        }else{

            datesGroup.text = startDay+" "+startMonth + " - " + endDay+" "+endMonth
        }


        
        
    }


    func createMarker(titleMarker: String , lat: CLLocationDegrees, long: CLLocationDegrees, isMemberMap: Bool, dayNumber: String, postion: Int, isMyId : String, j : Int){
        
        let fullMapMarker = GMSMarker()
        let marker = GMSMarker()
        print("Lat \(lat)  and long \(long)")
        marker.position = CLLocationCoordinate2DMake(lat, long)
        marker.title = titleMarker
        
        fullMapMarker.position = CLLocationCoordinate2DMake(lat, long)
        fullMapMarker.title = titleMarker
        let DynamicView=UIView(frame: CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 40, height: 45)))
        DynamicView.backgroundColor=UIColor.clear
        var imageViewForPinMarker : UIImageView
        imageViewForPinMarker  = UIImageView(frame:CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 38, height: 40)))
        if isMyId == "first"{
            imageViewForPinMarker.image = UIImage(named:"mapmarkersmall")
            
        }
        else{
            if (self.mapDays.count - 1) == postion {
                imageViewForPinMarker.image = UIImage(named:"mapmarkersmall")
                
            }else {
                imageViewForPinMarker.image = UIImage(named:"mapmarkersmall")
            }
        }
        let text = UILabel(frame:CGRect(origin: CGPoint(x: 2,y :2), size: CGSize(width: 38, height: 30)))
        
        text.text = "\(j + 1) "
        
        text.textAlignment = .center
        text.font = UIFont(name: text.font.fontName, size: 14)
        text.textAlignment = NSTextAlignment.center
        imageViewForPinMarker.addSubview(text)
        DynamicView.addSubview(imageViewForPinMarker)
        UIGraphicsBeginImageContextWithOptions(DynamicView.frame.size, false, UIScreen.main.scale)
        DynamicView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imageConverted: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        markcon = imageConverted
        
        fullMapMarker.accessibilityLabel = "\(isMemberMap)"
        fullMapMarker.icon = markcon
        fullMapMarker.snippet = "\(postion)"
        fullMapMarker.map = fullGoogleMap
        self.markerListFullMap.append(fullMapMarker)

        marker.accessibilityLabel = "\(isMemberMap)"
        marker.icon = markcon
        marker.snippet = "\(postion)"
        marker.map = googleMaps
        self.markerList.append(marker)
    }
    @IBOutlet weak var botomFoter: NSLayoutConstraint!
    func expandMap(animate: Bool) {
        
        
        
        self.header.headerView.backgroundColor = UIColor(netHex: AppSetting.Color.blue)

        for marker in self.markerListFullMap {
            self.fullMapBounds = self.fullMapBounds.includingCoordinate(marker.position)
        }
        CATransaction.begin()
        CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)
        
        self.fullGoogleMap.animate(toViewingAngle: 45)
        self.fullGoogleMap.animate(with: GMSCameraUpdate.fit(self.bounds))
        
        
        CATransaction.commit()
        
            self.view.layoutIfNeeded()
                UIView.animate(withDuration: duration, delay: 0.25, options: .curveEaseOut, animations: {
                        self.fullMap.isHidden = false
                        self.view.layoutIfNeeded()
                }, completion: {finish in
                      self.googleMaps.settings.myLocationButton = true
                    self.fullGoogleMap.settings.myLocationButton = true
                })
        
        }
    
    

    func getDays(){
        let url: String = ApiRouts.Api + "/days/group/\((self.currentGroup?.id)!)"
        print("Get Day url is \(url)")
        HTTP.GET(url) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let days:PlanDays  = try JSONDecoder().decode(PlanDays.self, from: response.data)
                self.planDays = days.days!
                DispatchQueue.main.sync {
                    self.getMap(dayMap: days)
                }
                
            }
            catch let error{
                print(error)
            }
            //    print("opt finished: \(response.description)")
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }
    
        
    
    
    
    func getMap(dayMap: PlanDays){
        self.markerList = []
        self.markerListFullMap = []
        self.mapDays = []
        let days  = dayMap
        self.mapDays = days.days!
        var index : Int = 1
        var j: Int = 0
        var postion: Int = 0
        var _: Int = 0
        for day in self.mapDays {
            for loc in day.locations! {
                if j == 0 && postion == 0 {
                    self.createMarker(titleMarker: loc.title != nil ? loc.title! : "", lat: CLLocationDegrees((loc.lat! as NSString).floatValue), long: CLLocationDegrees((loc.long! as NSString).floatValue), isMemberMap: false, dayNumber: "Day \(index)", postion: postion, isMyId: "first", j: j)
                }else {
                    self.createMarker(titleMarker: loc.title != nil ? loc.title! : "", lat: CLLocationDegrees((loc.lat! as NSString).floatValue), long: CLLocationDegrees((loc.long! as NSString).floatValue), isMemberMap: false, dayNumber: "Day \(index)", postion: postion, isMyId: "false", j : j)
                }
                j = j + 1
            }
            index = index + 1
            postion = postion + 1
        }

        self.fitAllMarkers()
    }
    func fitAllMarkers() {
        if self.markerList.count > 0 {
            for marker in self.markerList {
                self.bounds = self.bounds.includingCoordinate(marker.position)
            }
            print("Bounds \(self.bounds)")
            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)
            self.googleMaps.animate(toViewingAngle: 45)
            self.googleMaps.animate(with: GMSCameraUpdate.fit(self.bounds))
            
            CATransaction.commit()
        }else {
        }
       
        
        
      
    }
    let placesClient = GMSPlacesClient.shared()
   

    @IBOutlet weak var mapView: GMSMapView!
    
    func setMap(){
        self.placesClient.lookUpPlaceID((currentGroup?.translations?[0].destination_place_id)!, callback: { (place, error) -> Void in
            
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress!)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.coordinate.latitude)")
                print("Place attributions \(place.coordinate.longitude)")
                print("\(place.coordinate.latitude)")
                self.googleMaps.animate(toLocation: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
//                self.fullMap.animate(toLocation: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
                print("\(place.coordinate.longitude)")
            } else {
            }
        })
       
     
    }
    
    func getGroupImages()  {
        
        if currentGroup?.images != nil && (currentGroup?.images?.count)! > 0 {
            var image_path: String = ""
            for image in (currentGroup?.images!)! {
                if image.path !=  nil {
                    
                    image_path = "\(ApiRouts.Media)\(image.path!)"
                    image_path = image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    
                    let alamofireSource = SDWebImageSource(url: URL(string: image_path)!, placeholder: UIImage(named: "img-default")!)
                    self.images2.append(alamofireSource)
                    
                }
            }
            self.groupImages.contentScaleMode = .scaleAspectFill
            self.groupImages.contentMode = .scaleAspectFill
            self.groupImages.setImageInputs(self.images2)
        }else {
            self.groupImages.contentScaleMode = .scaleAspectFill
            self.groupImages.contentMode = .scaleAspectFill
            self.groupImages.setImageInputs([
                ImageSource(image: UIImage(named: "img-default")!)])
        }
        
    }
    override func headerBarGoBackImpl() {
        self.tabBarController?.navigationController?.popViewController(animated: true)
    }

}

extension GroupInfoViewControler: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        //self.topScrollView.constant = 0
        let defaultTop: CGFloat = CGFloat(0)
        scrollView.bounces = scrollView.contentOffset.y > 100
        //var currentTop: CGFloat = defaultTop
//        if (self.lastContentOffset > scrollView.contentOffset.y) {
//            //labelTop.constant = 20
//        }
//        else if (self.lastContentOffset < scrollView.contentOffset.y) {
//            //labelTop.constant = viewTop.constant + offset
//        }
//        if offset < 0{
//            currentTop = offset
////            viewHieght.constant = originalHeight - offset
//
//        }else{
//
//           // viewHieght.constant = originalHeight
//        }
        if offset > viewHieght.constant - 150 {
            //print("Im here in make header wethaer 2")
             header.makeHeaderWeather2(isFlaged: true, isprovider: false)
        }else {
            //print("Im here in make header wethaer 3")

             header.makeHeaderWeather2(isFlaged: false, isprovider: false)
        }
        
        //self.lastContentOffset = scrollView.contentOffset.y
    
        //viewTop.constant = currentTop
        
        
        
    }
    
}
extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
}
extension UIView {

    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?

    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        set {

            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
    }
    // HI 11122



    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGestureRecognizer)
    }




    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGesture(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }

}

extension String {
    enum RegularExpressions: String {
        case phone = "^\\s*(?:\\?(\\d{1,3}))?([-. (]*(\\d{3})[-. )]*)?((\\d{3})[-. ]*(\\d{2,4})(?:[-.x ]*(\\d+))?)\\s*$"
    }
    
    func isValid(regex: RegularExpressions) -> Bool {
        return isValid(regex: regex.rawValue)
    }
    
    func isValid(regex: String) -> Bool {
        let matches = range(of: regex, options: .regularExpression)
        return matches != nil
    }
    
    func onlyDigits() -> String {
        var filtredUnicodeScalars = unicodeScalars
        var number = String(String.UnicodeScalarView(filtredUnicodeScalars))
        let regex = RegularExpressions.phone
        let allMatches = matches(for: regex.rawValue, in: number as String)
        print("All regix is \(allMatches)")
        return number
    }
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,range: NSRange(text.startIndex..., in: text))
            let finalResult = results.map {
                String(text[Range($0.range, in: text)!])
            }
            return finalResult
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    func makeAColl() {
        //if isValid(regex: .phone) {
            print("Only digitss is \(self.onlyDigits())")
            if let url = URL(string: "tel://\(self.onlyDigits())"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            } else {
                let snackbar = TTGSnackbar(message: "There is problem with connecting to the required number \((self.onlyDigits()))", duration: .middle)
                snackbar.icon = UIImage(named: "AppIcon")
                snackbar.show()
            }
    }
    
    
    var utfData: Data? {
        return self.data(using: .utf8)
    }
    
    
    
    subscript(_ range: CountableRange<Int>) -> String {
        let idx1 = index(startIndex, offsetBy: max(0, range.lowerBound))
        let idx2 = index(startIndex, offsetBy: min(self.count, range.upperBound))
        return String(self[idx1..<idx2])
    }
}
extension GroupInfoViewControler: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.currentGroup?.prices?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //PriceTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "PriceTableViewCell", for: indexPath) as! PriceTableViewCell
        cell.selectionStyle = .none
      cell.makeCell(self.currentGroup?.prices?[indexPath.row],indexPath.row)
        return cell
    }
    
    
    
}
extension Float {
    var clean: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)

    }
}
