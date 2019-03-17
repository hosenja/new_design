//
//  AskShareViewController.swift
//  trid
//
//  Created by Black on 9/1/17.
//  Copyright © 2017 Black. All rights reserved.
//

import UIKit
import PureLayout
import PageControl
import SwiftHTTP
import BmoViewPager

class AskShareViewController: DashboardBaseViewController, BmoViewPagerDelegate, BmoViewPagerDataSource {
  
    @IBOutlet weak var constraintBodyTop: NSLayoutConstraint!
    @IBOutlet weak var body: UIView!
    var tipView : ExploreCollectionView!

    @IBOutlet weak var topConstrat: NSLayoutConstraint!
    /// day attrbute
    @IBOutlet weak var dayNumber: UILabel!
    @IBOutlet weak var dayDate: UILabel!
    
    
    @IBOutlet weak var clickLeft: UIView!
    @IBOutlet weak var clickRight: UIView!
    
    @IBOutlet weak var viewHight: UIView!
    var isFirstTime: Bool = false
    var curentPage: Int = 0
    var rotationAngle: CGFloat!
    var array: [Int] = [1,2,3,4,5]
    var singleGroup: TourGroup?
    
    @IBOutlet weak var bmoPageViewer: BmoViewPager!
    var planDays: [DayInterry] = []
    var pickerData: [String] = ["1","2","3"]
    
//
//
//    func pickerView(_ pickerView: UIPickerView, viewForRow  row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//
//        //let pickerCell = PickerCell()
//       // pickerCell.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
//        let view2 = UIView()
//        view2.frame = CGRect(x: 0 , y: 0 , width: 200, height: 200)
//
////        let label = UILabel()
////        let dateLabel = UILabel()
////        dateLabel.numberOfLines = 0
////        label.numberOfLines = 0
////
////        label.frame = CGRect(x: 0 , y: 0 , width: 60, height: 25)
////
////        dateLabel.frame = CGRect(x: 0 , y: 0 , width: 60, height: 25)
////        //     label.topAnchor.constraint(equalTo: view.topAnchor, constant: 30)
////        dateLabel.topAnchor.constraint(equalTo: label.topAnchor, constant: 5)
////        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5)
////        dateLabel.text = "asdasds"
////        dateLabel.textAlignment = .center
////        dateLabel.font = UIFont(name:"HelveticaNeue-Bold" , size: 12)
////        dateLabel.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )
////
////        label.textAlignment = .center
//
////        label.font = UIFont(name:"HelveticaNeue-Bold" , size: 12)
////        label.text = "Day \(self.planDays[row].day_number!)"
////        if #available(iOS 11.0, *) {
////            label.textColor = UIColor(named: "Primary")
////        } else {
////            // Fallback on earlier versions
////            label.textColor = UIColor(netHex: AppSetting.Color.blue)
////        }
////        label.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )
////
////        view.addSubview(label)
////        view.addSubview(dateLabel)
////
//
//        let label = UILabel()
//        let imageView = UIImageView()
//        label.text = "Constraint finder"
//        label.numberOfLines = 0
//        label.font = UIFont(name:"HelveticaNeue-Bold" , size: 12)
//    label.translatesAutoresizingMaskIntoConstraints = false
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )
//        label.transform =  CGAffineTransform(rotationAngle:  ( 90 * (.pi/180) ) )
//
//        view2.addSubview(label)
//        view2.addSubview(imageView)
//
//        label.topAnchor.constraint(equalTo: (view2.topAnchor), constant: 1).isActive = true
//        label.centerYAnchor.constraint(equalTo: (view2.centerYAnchor)).isActive = true
//
//        imageView.topAnchor.constraint(equalTo: label.bottomAnchor ).isActive = true
//
//        imageView.widthAnchor.constraint(equalToConstant: 20)
//        imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: (view2.centerYAnchor)).isActive = true
//
//        imageView.image = UIImage(named: "scrollleft")
//
//        return view2
//
//    }
//
    @IBOutlet weak var viewIntery: UIView!
    @IBOutlet weak var constaratView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar.setBarHide()
        clickLeft.addTapGestureRecognizer {
            
            if self.curentPage - 1 >= 0
            {
                self.curentPage = self.curentPage - 1
                self.bmoPageViewer.presentedPageIndex  = self.curentPage
                self.dayNumber.text = "Day \(self.planDays[self.curentPage].day_number!)"
               // self.dayDate.text = "\(self.planDays[self.curentPage].date!)"
                self.constaratView.slideInFromLeft(type: "asd")

            }
        }
        clickRight.addTapGestureRecognizer {
            if (self.curentPage + 1) < (self.planDays.count)
            {
                self.curentPage = self.curentPage + 1
                self.bmoPageViewer.presentedPageIndex  = self.curentPage
                self.dayNumber.text = "Day \(self.planDays[self.curentPage].day_number!)"
               // self.dayDate.text = "\(self.planDays[self.curentPage].date!)"
                self.constaratView.slideInFromLeft(type: "")
               // self.overView.slideInFromLeft(type: "asd")

            }
        }
        tabbar.footerInterry.isHidden = false
        print("im here ")
        header.makeHeaderAskShare()
       // rotationAngle = -1 * (90 * (.pi/180))
        bmoPageViewer.delegate = self
        bmoPageViewer.dataSource = self
        getDays()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        topConstrat.constant = header.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    @IBAction func onBackTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func bmoViewPagerDataSourceNumberOfPage(in viewPager: BmoViewPager) -> Int {
        print("Days bmoViewPagerDataSourceNumberOfPage \(planDays.count)")
        return planDays.count
    }
    
    func bmoViewPagerDataSource(_ viewPager: BmoViewPager, viewControllerForPageAt page: Int) -> UIViewController {
        print("im here datasource")
        
        let itemViewController = ItemViewController(nibName: "ItemViewController", bundle: nil)
        
        

        itemViewController.number = self.planDays[page].day_number!
        itemViewController.dayDescription = (self.planDays[page] != nil && self.planDays[page].description != nil)  ? self.planDays[page].description! : "There is no description"
        itemViewController.dayTitle = (self.planDays[page] != nil && self.planDays[page].title != nil)  ? self.planDays[page].title! : ""
        itemViewController.date = (self.planDays[page] != nil && self.planDays[page].date != nil)  ? self.planDays[page].date! : ""
        itemViewController.currentDay = self.planDays[page]
        if self.planDays[page].images?.count != 0 {
            itemViewController.dayImagePath = (self.planDays[page].images?[0].path!)!
            print(itemViewController.dayImagePath)
        }
        return itemViewController
    }
    
    func bmoViewPagerDelegate(_ viewPager: BmoViewPager, pageChanged page: Int) {
        
       // self.daysPicker.selectRow(page, inComponent: 0, animated: true)
        dayNumber.text = "Day \(self.planDays[page].day_number!)"
       // dayDate.text = "Day \(self.planDays[page].date!)"
        if !self.isFirstTime {
            self.isFirstTime = true
        }else {
            if curentPage < page {
                self.constaratView.slideInFromLeft(type: "")
                
            }else {
                self.constaratView.slideInFromLeft(type: "asd")
            }
        }
        
        
        self.curentPage = page
        print("PageChanged \(page)")
    }
    
    func getDays(){
        AppLoading.showLoading()
        let url: String = ApiRouts.ApiV4+"/groups/\((AppState.currentGroup?.id!)!)/days"
         print("Self Url is \(url)")
        HTTP.GET(url) { response in
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                DispatchQueue.main.async {
                    AppLoading.hideLoading()

                }

                return //also notify app of failure as needed
            }
            do {
                let days  = try JSONDecoder().decode(PlanStruct.self, from: response.data)
                self.planDays = days.days!
                DispatchQueue.main.sync {
                    AppLoading.showLoading()
                    if ((self.planDays.count) < 2) {
                        print("I in day > 1 days = \(self.planDays.count)")
                        self.clickLeft.isHidden = true
                        self.clickRight.isHidden = true

                    }else {
                        print("I in day = 1 days = \(self.planDays.count)")
                        self.clickLeft.isHidden = false
                        self.clickRight.isHidden = false                    }
                    self.bmoPageViewer.reloadData()
                    AppLoading.hideLoading()

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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    override func headerBarGoBackImpl() {
        self.tabBarController?.selectedIndex = 0
    }

}
