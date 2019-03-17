//
//  AllCitiesViewController.swift
//  trid
//
//  Created by Black on 9/28/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Alamofire
import PureLayout
import SwiftyJSON
import SwiftHTTP
import GooglePlaces
import GooglePlacesSearchController
import UIScrollView_InfiniteScroll
import TTGSnackbar
import MessageUI
import SwipeCellKit
import BetterSegmentedControl
import FirebaseMessaging
import Firebase

struct InboxGroup: Codable {
    var group: TourGroup?
}
class AllCitiesViewController: MainBaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, CityServiceProtocol,MFMailComposeViewControllerDelegate {
    
  
    var isSwipeRightEnabled = true
    var isSpecialGroups: Bool = false
    var urlGetGroup: String = ""
    // identifier
    var isSelecctionGroups: Bool = false
    var kCellIdentifier = "CityCell"
    var page: Int = 1
    var isLogged: Bool = false
    var hasLoadMore: Bool = true
    var isLoading: Bool = false

    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var topViewConstratee: NSLayoutConstraint!
    var clickeble: Bool = false
    var searchUrl: String =  ""
    // outlet
    @IBOutlet weak var tableCity: UITableView!
    
    @IBOutlet weak var collectionGroup: UICollectionView!
    
    
    
    //// filter
    
    
    // property
    var isFirstLoaded = false
    var allCities : [GroupItemObject] = []
    
    @IBOutlet weak var no_slection_view: UIView!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var collectionViewTop: NSLayoutConstraint!
    
    var presentTransition: UIViewControllerAnimatedTransitioning?
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    @IBOutlet weak var allGroupBt: UIButton!
    @IBOutlet weak var topFilterConstrate: NSLayoutConstraint!

    
    /// groups types
    @IBOutlet weak var groupsType: BetterSegmentedControl!
    
    @IBOutlet weak var tourDurationTypes: BetterSegmentedControl!
    
    @IBOutlet weak var pricesTypes: BetterSegmentedControl!
    
    var grroupsType: [String] = ["Unique Groups", "Both",  "Reccuring Groups"]
    var tourDurationArray: [String] = ["Any", "Single Day", "2-4 Days", "9+ Days"]
    var pricesArray: [String] = ["Any", "$","$$","$$$","$$$$"]
    var menuOptionNameArray = ["All groups", "My groups", "One day groups","Multi days groups"]
    // multy selection
    var arrData = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedData = [String]() // This is selected cell data array
    var filterRequset: FilterGetSelect?
    var filters: [FilterCatgory]?  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  getCatgory(url: "")
        
        
    GMSPlacesClient.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")
        debugPrint("AllCitiesViewController viewDidLoad")
        collectionGroup.isHidden = true
        tableCity.isHidden = false
        
        allGroupBt.layer.cornerRadius = allGroupBt.bounds.size.height/2
        allGroupBt.clipsToBounds = true
        
        collectionGroup.delegate = self
        collectionGroup.dataSource = self
        // header
        header.makeHeaderAllCity()
        
