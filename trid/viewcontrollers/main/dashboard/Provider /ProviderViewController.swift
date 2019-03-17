//
//  ProviderViewController.swift
//  Snapgroup
//
//  Created by snapmac on 18/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import SwiftHTTP
import PopupDialog

class ProviderViewController: DashboardBaseViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var viewHight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewProvider: UIScrollView!
    @IBOutlet weak var constrateTop: NSLayoutConstraint!
    @IBOutlet weak var botomConstarate: NSLayoutConstraint!
    
    @IBOutlet weak var providerimage: ImageSlideshow!
    @IBOutlet weak var providerName: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var googleMap: GMSMapView!
    @IBOutlet weak var readMoreBt: UIButton!
    @IBOutlet weak var providerIcon: UIImageView!
    var locationManager = CLLocationManager()
    
    // adress
    @IBOutlet weak var adressLbl: UILabel!
    @IBOutlet weak var adressView: UIView!
    
    // phone
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var phoneView: UIView!
    
    // email
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailView: UIView!
    
    // website
    @IBOutlet weak var websiteLbl: UILabel!
    @IBOutlet weak var websiteView: UIView!
    
    // http requset
    var urlGetService: String?
    var urlGetRate: String?
    var providerModel : ProviderModel?
    
   // ratings
    
    @IBOutlet weak var tableViewRatings: UITableView!
    @IBOutlet weak var ratingH: NSLayoutConstraint!
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var moreReviewsBt: UIButton!
    var ratingsArray: [RatingModel]? = []
    var count: Int = 5
    @IBOutlet weak var ratingsLbl: UILabel!
    
     // slide image
    var images2: [SDWebImageSource] = []
    
    @IBAction func readMoreClick(_ sender: Any) {
        if self.readMoreBt.titleLabel?.text == "Read More"
        {
            self.descriptionLbl.numberOfLines = 0
            self.descriptionLbl.sizeToFit()
            self.readMoreBt.setTitle("Read Less", for: .normal)
        }else {
            self.descriptionLbl.numberOfLines = 3
            self.descriptionLbl.sizeToFit()
            self.readMoreBt.setTitle("Read More", for: .normal)
            
        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
        
        
    }
    @IBAction func writeReview(_ sender: Any) {
        // Create a custom view controller
        let ratingVC = RateDialog(nibName: "RateDialog", bundle: nil)
        
        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        
        // Present dialog
        ProviderInfo.model_type = (ProviderInfo.model_type)!
        ProviderInfo.model_id =  (ProviderInfo.model_id)!
        present(popup, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.makeHeaderProvider()
        tableViewRatings.isScrollEnabled = false
        tableViewRatings.delegate = self
        tableViewRatings.dataSource = self
        tableViewRatings.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingsTableViewCell")
        googleMap.settings.myLocationButton = false
        googleMap.isMyLocationEnabled = false
        self.googleMap.delegate = self
        self.googleMap.settings.compassButton = true
        self.googleMap.settings.zoomGestures = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        if #available(iOS 11.0, *) {
            googleMap.preservesSuperviewLayoutMargins = false
        } else {
            googleMap.preservesSuperviewLayoutMargins = true
        }
        moreReviewsBt.addTarget(self, action:#selector(ProviderViewController.goToAllReviews), for: .touchUpInside)
        googleMap.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        switch (ProviderInfo.model_type)! {
        case "places":
            providerIcon.image = UIImage(named: "placeicon")
        case "hotels":
            providerIcon.image = UIImage(named: "hotelicon")
        case "restaurants":
            providerIcon.image = UIImage(named: "restauranticon")
        case "tour_guides":
            providerIcon.image = UIImage(named: "tourguideicon")
        case "transports":
            providerIcon.image = UIImage(named: "transportationicon")
        case "activities":
            providerIcon.image = UIImage(named: "activityicon")
        default:
            break
        }
         tabbar.setBarHide()
        scrollViewProvider.delegate = self
         header.btnBack.addTarget(self, action:#selector(ServicesViewControler.back), for: .touchUpInside)
    }
    
    @objc func goToAllReviews(){
        let provider = AllRatingsViewController()
        self.navigationController?.pushViewController(provider, animated: true)
    }
    @objc func back(){
        
       self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
         NotificationCenter.default.addObserver(self, selector: #selector(getRatingsFunc), name: NotificationKey.writeRate_provider, object: nil)
        getUrlService()
    }
    @objc func getRatingsFunc(notification: NSNotification) {
        
        DispatchQueue.main.async {
            print("Array count is before \((self.ratingsArray?.count)!)")
            self.ratingsView.isHidden = false
            let obj = notification.object as? RatingModel
            self.ratingsArray?.append(obj!)
            self.tableViewRatings.reloadData()
            print("Array count is after \((self.ratingsArray?.count)!)")
            
            var height: CGFloat = self.ratingH.constant
            if (self.ratingsArray?.count)! > 5 {
                self.moreReviewsBt.isHidden = false
            }else {
                height = height + 90
            }
            print("Array count is in tableheight \((self.ratingsArray?.count)!) and height is \(height)")
            self.ratingH.constant = height
            self.tableViewRatings.reloadData()
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        botomConstarate.constant = tabbar.frame.height
    }
    
    func getUrlService(){
  

        switch ProviderInfo.model_type!{
        case "hotels":
            urlGetService = ApiRouts.Api+"/get/hotel/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=hotels"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "hotels"
        case "places":
            urlGetService = ApiRouts.Api+"/get/place/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=places"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "places"
        case "restaurants":
            urlGetService = ApiRouts.Api+"/get/restaurant/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=restaurants"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "restaurants"
        case "tourguides":
            urlGetService = ApiRouts.Api+"/get/tourguide/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=tourguides"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "tourguides"
        case "transport":
            urlGetService = ApiRouts.Api+"/get/transport/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=transports"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "transports"
        case "activities":
            urlGetService = ApiRouts.Api+"/get/activity/\((ProviderInfo.model_id)!)"
            let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=activities"
            urlGetRate = url
            ProviderInfo.model_id = (ProviderInfo.model_id)!
            ProviderInfo.model_type = "activities"
        default:
            urlGetService = "null"
            urlGetRate = "null"
        }
        
        getProvider()
        getRatings()
        
    }
    
    fileprivate func setMap() {
        let marker = GMSMarker()
        if self.providerModel?.long != nil  && self.providerModel?.lat != nil {
            marker.position = CLLocationCoordinate2DMake(CLLocationDegrees((self.providerModel?.long! as! NSString).floatValue), CLLocationDegrees((self.providerModel?.lat! as! NSString).floatValue))
            
            let markcon = UIImage(named: "destinationicon")!
            marker.accessibilityLabel = "\(true)"
            marker.icon = markcon
            marker.map = self.googleMap
            CATransaction.begin()
            CATransaction.setValue(NSNumber(value: 1.0), forKey: kCATransactionAnimationDuration)
            
         //   self.googleMap.animate(toViewingAngle: 45)
        //    self.googleMap.animate(toZoom: 250)
            self.googleMap.animate(toLocation: marker.position)
            CATransaction.commit()
            self.googleMap.selectedMarker = marker
        }
    }
    
    func getProvider(){
        
        print("^^^^ "+urlGetService!)
    
        AppLoading.showLoading()
        HTTP.GET(urlGetService!, parameters:[])
        { response in
            if let err = response.error {
                
                AppLoading.hideLoading()
                print("error: \(err.localizedDescription)")
                
                return //also notify app of failure as needed
            }
            
            
            
            do{
                print("^^^^")
                
                self.providerModel = try JSONDecoder().decode(ProviderModel.self, from: response.data)
                print("\(response.data)")
                DispatchQueue.main.async {
                    if self.providerModel?.images != nil {
                        if self.providerModel?.images?.count == 0 {
                            
                            self.providerimage.setImageInputs([
                                ImageSource(image: UIImage(named: "img-default")!)])
                        }
                        else{
                             var image_path: String = ""
                            for image in (self.providerModel?.images)! {
                                if image.path !=  nil {
                                    image_path = ""
                                    image_path = "\(ApiRouts.Media)\(image.path!)"
                                    image_path = image_path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                                    
                                    let alamofireSource = SDWebImageSource(url: URL(string: image_path)!, placeholder: UIImage(named: "img-default")!)
                                    self.images2.append(alamofireSource)
                                    
                                }
                            }
                            self.providerimage.contentScaleMode = .scaleAspectFill
                            self.providerimage.setImageInputs(self.images2)
                            self.providerimage.contentScaleMode = .scaleAspectFill
                            
                        }
                    }else {
                        self.providerimage.setImageInputs([
                            ImageSource(image: UIImage(named: "img-default")!)])
                    }
                    if self.providerModel?.description != nil
                    {
                        self.descriptionLbl.text = (self.providerModel?.description)!
                        
                    }
                    else
                    {
                        if self.providerModel?.bio != nil
                        {
                            self.descriptionLbl.text = (self.providerModel?.bio)!
                        }
                        else
                        {
                            self.descriptionLbl.text = "there is no info"
                        }
                        
                    }
                    if self.providerModel?.rating != nil {
                        self.ratingsLbl.text = "\((self.providerModel?.rating)!)"
                        ProviderInfo.ratings = "\((self.providerModel?.rating)!)"
                    }else{
                         self.ratingsLbl.text = ""
                    }
                    if self.providerModel?.company_name != nil
                    {
                        self.providerName.text = (self.providerModel?.company_name)!
                    }
                    else
                    {
                        if self.providerModel?.name != nil
                        {
                            
                            self.providerName.text = (self.providerModel?.name)!
                        }
                        else
                        {
                            if self.providerModel?.first_name != nil && self.providerModel?.last_name != nil
                            {
                                self.providerName.text = "\((self.providerModel?.first_name)!) \((self.providerModel?.last_name)!)"
                                
                            }
                            
                        }
                        
                    }
                    if self.providerModel?.city != nil {
                        self.adressLbl.text =  ( self.providerModel?.city != nil ? self.providerModel?.city : "there is not exits")!
                    }else {
                        self.adressView.isHidden = true
                    }
                    
                    if self.providerModel?.phone != nil
                    {
                        self.phoneLbl.text = self.providerModel?.phone
                    }
                    else{
                        self.phoneView.isHidden = true
                        
                    }
                    
                    if  self.providerModel?.contacts != nil
                    {
                        if  (self.providerModel?.contacts?.count)! > 0
                        {
                            if (self.providerModel?.contacts![0].email) == nil
                            {
                                self.emailLbl.text = "no email"
                                self.emailView.isHidden = true
                            }
                            else{
                                self.emailLbl.text =  (self.providerModel?.contacts![0].email)
                            }
                        }
                        else
                        {
                            
                            self.emailLbl.text = "no email"
                            self.emailView.isHidden = true
                            
                        }
                    }
                    else
                    {
                        self.emailLbl.text = "no email"
                        self.emailView.isHidden = true
                    }
                    if self.providerModel?.website != nil
                    {
                        self.websiteLbl.text = (self.providerModel?.website)
                    }
                    else{
                        
                        self.websiteView.isHidden = true
                    }
                    
                    
                }
                DispatchQueue.main.async {
                AppLoading.showSuccess()
                if self.descriptionLbl.calculateMaxLines() > 4 {
                    self.readMoreBt.isHidden = false
                    self.descriptionLbl.numberOfLines = 4
                    
                }
                else{
                    self.readMoreBt.isHidden = true
                }
                
                
                
                    self.setMap()
                }
                print("after Decoding \(self.providerModel)")
            }
            catch let error {
            }
        }
        
    }
    func getRatings() {
        self.ratingsArray = []
        let url = urlGetRate
        print("Rating url is === \(url)")
        HTTP.GET(url!, parameters:[])
        {
            response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            do {
                let rates = try JSONDecoder().decode(RatingsStrubs.self, from: response.data)
                self.ratingsArray = rates.ratings
                print("The Array is \(self.ratingsArray!)")
                DispatchQueue.main.sync {
                    
                    if self.ratingsArray?.count == 0 {
                        self.count = 0
                        self.tableViewRatings.reloadData()
                    }
                    self.tableViewRatings.reloadData()
                    self.setTableViewHeigh()
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }
    fileprivate func setTableViewHeigh() {
        if self.ratingsArray?.count == 0 {
            self.ratingH.constant = 0
            self.ratingsView.isHidden = true
        }
        else
        {
            self.ratingsView.isHidden = false
            var height: CGFloat = 0
            for cell in self.tableViewRatings.visibleCells {
                height += cell.bounds.height
            }
            print("Array count is in tableheight \((self.ratingsArray?.count)!) and height is \(height)")
            
            self.ratingH.constant = height
            self.tableViewRatings.reloadData()
        }
    }


}
extension ProviderViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        //self.topScrollView.constant = 0
        let defaultTop: CGFloat = CGFloat(0)
        
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
        if offset > 20  {
            //print("Im here in make header wethaer 2")
            header.makeHeaderWeather2(isFlaged: true, isprovider: true)
        }else {
            //print("Im here in make header wethaer 3")
            
            header.makeHeaderWeather2(isFlaged: false, isprovider: true)
                                      
        }
        
        //self.lastContentOffset = scrollView.contentOffset.y
        
        //viewTop.constant = currentTop
        
        
        
    }
    
}
extension ProviderViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.ratingsArray?.count)! == 0 {
            self.moreReviewsBt.isHidden = true
            return 0
        }else {
            
            if (self.ratingsArray?.count)! > 5 {
                self.moreReviewsBt.isHidden = false
                
                return 5
            }else {
                self.moreReviewsBt.isHidden = true
                print("Array count is in return \((self.ratingsArray?.count)!)")
                
                return (self.ratingsArray?.count)!
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRatings.dequeueReusableCell(withIdentifier: "RatingsTableViewCell", for: indexPath) as! RatingsTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(rate: (self.ratingsArray?[indexPath.row])!)
        return cell
    }
    
    
}
