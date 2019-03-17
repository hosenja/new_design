//
//  MenuViewController
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SDWebImage
import PureLayout
import FirebaseAuth
import MessageUI

enum MenuType : Int {
    case allCities = 0
    case bookTicket = 1
    case myPlan = 2
    case myPost = 3
    case favorite = 4
    case profile = 5
    case aboutApp = 6
    case privacy = 7
    case feedback = 8
    case reviewApp = 9
    case setting = 10
    case logOut = 11
    case visaOnline = 12
}

protocol MenuViewControllerDelegate {
    func menuPopToSignIn()
    func menuPopToSignUp()
}

class MenuViewController: UIViewController {
    
    // Outlet
    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var viewNotSigned: UIView!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var constraintMenuTrailing: NSLayoutConstraint!
    @IBOutlet weak var tableMenu: UITableView!
    @IBOutlet weak var labelVersion: UILabel!
    
    var delegate : MenuViewControllerDelegate?
    
    // values ==> Tạm thời disable section 1
    let menuSections = ["", Localized.information]
    let menuTitles = [Int(0): [MenuType.allCities,
                               MenuType.bookTicket,
                                MenuType.visaOnline],
                      Int(1): [ MenuType.feedback,
                               MenuType.reviewApp,
                               MenuType.logOut
                              ,MenuType.setting,
                                MenuType.favorite]]
    
    let menuNotSignedTitles = [Int(0):  [MenuType.allCities,MenuType.allCities,
                                        MenuType.bookTicket,
                                        MenuType.visaOnline],
                               Int(1): [MenuType.feedback,
                                        MenuType.reviewApp,
                                        MenuType.setting,
                                        MenuType.favorite]]
    
    let titles = [MenuType.allCities: Localized.AllCities.uppercased(),
                  MenuType.bookTicket: Localized.BookTicket.uppercased(),
                  MenuType.visaOnline: Localized.VisaOnline.uppercased(),
                  MenuType.myPlan: Localized.myPlan,
                  MenuType.myPost: Localized.myPost,
                  MenuType.favorite: Localized.favorite,
                  MenuType.profile: Localized.profile,
                  MenuType.feedback: Localized.feedback,
                  MenuType.reviewApp: Localized.reviewApp,
                  MenuType.setting: Localized.setting,
                  MenuType.logOut: Localized.logOut]
    
    let icons = [MenuType.allCities: "menuallgroups",
                 MenuType.bookTicket: "menuspecial",
                 MenuType.visaOnline: "menumygroups",
                 MenuType.myPlan: "menu-myplan",
                 MenuType.myPost: "menu-mypost",
                 MenuType.favorite: "menuprivacy",
                 MenuType.profile: "menu-profile",
                 MenuType.feedback: "menufeedback",
                 MenuType.reviewApp: "menurate",
                 MenuType.setting: "menu-setting",
                 MenuType.logOut: "menu-profile"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(netHex: AppSetting.Color.settingblue)
        // remove header scrollview space
        self.automaticallyAdjustsScrollViewInsets = false
        // margin right
        
        constraintMenuTrailing.constant = AppSetting.App.screenSize.width/2 - CGFloat(MainViewController.offsetX) + 10.0
         tableMenu.register(UINib(nibName: "MenuFilterCell", bundle: nil), forCellReuseIdentifier: "MenuFilterCell")
        tableMenu.register(UINib(nibName: MenuCell.className, bundle: nil), forCellReuseIdentifier: MenuCell.className)
        if tableMenu.tableHeaderView != nil {
            tableMenu.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: tableMenu.bounds.width, height: 80)
            tableMenu.tableHeaderView?.backgroundColor = .clear
        }
       // tableMenu.backgroundColor = .clear
        
        // Header
        imgAvatar.layer.cornerRadius = imgAvatar.bounds.height/2
        imgAvatar.clipsToBounds = true
        imgAvatar.layer.shadowColor = UIColor.gray.cgColor
        imgAvatar.layer.shadowRadius = 2
        imgAvatar.layer.shadowOpacity = 0.6
        
        btnSignIn.layer.borderColor = UIColor.white.cgColor
        btnSignIn.layer.borderWidth = 1
        btnSignIn.layer.cornerRadius = btnSignIn.bounds.height/2
        btnSignIn.clipsToBounds = true
        btnSignIn.setTitle(Localized.signIn, for: UIControl.State.normal)
        btnSignUp.layer.borderColor = UIColor.white.cgColor
        btnSignUp.layer.borderWidth = 1
        btnSignUp.layer.cornerRadius = btnSignIn.bounds.height/2
        btnSignUp.clipsToBounds = true
        btnSignUp.setTitle(Localized.signUp, for: UIControl.State.normal)
        
