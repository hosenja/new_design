//
//  TermsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 03/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit

class TermsViewController: DashboardBaseViewController {

    @IBOutlet weak var termsLbl: UILabel!
    @IBOutlet weak var topConstrate: NSLayoutConstraint!
    @IBOutlet weak var bottomConstrate: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

    termsLbl.setHtmlText((AppState.currentGroup?.group_conditions!)!)
        header.makeHeaderTerms()
        header.btnBack.addTarget(self, action:#selector(ServicesViewControler.back), for: .touchUpInside)
        tabbar.setBarHide()
        
    }
    
    @objc func back(){
        
        setTabbarIndex(0)
    }

    override func viewDidAppear(_ animated: Bool) {
        topConstrate.constant = header.frame.height + 20
        bottomConstrate.constant = tabbar.frame.height + 20
    }
    
}
