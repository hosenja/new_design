
import UIKit
import FirebaseAuth

class SplashViewController: UIViewController {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    // variables
    var listenerHandle: AuthStateDidChangeListenerHandle?
    var checkedLogin = false
    var moved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create animation "trid"
        //labelName.text = Localized.AppFullName
        //labelDescription.text = Localized.AppSlogan1
       
        // Check service
        //self.autologin()
    }
    override func viewDidAppear(_ animated: Bool) {

        let defaults = UserDefaults.standard
        let showSplash = defaults.bool(forKey: "showSplash")
        print("showSplash \(showSplash)")
        if showSplash != nil && showSplash
        {
            gotoMain()
        }
        else{
            self.setToUserDefaults(value: true, key: "showSplash")
            self.gotoLogin()
        }
      
        
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
    func autologin() {
//        // auto login
//        let info = AppState.getSignInInfo()
//        print("Info is \(info)")
//        var credential : AuthCredential?
//        if info != nil {
//            //credential = info?.credential()
//        }
//        // có thể đã login hoặc login nhưng bị hết hạn session
//        listenerHandle = Auth.auth().addStateDidChangeListener({auth, user in
//            if self.checkedLogin {
//                return
//            }
//            self.checkedLogin = true
//            if user != nil {
//                user!.reload(completion: {error in
//                    if error != nil {
//                        // something wrong, maybe user has been deleted
//                        self.gotoLogin()
//                    }
//                    else{
//                        if credential != nil {
//                            // Reauth by credential. because maybe user was disabled
//                            user?.reauthenticate(with: credential!) { error in
//                                if error != nil {
//                                    // remove current user
//                                    AppState.currentUser = nil
//                                    // An error happened.
//                                    self.gotoLogin()
//                                    // clear credential
//                                    AppState.setSignInInfo(nil)
//                                } else {
//                                   // self.continueWithUser(user!)
//                                }
//                            }
//                        }
//                        else{
//                            //self.continueWithUser(user!)
//                        }
//                    }
//                })
//            }
//            else{
//                self.gotoLogin()
//            }
//        })
    }
    
//    func continueWithUser(_ user: User) {
//        let fuser = FUser.userWith(firUser: user, loginProvider: user.providerID)
//        fuser.fetchInBackground(finish: {e in
//            if e != nil || fuser.snapshot == nil{
//                self.gotoLogin()
//            }
//            else {
//                if fuser.getInactive() {
//                    self.gotoLogin()
//                }
//                else{
//                    // #set-current-user
//                    AppState.currentUser = fuser
//                    // User re-authenticated
//                    self.gotoMain()
//                }
//            }
//        })
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if listenerHandle != nil {
            Auth.auth().removeStateDidChangeListener(listenerHandle!)
        }
        moved = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gotoLogin(){
        
        let controller = LoginViewController(nibName: "LoginViewController", bundle: nil)
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
//    public func UIColorFromRGB(rgbValue: UInt) -> UIColor {
//        return UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: CGFloat(1.0)
//        )
//    }
    
    func gotoMain(){
      
        let controller = MainViewController()
        _ = self.navigationController?.pushViewController(controller, animated: false)
    }
    
}