        // User Info
        handleSigned(out: AppState.currentUser == nil)
        
        // App Version
        labelVersion.text =   "SNAPGROUP  V" + (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String)
        
        // Register Notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserSignedIn), name: NotificationKey.signedIn, object: nil)
       makeUserInfo()
       
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - HANDLE Notification
    @objc func handleUserSignedIn(notification: Notification) {
        handleSigned(out: false)
    }
    
    
    // MARK: - UI
    func handleSigned(out: Bool){

        
        makeUserInfo()
        
        tableMenu.reloadData()
    }
    
    func makeUserInfo() {
        let defaults = UserDefaults.standard
        let isLogged = defaults.bool(forKey: "isLogged")
        
        if isLogged {
            imgAvatar.isHidden = false
            labelName.isHidden = false
            viewNotSigned.isHidden = true
            let first = defaults.string(forKey: "first_name")
            let last = defaults.string(forKey: "last_name")
            let profile_image = defaults.string(forKey: "profile_image")
            labelName.text = "\(first != nil ? (first)! : "" ) \(last != nil ? (last)! : "" )"
            if profile_image != nil {
                if profile_image == "no value"
                {
                    self.imgAvatar.image = UIImage(named : "default user")
                }
                else {
                    var urlString : String?
                    if (profile_image?.contains("http"))!
                    {
                        urlString = (profile_image)!
                    }else{
                        urlString = ApiRouts.Media + (profile_image)!
                    }
                    print("Url string is \(urlString)")
                    urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
                    var url = URL(string: urlString!)
                    if url != nil {
                        self.imgAvatar.sd_setImage(with: url!, completed: nil)
                    }
                }
                
            }else
            {
                self.imgAvatar.image = UIImage(named : "default user")
            }
        }else {
            imgAvatar.isHidden = true
            labelName.isHidden = true
            viewNotSigned.isHidden = false
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Actions
    @IBAction func actionOpenSignIn(_ sender: Any) {
        if delegate?.menuPopToSignIn != nil {
            delegate?.menuPopToSignIn()
        }
    }
    
    @IBAction func actionOpenSignUp(_ sender: Any) {
        if delegate?.menuPopToSignUp != nil {
            delegate?.menuPopToSignUp()
        }
    }
    
    func actionFeedback(){
        print("Im in actionRateApp")
        NotificationCenter.default.post(name: NotificationKey.feedBack, object: false)
        sideMenuViewController?.hideMenuViewController()
    }
    func actionSettings(){
        print("Im in actionRateApp")
        sideMenuViewController?.hideMenuViewController()
        let controller = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: false)
        
                
    }
    func actionGoToPrivacy(){
        print("Im in actionRateApp")
        sideMenuViewController?.hideMenuViewController()
        let controller = PrivacyViewController(nibName: "PrivacyViewController", bundle: nil)
        self.navigationController?.pushViewController(controller, animated: false)
        
        
    }
    func actionRateApp(){
        print("Im in actionRateApp")
        NotificationCenter.default.post(name: NotificationKey.rateUs, object: false)
        sideMenuViewController?.hideMenuViewController()
       
    }
    
    func actionOpenAbout(){
        print("Im in actionOpenAbout")

        let url = AppUrl.website
        openWeb(url: url, title: Localized.aboutApp)
    }
    
    func actionOpenPrivacy(){
        print("Im in actionOpenPrivacy")

        let url = AppUrl.privacy
        openWeb(url: url, title: Localized.privacy)
    }
    
    func openWeb(url: String, title: String){
        print("Im in openWeb")

        Utils.openWeb(url: url, title: title, controller: self, navigation: self.navigationController)
    }
    
    func actionAllCities() {
        print("Im in actionAllCities")
        NotificationCenter.default.post(name: NotificationKey.specialsClick, object: false)
        sideMenuViewController?.hideMenuViewController()
    }
    func actionFilter() {
        sideMenuViewController?.hideMenuViewController()
        print("Im in actionAllCities")
       // NotificationCenter.default.post(name: NotificationKey.actionFilter, object: false)
        
    }
    func setMySelction() {
        print("Im in My Selection")
       NotificationCenter.default.post(name: NotificationKey.my_selection, object: false)
        sideMenuViewController?.hideMenuViewController()
    }
    func actionBookTicket(){
        NotificationCenter.default.post(name: NotificationKey.specialsClick, object: true)
        print("Im in actionBookTicket")
        sideMenuViewController?.hideMenuViewController()

//        sideMenuViewController?.hideMenuViewController()
//        NotificationCenter.default.post(name: NotificationKey.gridClick, object: nil)
    }
}

// MARK: - Table delegate
extension MenuViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let header = menuSections[section]
        if header == "" {
            return 20.0
        }
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height))
        header.backgroundColor = .clear
        // add separator line
        let sep = UIImageView(frame: CGRect(x: 0, y: 9, width: tableView.bounds.width, height: 1))
        sep.backgroundColor = UIColor(netHex: 0x106AB0)
        sep.alpha = 0.4
        header.addSubview(sep)
        // add title
        let title = menuSections[section]
        if title != "" {
            let label = UILabel(frame: CGRect(x: 0, y: height - 20 - 10, width: tableView.bounds.width, height: 20))
            label.backgroundColor = .clear
            label.alpha = 0.6
            label.textColor = .white
            label.font = UIFont(name: AppSetting.Font.roboto, size: AppSetting.FontSize.normal)
            label.text = title
            header.addSubview(label)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = (AppState.currentUser != nil) ? menuTitles[indexPath.section]?[indexPath.row] : menuNotSignedTitles[indexPath.section]?[indexPath.row]
        tableView.visibleCells.forEach { cell in
            
            if let cell = cell as? MenuCell {
                cell.backgroundColor = UIColor.clear
                if cell.indexpathCell == indexPath {
                    cell.label.textColor = UIColor.black
                }else {
                    cell.label.textColor = UIColor.white
                }
            }
            
        }
        
        //let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        switch type! as MenuType{
        case .allCities:
            print("my all cites")
            if indexPath.row == 0 {
                 actionFilter()
            }else {
            actionAllCities()
            }
            //cell?.backgroundColor = .clear
            break
        case .bookTicket:
            print("my special")

            actionBookTicket()
            break
        case .visaOnline:
            // my slection
            print("my selection")
            setMySelction()
            //Utils.openUrl(AppSetting.Visa.url)
            break
        case MenuType.myPlan:
            break
        case MenuType.myPost:
            break
        case MenuType.favorite:
            actionGoToPrivacy()
            break
        case MenuType.profile:
            break
        case MenuType.aboutApp:
            actionOpenAbout()
            break
        case MenuType.privacy:
            actionOpenPrivacy()
            break
        case MenuType.feedback:
            actionFeedback()
            break
        case MenuType.setting:
            actionSettings()
            break
        case MenuType.reviewApp:
            actionRateApp()
            break
        case MenuType.logOut:
            // action logout
            debugPrint("LOG OUT")
            do{
                // signout
                try Auth.auth().signOut()
                // #set-current-user
                AppState.currentUser = nil
                // clear credential
                AppState.setSignInInfo(nil)
                // Notification
                NotificationCenter.default.post(name: NotificationKey.signedOut, object: nil)
                // ui
                handleSigned(out: true)
            }
            catch {
                self.view.makeToast(error.localizedDescription)
            }
            break
        }
    }
}

