//
//  AgentViewControler.swift
//  Snapgroup
//
//  Created by snapmac on 05/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import SwiftHTTP
import UIKit
import PopupDialog
import Firebase

class AgentViewControler: DashboardBaseViewController {

    @IBOutlet weak var bottomConstrate: NSLayoutConstraint!
    @IBOutlet weak var topConstrate: NSLayoutConstraint!
    var allCities : [GroupItemObject] = []
    var page: Int = 1
    var isLogged: Bool = false
    var hasLoadMore: Bool = true
    var isLoading: Bool = false
    // Agent info
    @IBOutlet weak var agentPhone: UILabel!
    @IBOutlet weak var agentEmail: UILabel!
    @IBOutlet weak var agentName: UILabel!
    @IBOutlet weak var agentImg: UIImageView!
    @IBOutlet weak var agentDescrption: UILabel!
    @IBOutlet weak var agentDescrptionView: UIView!
    
    
    // socail media
    
    @IBOutlet weak var socialMediaStack: UIStackView!
    @IBOutlet weak var instagramView: UIView!
    @IBOutlet weak var googlePlusView: UIView!
    @IBOutlet weak var youtubeView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var linkdinView: UIView!
    
    
    // manged group
    @IBOutlet weak var mangedGroupView: UIView!
    @IBOutlet weak var mangeGroupCollectionView: UICollectionView!
    
    // ratings
    @IBOutlet weak var ratingH: NSLayoutConstraint!
    @IBOutlet weak var tableViewRatings: UITableView!
    @IBOutlet weak var ratingsView: UIView!
      @IBOutlet weak var moreReviewsBt: UIButton!
    var ratingsArray: [RatingModel]? = []
    var count: Int = 5

    // read more
    @IBOutlet weak var readMoreLbl: UIButton!

    @IBOutlet weak var lineDescrption: UIView!
    
