//
//  AllRatingsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 20/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import SwiftHTTP
class AllRatingsViewController: DashboardBaseViewController {

    @IBOutlet weak var totalRatings: UILabel!

    @IBOutlet weak var topConstrate: NSLayoutConstraint!
    @IBOutlet weak var botomConstrate: NSLayoutConstraint!
    @IBOutlet weak var tableViewRatings: UITableView!

    var ratingsArray: [RatingModel]? = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.makeHeaderRates()
        tabbar.setBarHide()
         header.btnBack.addTarget(self, action:#selector(AllRatingsViewController.back), for: .touchUpInside)
        tableViewRatings.register(UINib(nibName: "RatingsTableViewCell", bundle: nil), forCellReuseIdentifier: "RatingsTableViewCell")
        self.tableViewRatings.delegate = self
        self.tableViewRatings.dataSource = self
        getRatings()
        // Do any additional setup after loading the view.
    }
    @objc func back(){
         self.navigationController?.popViewController(animated: true)
    }
    override func viewDidAppear(_ animated: Bool) {
        topConstrate.constant = header.frame.height
        botomConstrate.constant = tabbar.frame.height
    }
    func getRatings() {
        let url = ApiRouts.Api+"/ratings?model_id=\((ProviderInfo.model_id)!)&model_type=\((ProviderInfo.model_type)!)"
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
                        self.tableViewRatings.reloadData()
                    }
                    self.tableViewRatings.reloadData()
                }
            }
            catch {
                
            }
            print("url rating \(response.description)")
        }
    }

}
extension AllRatingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return (self.ratingsArray?.count)!
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRatings.dequeueReusableCell(withIdentifier: "RatingsTableViewCell", for: indexPath) as! RatingsTableViewCell
        cell.selectionStyle = .none
        cell.updateCell(rate: (self.ratingsArray?[indexPath.row])!)
        return cell
    }
    
    
}