// MARK: - Table datasource
extension MenuViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int{
        return AppState.currentUser != nil ? menuTitles.keys.count : menuNotSignedTitles.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return AppState.currentUser != nil ? menuTitles[section]!.count : menuNotSignedTitles[section]!.count
    }
    @objc func listClick(gesture: UIGestureRecognizer) {
        sideMenuViewController?.hideMenuViewController()
        NotificationCenter.default.post(name: NotificationKey.gridClick, object: "GroupMediaCell")
    }
    @objc func instaClick(gesture: UIGestureRecognizer) {
        sideMenuViewController?.hideMenuViewController()
        NotificationCenter.default.post(name: NotificationKey.gridClick, object: "CityCell")
    }
    @objc func mediaClick(gesture: UIGestureRecognizer) {
        sideMenuViewController?.hideMenuViewController()
        NotificationCenter.default.post(name: NotificationKey.gridClick, object: "GroupCollectionCell")
//        collectionGroup.isHidden = true
//        tableCity.isHidden = false
        
    }
    
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        if indexPath.row == 0 && indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuFilterCell") as! MenuFilterCell
            cell.backgroundColor = .clear
        cell.listView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(listClick)))
        cell.instaView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(instaClick)))
        cell.gridView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(mediaClick)))
            
       cell.selectionStyle = .none
        return cell
           
        }else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: MenuCell.className) as! MenuCell
            let type = AppState.currentUser != nil ? menuTitles[indexPath.section]?[indexPath.row] : menuNotSignedTitles[indexPath.section]?[indexPath.row]
            cell.selectionStyle = .none

            cell.indexpathCell = indexPath
            cell.fill(type: type!, icon: icons[type!]!, text: titles[type!]!, section: indexPath.section)
            return cell
        }
       
    }
}
