//
//  GroupLeaderViewControler.swift
//  Snapgroup
//
//  Created by snapmac on 31/01/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import SwiftHTTP
import TTGSnackbar

class ServicesViewControler: DashboardBaseViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var botomConstarate: NSLayoutConstraint!
    var services: [ServiceCollection]? = []
    @IBOutlet weak var servicesTableView: UITableView!
    @IBOutlet weak var constrateTop: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        getServices()
        tabbar.setBarHide()
        header.makeHeaderServices()
        servicesTableView.delegate = self
        servicesTableView.dataSource = self
       
         header.btnBack.addTarget(self, action:#selector(ServicesViewControler.back), for: .touchUpInside)
        self.servicesTableView.register(UINib(nibName: "ServiceTableViewCell", bundle: nil), forCellReuseIdentifier: "ServiceTableViewCell")
    }
    
    
    @objc func back(){
        
        setTabbarIndex(0)
    }
    func getServices(){
        AppLoading.showLoading()
        let url: String = ApiRouts.Api+"/groups/\((AppState.currentGroup?.id!)!)/services?broadcast=true"
        print("Self Url is \(url)")
        HTTP.GET(url) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                  AppLoading.hideLoading()
                    let snackbar = TTGSnackbar(message: "There are no services.", duration: .middle)
                    snackbar.icon = UIImage(named: "AppIcon")
                    snackbar.show()
                }
                
                return //also notify app of failure as needed
            }
            do {
                
                let days  = try JSONDecoder().decode(ServiceHttp.self, from: response.data)
                self.services = days.services!
                DispatchQueue.main.async {
                    if self.services?.count == 0 {
                        let snackbar = TTGSnackbar(message: "There are no services.", duration: .middle)
                        snackbar.icon = UIImage(named: "AppIcon")
                        snackbar.show()
                    }
                    AppLoading.showSuccess()
               self.servicesTableView.reloadData()
                    
                }
                
            }
            catch let error{
                DispatchQueue.main.async {
                    AppLoading.hideLoading()
                    
                }
                print(error)
            }
            //    print("opt finished: \(response.description)")
            //print("data is: \(response.data)") access the response of the data with response.data
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        constrateTop.constant = header.frame.height
        botomConstarate.constant = tabbar.frame.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.services?.count)!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 260
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceTableViewCell", for: indexPath) as! ServiceTableViewCell
        // parse data
        cell.selectionStyle = .gray
        if self.services?[indexPath.row].image != nil {
            var urlString = ApiRouts.Media + (self.services?[indexPath.row].image_path)!
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
        switch (self.services?[indexPath.row].type)! {
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
        cell.serviceLbl.text = self.services?[indexPath.row].name != nil ? (self.services?[indexPath.row].name)! : ""
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ProviderInfo.model_id = (self.services?[indexPath.row].broadcastable_id)!
        ProviderInfo.model_type = (self.services?[indexPath.row].type) != nil ? (self.services?[indexPath.row].type)! : ""
        ProviderInfo.nameProvider = (self.services?[indexPath.row].name) != nil ? (self.services?[indexPath.row].name)! : ""
        let provider = ProviderViewController()
        self.navigationController?.pushViewController(provider, animated: true)
    }
}