        header.btnSearch.addTarget(self, action:#selector(AllCitiesViewController.headerBarSearchImpls), for: .touchUpInside)
        

        
        self.collectionGroup.register(UINib(nibName: "GroupCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GroupCollectionCell")
        // table
        self.tableCity.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
      //  self.tableCity.register(UINib(nibName: "GroupMediaCell", bundle: nil), forCellReuseIdentifier: "GroupMediaCell")
        self.tableCity.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        // Get Location
        _ = Le2Location.shared
        self.tableCity.addInfiniteScroll(handler: { (tableView) in
            if  self.hasLoadMore == true && !self.isLoading{
                self.isLoading = true
                print("Reach last tableView")
                self.getAllGroups(isSpecial: self.isSpecialGroups)
            }
            self.tableCity.finishInfiniteScroll()
            print("Im here addInfiniteScroll")
        })
        self.urlGetGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des"
        
        getAccessToken()
        

        // Notification
          NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: NotificationKey.refreshData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actionFilter), name: NotificationKey.actionFilter, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(feedBackFunc), name: NotificationKey.feedBack, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rateUsFunc), name: NotificationKey.rateUs, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mySelectionGroup), name: NotificationKey.my_selection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setGroupsType), name: NotificationKey.specialsClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setYoutubeView), name: NotificationKey.gridClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCities), name: NotificationKey.reloadCities, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserSignedInOut), name: NotificationKey.signedOut, object: nil)
        
        
    }
    func getAccessToken() {
        let defaults = UserDefaults.standard
        let access_token = defaults.string(forKey: "access_token")
        let expires_in = defaults.object(forKey: "expires_in")
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .second, value: 0, to : Date())
       
        if access_token == nil
        {
            
            getTokenReuqest()
        }
        else
        {
            if (expires_in as! Date) > date! {
              
              getAllGroups(isSpecial: self.isSpecialGroups)
            }
            else
            {
                getTokenReuqest()
                
            }
        }
    }
    func getTokenReuqest() {
        var params: [String: Any] = [:]
        params = ["grant_type": "client_credentials", "client_id": "2", "scope": "", "client_secret": "YErvt0T9iPupWJfLOChPSkJKcqZKZhP0DHntkcTL"]
        let url: String = ApiRouts.Web + "/oauth/token"
        HTTP.POST(url, parameters: params) { response in
            if response.error != nil {
                print("error \(response.error)")
                return
            }
            do {
                let accessToken : AccessToken =  try JSONDecoder().decode(AccessToken.self, from: response.data)
                let calendar = Calendar.current
                let date = calendar.date(byAdding: .second, value: accessToken.expires_in!, to : Date())
                self.setToUserDefaults(value: accessToken.access_token!, key: "access_token")
                self.setToUserDefaults(value: date, key: "expires_in")
                DispatchQueue.main.async {
                 
                    self.getAllGroups(isSpecial: self.isSpecialGroups)
                 
                    
                }
                print ("successed \(response.description)")
            }
            catch {
                
            }
        }
    }
   
    fileprivate func getGroupRequest(isSpecial: Bool) {
        if isSpecial {
        self.urlGetGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des&special_price=true"
        }else {
        self.urlGetGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des"
        }
        self.isSelecctionGroups = false
        AppLoading.showLoading()
        print("Url is \(self.urlGetGroup)")
        HTTP.GET(self.urlGetGroup) { response in
            if let error = response.error {
                print("Error is \(error)")
                 AppLoading.hideLoading()
            }
            let data = response.data
            do {
                let groups2 = try JSONDecoder().decode(FCity.GroupItem.self, from: data)
                
                //self.allCities?.data?.append(contentsOf: groups2)
                DispatchQueue.main.async {
                    
                    if self.page == 1 {
                        self.collectionViewTop.constant = self.header.frame.height
                        self.tableViewTop.constant = self.header.frame.height
                        self.topViewConstratee.constant = self.header.frame.height
                    }
                    if groups2.data != nil {
                        for group in groups2.data! {
                            self.allCities.append(group)
                        }
                        print("Groups count is \(self.allCities.count)")
                        self.page += 1
                        AppLoading.showSuccess()
                        self.tableCity.reloadData()
                        self.collectionGroup.reloadData()
                    }
                    if (groups2.total) != nil && (groups2.total)! == 0
                    {
                        self.hasLoadMore = false
                        return
                    }
                    if self.page > (groups2.last_page != nil ? groups2.last_page! : 0)
                    {
                        self.hasLoadMore = false
                        return
                    }
                    self.isLoading = false
                    
                }
                
            }
            catch let _ {
                
            }
            
        }
    }
    fileprivate func getSelectionGroup(idsgroup: String) {

        self.urlGetGroup = ApiRouts.ApiGroups + "/groups?ids=\(idsgroup)"
        AppLoading.showLoading()
        print("Url is \(self.urlGetGroup)")
        HTTP.GET(self.urlGetGroup) { response in
            if let error = response.error {
                print("Error is \(error)")
                AppLoading.hideLoading()
            }
            let data = response.data
            do {
                let groups2 = try JSONDecoder().decode(FCity.GroupItem.self, from: data)
                
                //self.allCities?.data?.append(contentsOf: groups2)
                DispatchQueue.main.async {
                    
                    if groups2.data != nil {
                        for group in groups2.data! {
                            self.allCities.append(group)
                        }
                        print("Groups count is \(self.allCities.count)")
                        self.page += 1
                        AppLoading.showSuccess()
                        self.tableCity.reloadData()
                        self.collectionGroup.reloadData()
                    }
                    if (groups2.total)! == 0
                    {
                        self.hasLoadMore = false
                        return
                    }
                    if self.page > (groups2.last_page!)
                    {
                        self.hasLoadMore = false
                        return
                    }
                    self.isLoading = false
                    let snackbar = TTGSnackbar(message: "Swipe the item to remove it.", duration: .long)
                    snackbar.show()
                }
                
            }
            catch let _ {
                
            }
            
        }
    }
    
    
    
    public func getAllGroups(isSpecial: Bool) {
        self.isLoading = true
         self.no_slection_view.isHidden = true
       // self.filterView.isHidden = true
        getGroupRequest(isSpecial: self.isSpecialGroups)
    }
    @objc func reloadCities(notification: NSNotification) {
        tableCity.reloadData()
        self.collectionGroup.reloadData()
        let obj = notification.object as? FCity
        if obj != nil {
            DispatchQueue.main.async {
                self.goto()
            }
        }
    }
    
    
    @objc func mySelectionGroup(notification: NSNotification) {

        /// seleeee
        let defaults = UserDefaults.standard
        let array = defaults.array(forKey: "GroupsId")  as? [Int] ?? [Int]()
        if array.count > 0 {
             self.no_slection_view.isHidden = true
            self.isSelecctionGroups = true
            var idsGroup: String = "["
            for id in array {
                idsGroup = idsGroup + "\(id),"
            }
            idsGroup = String(idsGroup.dropLast())
            idsGroup = idsGroup + "]"
            print("Idgroup = \(idsGroup)")
            self.allCities = []
            self.page = 1
            self.hasLoadMore = true
            self.tableCity.reloadData()
            getSelectionGroup(idsgroup: idsGroup)
            self.collectionGroup.isHidden = true
            self.tableCity.isHidden = false
            self.kCellIdentifier = "CityCell"
            self.tableCity.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
            self.tableCity.reloadData()
            
            
            
        }else {
             self.no_slection_view.isHidden = false
        }
        
    }
    @IBAction func allGroupClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.allCities = []
            self.page = 1
            self.hasLoadMore = true
            self.isSpecialGroups = false
            self.getAllGroups(isSpecial: self.isSpecialGroups)
        }
    }
    
    @objc func refreshData(notification: NSNotification) {
        DispatchQueue.main.async {
           self.tableCity.reloadData()
            self.collectionGroup.reloadData()
        }
    }
    @objc func actionFilter(notification: NSNotification) {
//        UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
//
//            self.filterView.slideInFromLeft(type: "top")
//        }) { (success) in
//
//            UIView.animate(withDuration: 0.5, delay: 0, options: .curveLinear, animations: {
//                self.filterView.isHidden = false
//            }, completion: nil)
//        }
    }
    fileprivate func hideFilter() {
//        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//
//            self.filterView.slideInFromLeft(type: "top")
//        }) { (success) in
//
//            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
//                self.filterView.isHidden = true
//            }, completion: nil)
//        }
    }
    @objc func feedBackFunc(notification: NSNotification) {
        
        if MFMailComposeViewController.canSendMail() {
            let mailComposerVC = MFMailComposeViewController()
            mailComposerVC.mailComposeDelegate = self
            mailComposerVC.setSubject("Snapgroup FeedBack ")
            mailComposerVC.setToRecipients(["info@snapgroup.co"])
            mailComposerVC.setMessageBody("", isHTML: false)
            self.present(mailComposerVC, animated: true, completion: nil)
        }else {
            let snackbar = TTGSnackbar(message: "Cannot send mail", duration: .middle)
            snackbar.icon = UIImage(named: "AppIcon")
            snackbar.show()
        }
        
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        print("MFMailComposeViewController \(result)")
        controller.dismiss(animated: false, completion: nil)
    }
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/1363741326") else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @objc func rateUsFunc(notification: NSNotification) {
        
        let bundleID = Bundle.main.bundleIdentifier

        print("My App id  is \(bundleID!)")
        rateApp(appId: bundleID!) { success in
                print("RateApp \(success)")
            }
        
        
        
    }
    
    @objc func setGroupsType(notification: NSNotification) {
        DispatchQueue.main.async {
            self.allCities = []
            self.page = 1
            self.hasLoadMore = true
            self.isSpecialGroups = (notification.object as? Bool)!
            self.getAllGroups(isSpecial: self.isSpecialGroups)
        }
    }
    
    @objc func setYoutubeView(notification: NSNotification) {
        DispatchQueue.main.async {
            let obj = notification.object as? String
            self.tableCity.reloadData()
            self.collectionGroup.reloadData()
            if obj != nil && obj == "GroupCollectionCell" {
                 self.collectionGroup.register(UINib(nibName: "GroupCollectionCell", bundle: nil), forCellWithReuseIdentifier: "GroupCollectionCell")
                self.collectionGroup.isHidden = false
                self.tableCity.isHidden = true
                self.collectionGroup.reloadData()
                
            }else {
                self.collectionGroup.isHidden = true
                self.tableCity.isHidden = false
            self.kCellIdentifier = obj!
            self.tableCity.register(UINib(nibName: "GroupMediaCell", bundle: nil), forCellReuseIdentifier: "GroupMediaCell")
            self.tableCity.reloadData()
            }

        }
        
    }
    
    @objc func onUserSignedInOut(notification: NSNotification) {
        filterAllCities()
        tableCity.reloadData()
        self.collectionGroup.reloadData()
    }
    
    func filterAllCities() {
       //allCities = AppState.getCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppState.clearCurrentCity()
        CityService.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstLoaded{
            isFirstLoaded = true
        }
       // multySelctionH.constant = multiSelectCollection.contentSize.height
        print("Device Id \(UIDevice().type) and header hight is \(header.frame.height)")
        collectionViewTop.constant = header.frame.height
        tableViewTop.constant = header.frame.height
        topViewConstratee.constant = header.frame.height
   

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CityService.shared.delegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // Table delegate & datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allCities.count
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if kCellIdentifier == "GroupMediaCell" {
            return 130
        }else {
            return CityCell.cellHeight()
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if kCellIdentifier == "GroupMediaCell" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMediaCell", for: indexPath) as! GroupMediaCell
            // parse data
            let city = allCities[indexPath.row]
            cell.makeCity(city)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
            // parse data
            let city = allCities[indexPath.row]
            cell.delegate = self
            cell.makeCity(city)
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionGroup {
        if !clickeble {
            self.clickeble = true
            
        getGroup(group_id:(self.allCities[indexPath.row].id)!)
        }
        }else {
            
            let strData = arrData[indexPath.item]
            
            if arrSelectedIndex.contains(indexPath) {
                arrSelectedIndex = arrSelectedIndex.filter { $0 != indexPath}
                arrSelectedData = arrSelectedData.filter { $0 != strData}
            }
            else {
                arrSelectedIndex.append(indexPath)
                arrSelectedData.append(strData)
            }
            
            collectionView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !clickeble {
            self.clickeble = true
      getGroup(group_id:(self.allCities[indexPath.row].id)!)
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionGroup {
         return self.allCities.count
        }else {
           return (self.arrData.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionGroup.dequeueReusableCell(withReuseIdentifier: "GroupCollectionCell", for: indexPath) as! GroupCollectionCell
        
        cell.group_label.layer.shadowColor = UIColor.black.cgColor
        cell.group_label.layer.shadowOpacity = 0.5
        cell.group_label.layer.shadowOffset = CGSize.zero
        cell.group_label.layer.shadowRadius = 4
        let city = allCities[indexPath.row]
        cell.makeCity(city)
        return cell
       
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionGroup {
            return 0.0
        }else {
            return 0
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == collectionGroup {
        return 0.0
        }else {
            return 2
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == collectionGroup {
        let padding: CGFloat =  2
        let collectionViewSize = UIScreen.main.bounds.width
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        }else {

            let collectionViewSize = UIScreen.main.bounds.width - 27
            return CGSize(width: collectionViewSize/3, height: 30)
            //return CGSize(width: 100, height: 30)
            
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == collectionGroup {
        cell.layer.transform = CATransform3DMakeScale(1.15, 1.05, 1)
        UIView.animate(withDuration: 0.3, delay: 0.025, options: .allowUserInteraction, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
            
        if indexPath.row + 1 == self.allCities.count && hasLoadMore == true && !self.isLoading{
            
                DispatchQueue.main.async {
                    self.isLoading = true
                    self.getAllGroups(isSpecial: self.isSpecialGroups)
                    
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.transform = CATransform3DMakeScale(1.15, 1.05, 1)
        UIView.animate(withDuration: 0.3, delay: 0.025, options: .allowUserInteraction, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }, completion: nil)
    }
    
    // city protocol
    func cityServiceAdded(_ city: FCity) {
        filterAllCities()
        tableCity.reloadData()
        self.collectionGroup.reloadData()
//        tableCity.beginUpdates()
//        let indexpath = IndexPath(row: CityService.shared.cities.count-1, section: 0)
//        tableCity.insertRows(at: [indexpath], with: .fade)
//        tableCity.endUpdates()
    }
    
    func cityServiceChangedAt(index: Int) {
        filterAllCities()
        tableCity.reloadData()
//        let indexpath = IndexPath(row: index, section: 0)
//        tableCity.reloadRows(at: [indexpath], with: .right)
    }
    
    func cityServiceRemovedAt(index: Int) {
        filterAllCities()
        tableCity.reloadData()
//        let indexpath = IndexPath(row: index, section: 0)
//        tableCity.deleteRows(at: [indexpath], with: .fade)
    }
    
    func openVideoUrl(_ url: String?) {
        if url == nil {
            return
        }
        let player = AVPlayer(url: URL(string: url!)!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    

    // MARK: - Override parent func
    @objc func headerBarSearchImpls(){
        
        let searchVC = SearchCityViewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
        
        // go to city search
//        let placePickerController = GMSAutocompleteViewController()
//        placePickerController.delegate = self
//        UINavigationBar.appearance().backgroundColor = UIColor(netHex: AppSetting.Color.blue)
//        UIBarButtonItem.appearance().tintColor = UIColor.white
//        UINavigationBar.appearance().barTintColor = UIColor(netHex: AppSetting.Color.blue)
//        UINavigationBar.appearance().isTranslucent = false
//        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//
//
//
//        presentTransition = RightToLeftTransition()
//        dismissTransition = LeftToRightTransition()
//
//        placePickerController.modalPresentationStyle = .custom
//        placePickerController.transitioningDelegate = self
//
//        present(placePickerController, animated: true, completion: { [weak self] in
//            self?.presentTransition = nil
//        })
        
        
        //present(placePickerController, animated: false, completion: nil)
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
    
    func getGroup(group_id: Int ){
        let urlstring: String = ApiRouts.ApiGroups + "/groups/\((group_id))"
        
        print("Url string is \(urlstring)")
        AppLoading.showLoading()

        HTTP.GET((urlstring)){response in
            if response.error != nil {
                DispatchQueue.main.async {
                    AppLoading.hideLoading()
                    self.clickeble = false
                    return
                }
                
            }
            do {
                let  group2  = try JSONDecoder().decode(InboxGroup.self, from: response.data)
                AppState.currentGroup = group2.group!

                DispatchQueue.main.sync {
                    AppLoading.hideLoading()
                   
                    
                    let device_id = UIDevice.current.identifierForVendor!.uuidString
                    print("firebase-1234 before")
                    Analytics.logEvent("clicked_a_group", parameters: [
                        "device_id": device_id as NSObject,
                        "group_id": (group2.group?.id)! as NSObject
                        ])
                    print("firebase-1234 In")
                    
                    if ((group2.group?.group_leader_id)! == 1969) {
                        Analytics.logEvent("clicked_viator", parameters: [
                            "device_id": device_id as NSObject,
                            "group_id": (group2.group?.id)! as NSObject
                            ])
                    }
                    if ((group2.group?.id)! == 1000) {
                        Analytics.logEvent("clicked_bicester", parameters: [
                            "device_id": device_id as NSObject,
                            "group_id": (group2.group?.id)! as NSObject
                            ])
                    }
                    if ((group2.group?.id)! == 1007) {
                        Analytics.logEvent("clicked_support_il", parameters: [
                            "device_id": device_id as NSObject,
                            "group_id": (group2.group?.id)! as NSObject
                            ])
                    }
                    let params: [String: Any] = ["device_id": (device_id) , "group_id": (AppState.currentGroup?.id!)! , "type": ApiRouts.VisitGroupType]
                    setCheckGroupTrue(member_id: -1, groupID: (AppState.currentGroup?.id)!)
                    print("PARAMS - \(params)")
                    ApiRouts.actionRequest(parameters: params)
                        let isOpen : Bool = group2.group?.open != nil ? (group2.group?.open!)! : true
                        if group2.group?.role  == nil {
                            if isOpen {
                                AppState.isSelecctionGroups = self.isSelecctionGroups
                                self.goto()
                            }
                        }else{
                            AppState.isSelecctionGroups = self.isSelecctionGroups
                            self.goto()
                        }
                    self.clickeble = false
                }
            }
            catch let error{
                self.clickeble = false
                AppLoading.hideLoading()
                print("getGroup : \(error)")
                
            }
        }
    }
    
}

extension AllCitiesViewController : UIAlertViewDelegate {
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        //print("aaaa \(buttonIndex)")
        // 0-Cancel 1-Rate 2-Feedback
        if buttonIndex == 1 {
            Global.openRateApp()
        }
        else if buttonIndex == 2 {
            Global.sendFeedback(controller: self)
        }
    }
}

extension AllCitiesViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.placeID)")
        self.page = 1
        self.allCities = []
        let urlGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des&place_id=\(place.placeID)"
        self.searchUrl = urlGroup
        getAllGroups(isSpecial: self.isSpecialGroups)
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}

extension AllCitiesViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}
class RightToLeftTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        container.addSubview(toView)
        toView.frame.origin = CGPoint(x: toView.frame.width, y: 0)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            toView.frame.origin = CGPoint(x: 0, y: 0)
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}

class LeftToRightTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let duration: TimeInterval = 0.25
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        
        container.addSubview(fromView)
        fromView.frame.origin = .zero
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: {
            fromView.frame.origin = CGPoint(x: fromView.frame.width, y: 0)
        }, completion: { _ in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(true)
        })
    }
    
}
extension AllCitiesViewController: SwipeTableViewCellDelegate {
    

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if self.isSelecctionGroups {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            let defaults = UserDefaults.standard
            let array = defaults.array(forKey: "GroupsId")  as? [Int] ?? [Int]()
            let farray = array.filter {$0 != (self.allCities[indexPath.row].id)!}
            self.setToUserDefaults(value: farray, key: "GroupsId")
            self.allCities.remove(at: indexPath.row)
            if self.allCities.count == 0 {
                self.no_slection_view.isHidden = false
            }
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")
        
        return [deleteAction]
        }else {
            return []
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
 
}
extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}