    @objc func back(){
        tabBarController?.selectedIndex = 0
    }
    var currentGroup: TourGroup?

    
    @IBAction func mreReviewClick(_ sender: Any) {
            let provider = AllRatingsViewController()
            self.navigationController?.pushViewController(provider, animated: true)
        
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
        ProviderInfo.model_type = "members"
        ProviderInfo.model_id =  (AppState.currentGroup?.group_leader_id) != nil ? (AppState.currentGroup?.group_leader_id)! : -1
        present(popup, animated: true, completion: nil)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar.setBarHide()
        instagramView.addTapGestureRecognizer {
            if  (self.currentGroup?.group_leader?.profile?.instagram) != nil {
                let url = URL(string:(self.currentGroup?.group_leader?.profile?.instagram)!)
            if UIApplication.shared.canOpenURL(url!) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url!)
                }
            }
            }
        }
        mangeGroupCollectionView.register(UINib(nibName: "ServiceView", bundle: nil), forCellWithReuseIdentifier: "ServiceView")
        
        tableViewRatings.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingsTableViewCell")
        
        self.mangeGroupCollectionView.delegate = self
        self.mangeGroupCollectionView.dataSource = self
        
        self.tableViewRatings.delegate = self
        self.tableViewRatings.dataSource = self
        self.tableViewRatings.isScrollEnabled = false
        header.makeHeaderGroupLeader()
         header.btnBack.addTarget(self, action:#selector(ServicesViewControler.back), for: .touchUpInside)
        currentGroup = AppState.currentGroup!
       getSelectionGroup()
        
        
     
       
        
        
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
    
    fileprivate func getSelectionGroup() {
        
        let url: String = ApiRouts.ApiGroups+"/groups?group_leader_id=\((currentGroup?.group_leader?.id)!)"
       // AppLoading.showLoading()
        print("Url is \(url)")
        HTTP.GET(url) { response in
            if let error = response.error {
                print("Error is \(error)")
                AppLoading.hideLoading()
            }
            let data = response.data
            do {
                let groups2 = try JSONDecoder().decode(FCity.GroupItem.self, from: data)
                DispatchQueue.main.async {
                    
                    if groups2.data != nil {
                        for group in groups2.data! {
                            self.allCities.append(group)
                        }
                        print("Groups count is \(self.allCities.count)")
                        self.page += 1
                       // AppLoading.showSuccess()
                        self.mangeGroupCollectionView.reloadData()
                    }
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
                
                
                
            }
            catch let _ {
                
            }
            
        }
    }
    
    func getRatings() {
        self.ratingsArray = []
        let url = ApiRouts.Api+"/ratings?model_id=\((AppState.currentGroup?.group_leader_id)!)&model_type=members"
        ProviderInfo.model_id = (AppState.currentGroup?.group_leader_id)!
        ProviderInfo.model_type = "members"
        print("Rating url is === \(url)")
        HTTP.GET(url, parameters:[])
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
    
    @IBAction func readMoreClick(_ sender: Any) {
        if self.readMoreLbl.titleLabel?.text == "Read More"
        {
            self.agentDescrption.numberOfLines = 0
            self.agentDescrption.sizeToFit()
            self.readMoreLbl.setTitle("Read Less", for: .normal)
        }else {
            self.agentDescrption.numberOfLines = 3
            self.agentDescrption.sizeToFit()
            self.readMoreLbl.setTitle("Read More", for: .normal)
            
        }
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded();})
    }
    
    fileprivate func setSocialMedia() {
        if (currentGroup?.group_leader?.profile?.youtube) != nil {
            youtubeView.alpha = 1
        }else{
            youtubeView.alpha = 0.5
        }
        if (currentGroup?.group_leader?.profile?.linkedin) != nil {
            linkdinView.alpha = 1
        }else{
            linkdinView.alpha = 0.5
        }
        if (currentGroup?.group_leader?.profile?.instagram) != nil {
            instagramView.alpha = 1
        }else{
            instagramView.alpha = 0.5
        }
        if (currentGroup?.group_leader?.profile?.google_plus) != nil {
            googlePlusView.alpha = 1
        }else{
            googlePlusView.alpha = 0.5
        }
        if (currentGroup?.group_leader?.profile?.facebook) != nil {
            facebookView.alpha = 1
        }else{
            facebookView.alpha = 0.5
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
           NotificationCenter.default.addObserver(self, selector: #selector(getRatingsFunc), name: NotificationKey.writeRate_Leader, object: nil)
        if AppState.isGroupLeader != nil && (AppState.isGroupLeader)! == false {
            //companyProfile.isHidden = false
            socialMediaStack.isHidden = true
            agentName.text = (currentGroup?.group_leader?.company?.name) != nil ? (currentGroup?.group_leader?.company?.name!)! : ""
            
            if currentGroup?.group_leader?.company?.images != nil && (currentGroup?.group_leader?.company?.images?.count)! > 0 {
                var urlString =  ApiRouts.Media + (currentGroup?.group_leader?.company?.images?[0].path)!
                print("Url string is \(urlString)")
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                let url = URL(string: urlString)
                if url != nil {
                    self.agentImg.sd_setImage(with: url!, completed: nil)
                }
            }
            else
            {
                self.agentImg.image = UIImage(named: "img-default")
            }
            
            agentEmail.text = (currentGroup?.group_leader?.company?.website) != nil ? "\((currentGroup?.group_leader?.company?.website!)!) " : ""
            if currentGroup?.group_leader?.company?.phone != nil {
                agentPhone.text = (currentGroup?.group_leader?.company?.phone) != nil ? "\((currentGroup?.group_leader?.company?.phone!)!) " : ""
            }else {
                agentPhone.text = (currentGroup?.group_leader?.company?.address) != nil ? "\((currentGroup?.group_leader?.company?.address!)!) " : ""
            }
            if currentGroup?.group_leader?.company?.about == nil || ((currentGroup?.group_leader?.company?.about != nil && (currentGroup?.group_leader?.company?.about)! == "")){
                agentDescrptionView.isHidden = true
                lineDescrption.isHidden = true
            }else {
                agentDescrptionView.isHidden = false
                lineDescrption.isHidden = false
            }
            agentDescrption.text = (currentGroup?.group_leader?.company?.about) != nil ? "\((currentGroup?.group_leader?.company?.about!)!) " : ""
        }else {
            socialMediaStack.isHidden = false
            if currentGroup?.group_leader?.images != nil && (currentGroup?.group_leader?.images?.count)! > 0 {
                var urlString =  ApiRouts.Media + (currentGroup?.group_leader?.images?[0].path)!
                print("Url string is \(urlString)")
                urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                let url = URL(string: urlString)
                if url != nil {
                    self.agentImg.sd_setImage(with: url!, completed: nil)
                }
            }
            else
            {
                self.agentImg.image = UIImage(named: "img-default")
            }
           setSocialMedia()
           
            //   companyProfile.isHidden = true
            let groupLeaderFirstName: String = (currentGroup?.group_leader?.profile?.first_name) != nil ? "\((currentGroup?.group_leader?.profile?.first_name!)!) " : ""
            let groupLeaderLastName: String = (currentGroup?.group_leader?.profile?.last_name) != nil ? "\((currentGroup?.group_leader?.profile?.last_name!)!) " : ""
            
            agentName.text = groupLeaderFirstName + groupLeaderLastName
            
            agentEmail.text = (currentGroup?.group_leader?.email) != nil ? "\((currentGroup?.group_leader?.email!)!) " : ""
            agentPhone.text = (currentGroup?.group_leader?.phone) != nil ? "\((currentGroup?.group_leader?.phone!)!) " : ""
            if currentGroup?.group_leader?.profile?.about == nil || ((currentGroup?.group_leader?.profile?.about != nil && (currentGroup?.group_leader?.profile?.about)! == "")){
                agentDescrptionView.isHidden = true
                lineDescrption.isHidden = true
            }else {
                agentDescrptionView.isHidden = false
                lineDescrption.isHidden = false
            }
            agentDescrption.text = (currentGroup?.group_leader?.profile?.about) != nil ? "\((currentGroup?.group_leader?.profile?.about!)!) " : ""
        }
        if self.agentDescrption.calculateMaxLines() > 4 {
            self.readMoreLbl.isHidden = false
            self.agentDescrption.numberOfLines = 4
            
        }
        else{
            self.readMoreLbl.isHidden = true
        }
        getRatings()
    }
    override func viewDidAppear(_ animated: Bool){
        topConstrate.constant = header.frame.height
        bottomConstrate.constant = tabbar.frame.height
    }
}

extension AgentViewControler: UITableViewDelegate, UITableViewDataSource {
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


extension AgentViewControler: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countServices: Int = self.allCities.count

        return countServices
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getGroup(group_id: (self.allCities[indexPath.row].id)!)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mangeGroupCollectionView.dequeueReusableCell(withReuseIdentifier: "ServiceView", for: indexPath) as! ServiceView
        
        if allCities[indexPath.row].images != nil && (allCities[indexPath.row].images?.count)! > 0 {
            let urlPhotot  = ApiRouts.Media + (allCities[indexPath.row].images?[0].path)!
            cell.serviceImg.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
        }else {
            if allCities[indexPath.row].image != nil {
                let urlPhotot  = ApiRouts.Media + (allCities[indexPath.row].image)!
                
                cell.serviceImg.sd_setImage(with: URL(string: urlPhotot), placeholderImage: UIImage(named: "img-default"))
            }else {
               cell.serviceImg.image = UIImage(named: "img-default")
            }
            
            // self.group_image.image = UIImage(named: "img-default")
        }
        if allCities[indexPath.row].translations != nil && (allCities[indexPath.row].translations?.count)! >  0 {
            cell.serviceLbl.text = (allCities[indexPath.row].translations?[0].title)!
            
        }
        cell.serviceLbl.textAlignment = .left
        cell.constrateLeading.constant = 0
        cell.imageiCON.isHidden = true
        return cell
    }
    func getGroup(group_id: Int ){
        let urlstring: String = ApiRouts.ApiGroups + "/groups/\((group_id))"
        
        print("Url string is \(urlstring)")
        AppLoading.showLoading()
        
        HTTP.GET((urlstring)){response in
            if response.error != nil {
                DispatchQueue.main.async {
                    AppLoading.hideLoading()
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
                    let params: [String: Any] = ["device_id": (device_id) , "group_id": (AppState.currentGroup?.id!)! , "type": ApiRouts.VisitGroupType]
                    setCheckGroupTrue(member_id: -1, groupID: (AppState.currentGroup?.id)!)
                    print("PARAMS - \(params)")
                    ApiRouts.actionRequest(parameters: params)
                    let isOpen : Bool = group2.group?.open != nil ? (group2.group?.open!)! : true
                    if group2.group?.role  == nil {
                        if isOpen {
                            self.goto()
                        }
                    }else{
                        self.goto()
                    }
                }
            }
            catch let error{
                AppLoading.hideLoading()
                print("getGroup : \(error)")
                
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 200)
    }
    
    
}
