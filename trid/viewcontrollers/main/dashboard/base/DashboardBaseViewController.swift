//
//  DashboardBaseViewController.swift
//  trid
//
//  Created by Black on 9/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Foundation
import PureLayout

class DashboardBaseViewController: MainBaseViewController {

    var tabbar: TridTabbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add footer
        tabbar = TridTabbar.createTabbar()
        self.view.addSubview(tabbar)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.leading)
        tabbar.autoPinEdge(toSuperviewEdge: ALEdge.trailing)
        tabbar.autoSetDimension(ALDimension.height, toSize: AppSetting.App.tabbarHeight)
        tabbar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabbar.checkSelectedTab()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func showPopupAddTip() {
        // Logged in -> Show popup add
        var title = Localized.NewTip
        if AppState.shared.currentCity != nil {
            title = Localized.AskAQuestionOrShareYourTips //Localized.TipFor + " " + AppState.shared.currentCity!.getName()
        }
        let popup = PopupAddTip.popupWith(title: title)
        popup.actionAdd = {text in
            popup.hide()
            if text == nil {
                self.view.makeToast(Localized.ContentIsEmpty)
            }
            else{
                // !!!
                // Add new tip
                let tip = FPlace.tipWithContent(text!)
                if tip != nil {
                    tip?.saveInBackground({e in
                        if e != nil {
                            self.view.makeToast(e!.localizedDescription)
                        }
                        else{
                            self.view.makeToast(Localized.Success)
                        }
                    })
                }
                else{
                    self.view.makeToast(Localized.SomethingWrong)
                }
            }
        }
        popup.show()
    }
}

extension DashboardBaseViewController : TridTabbarProtocol {
    func tabbarShowAskAndShare() {
        setTabbarIndex(2)
       // setTabbarIndex(2)
        print("im hereoshhh")
    }
    

    // MARK: - tabbar delegate
    func tabbarAdd() {
        setCheckTrue(type: "book_now", groupID: (AppState.currentGroup?.id)!)
        let bookingController = BookingViewController()
        self.navigationController?.pushViewController(bookingController, animated: true)
        print("Im here in dashbord")
        
    }
    
    func tabbarShowAllCities() {
        _ = self.tabBarController?.navigationController?.popViewController(animated: true)
    }
    
    func tabbarShowGuide() {
        setTabbarIndex(1)
    }
    
    func tabbarShowFavorite() {
        MeasurementHelper.openSavedTab()
        setTabbarIndex(3)
    }
    
    func setTabbarIndex(_ index: Int){
        if self.tabBarController?.selectedIndex != index {
            self.tabBarController?.selectedIndex = index
        }
        else{
            // already stay at index -> pop to root
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
}
