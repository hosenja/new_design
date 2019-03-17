//
//  SearchCityViewController.swift
//  trid
//
//  Created by Black on 10/24/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GooglePlaces
import GooglePlacesSearchController
import SwiftHTTP
import UIScrollView_InfiniteScroll
import BetterSegmentedControl
import SwiftyPickerPopover
import TTGSnackbar
import Firebase
import NVActivityIndicatorView
import CalendarDateRangePickerViewController

class SearchCityViewController: MainBaseViewController, CalendarDateRangePickerViewControllerDelegate  {
   
    lazy var filter:GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        return filter
    }()
    @IBOutlet weak var showAllFilter: UIButton!
    @IBOutlet weak var loading: NVActivityIndicatorView!
    var clickFromDone: Bool = false
    var filterUrl: String  = ""
    var place_id : String = ""
    var cuurrentText: String = ""
    var isFilterSearch: Bool = false
    var kCellIdentifier = "CityCell"

    @IBOutlet weak var heightKey: NSLayoutConstraint!
    var selctedType: String = "Loactions"
    let arrayTypes: [String] = ["Loactions","Tour Supplier","Group Name"]
    var googlePlace = [GMSAutocompletePrediction]()
    
    @IBOutlet weak var updateFilterBt: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var viewSpinner: UIView!
    var allCities : [GroupItemObject] = []
    var searchUrl: String =  ""
    public var page: Int = 1
    var pageInten: Int = 1
    var isLogged: Bool = false
    var hasLoadMore: Bool = true
    var isLoading: Bool = false

    // outlet
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet var tfSearch: SearchTextField!
    @IBOutlet weak var tableResult: UITableView!
    
    
    @IBOutlet weak var multiplerBottom: NSLayoutConstraint!
    @IBOutlet weak var dropDwonView: UIView!
    @IBOutlet weak var viewSearch: UIView!
    var mySearchTextField = SearchTextField(frame: CGRect(x: 40, y: 0, width: UIScreen.main.bounds.width - 40, height: 44))
   
    // Set the array of strings you want to suggest
   
    @IBOutlet weak var groupsNotFound: UIView!
    
    // filterr
    @IBOutlet weak var newSearchTableView: UITableView!
    
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var multySelctionH: NSLayoutConstraint!
    @IBOutlet weak var multiSelectCollection: UICollectionView!
    /// groups types
    @IBOutlet weak var groupsType: BetterSegmentedControl!
    @IBOutlet weak var scrollFilter: UIScrollView!
    
    @IBOutlet weak var tourDurationTypes: BetterSegmentedControl!
    
    @IBOutlet weak var pricesTypes: BetterSegmentedControl!
    
    var grroupsType: [String] = ["Unique Groups", "Both",  "Reccuring Groups"]
    var tourDurationArray: [String] = ["Any", "Single Day", "2-4 Days","5-8 Days", "9+ Days"]
    var pricesArray: [String] = ["Any", "$","$$","$$$","$$$$"]
    
    var arrData = [String]() // This is your data array
    var arrSelectedIndex = [IndexPath]() // This is selected cell Index array
    var arrSelectedData = [String]() // This is selected cell data array
    var filterRequset: FilterGetSelect?
    var filters: [FilterCatgory]?  = []
    

    var serachArray: [SearchStruct]? = []
   // @IBOutlet weak var droupDwonList: UITableView!
    @IBOutlet weak var heightDroupDwon: NSLayoutConstraint!
    var isAnimating: Bool = false
    var minimumDate : Date?
    var maximumDate : Date?
    var dateString: String?
    @IBOutlet weak var exampView: UIView!
    @IBOutlet weak var viewFILterrrr: UIView!
    @IBOutlet weak var hightFilter: NSLayoutConstraint!

    var priceIndex: Int = 0
    var tourDurationIndex: Int = 0
    var groupIndex: Int = 1
    var groupBothIndex: Int = 1
    @IBOutlet weak var endDateBt: UIButton!
    @IBOutlet weak var startDateBt: UIButton!
    @IBOutlet weak var newfilter: UIView!
    @IBOutlet weak var tableviewConstrate: NSLayoutConstraint!
    @IBOutlet weak var hideFilter: UIView!
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.heightKey.constant = keyboardHeight
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {

        self.heightKey.constant = 0
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        getCatgory(url: "")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        print(dateFormatterGet.string(from: Date()))
        startDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
        endDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
        self.newSearchTableView.delegate = self
        self.newSearchTableView.dataSource = self
        self.updateFilterBt.layer.masksToBounds = true
        self.resetButton.layer.masksToBounds = true
        updateFilterBt.layer.cornerRadius = updateFilterBt.frame.height / 2
         resetButton.layer.cornerRadius = updateFilterBt.frame.height / 2
        resetButton.layer.borderWidth = 1
        resetButton.layer.borderColor = UIColor(netHex: AppSetting.Color.blue).cgColor
       
        hideFilter.addTapGestureRecognizer {
            self.viewFILterrrr.isHidden = true
            self.tableviewConstrate.constant = 0
        }
       showAllFilter.addTarget(self, action:#selector(SearchCityViewController.showAllFilters), for: .touchUpInside)
        
        updateFilterBt.addTarget(self, action:#selector(SearchCityViewController.updateFilterFunc), for: .touchUpInside)
        
        resetButton.addTarget(self, action:#selector(SearchCityViewController.resetFilterFunc), for: .touchUpInside)
        multiSelectCollection.layer.borderWidth = 0.3
        pricesTypes.layer.borderWidth = 0.3
        tourDurationTypes.layer.borderWidth = 0.3
        
        
        groupsType.segments = LabelSegment.segments(withTitles: grroupsType,
                                                    normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                    normalTextColor: UIColor(netHex: AppSetting.Color.blue),
                                                    selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
        groupsType.setIndex(1)
        
        tourDurationTypes.segments = LabelSegment.segments(withTitles: tourDurationArray,
                                                           normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                           normalTextColor: UIColor(netHex: AppSetting.Color.blue),
                                                           selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
        tourDurationTypes.setIndex(0)
        
        
        pricesTypes.segments = LabelSegment.segments(withTitles: pricesArray,
                                                     normalFont: UIFont(name: "HelveticaNeue-Light", size: 12.0)!,
                                                     normalTextColor: UIColor(netHex: AppSetting.Color.blue),
                                                     selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!, selectedTextColor: UIColor.white)
        pricesTypes.setIndex(0)
        
        groupsType.addTarget(self, action: #selector(SearchCityViewController.navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        tourDurationTypes.addTarget(self, action: #selector(SearchCityViewController.tourDurationFunc(_:)), for: .valueChanged)
        pricesTypes.addTarget(self, action: #selector(SearchCityViewController.pricesFunc(_:)), for: .valueChanged)
        arrSelectedIndex.append(IndexPath(row: 0, section: 0))
      //  droupDwonList.isScrollEnabled = false
       // droupDwonList.dropShadow()
        dropDwonView.dropShadow()
        viewSpinner.addTapGestureRecognizer {
            self.animateDroupDwon()
            self.mySearchTextField.tableView?.isHidden = true
            
        }
        
        self.multiSelectCollection.register(UINib(nibName: "MultipleSelectionsCell", bundle: nil), forCellWithReuseIdentifier: "MultipleSelectionsCell")
        self.multiSelectCollection.delegate = self
        
        self.multiSelectCollection.dataSource = self
        self.tableResult.addInfiniteScroll(handler: { (tableView) in
            if  self.hasLoadMore == true && !self.isLoading{
                
                self.isLoading = true
                print("Reach last tableView")
                
                self.getAllGroups(isSearshUrl: self.searchUrl)
                
            }
            self.tableResult.finishInfiniteScroll()
            print("Im here addInfiniteScroll")
        })
    GMSPlacesClient.provideAPIKey("AIzaSyDmGEPxVxdVhfUgFXMQ5L-2nJ3QeRs_XUg")

        // setup ui
       
        
        mySearchTextField.filterStrings(["Red", "Blue", "Yellow"])
        viewSearch.addSubview(mySearchTextField)

        //SearchCell
//        self.droupDwonList.register(UINib(nibName: "SearchCell", bundle: nil), forCellReuseIdentifier: "SearchCell")
         self.newSearchTableView.register(UINib(nibName: "SearchPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchPlaceTableViewCell")
        self.newSearchTableView.register(UINib(nibName: "SearchGroupTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchGroupTableViewCell")
        self.tableResult.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: "CityCell")
        
        self.newSearchTableView.register(UINib(nibName: "LineTableViewCell", bundle: nil), forCellReuseIdentifier: "LineTableViewCell")
        self.tableResult.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        
        self.newSearchTableView.separatorStyle = .none
        
        header.isHidden = true
        
        let clearButton = mySearchTextField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(UIImage(named: "106227-16"), for: .normal)
        clearButton.tintColor = .white
         mySearchTextField.filterStrings([])
        mySearchTextField.delegate = self
        mySearchTextField.textColor = UIColor.white
        mySearchTextField.autocorrectionType = .no
        mySearchTextField.theme = .darkTheme()
        mySearchTextField.returnKeyType = UIReturnKeyType.done
        mySearchTextField.attributedPlaceholder = NSAttributedString(string: "   Search",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(netHex: 0xf1f1f1)])
        mySearchTextField.clearButtonMode = .whileEditing

        //mySearchTextField
        mySearchTextField.itemSelectionHandler = {item, itemPosition in
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            print(dateFormatterGet.string(from: Date()))
            self.startDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
            self.endDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
            self.tourDurationTypes.setIndex(0)
            self.groupsType.setIndex(1)
            self.pricesTypes.setIndex(0)
            self.groupIndex = 1
            self.priceIndex = 0
            self.tourDurationIndex = 0
            
            self.view.endEditing(true)
            self.isFilterSearch = false
            
             self.cuurrentText = ""
            self.clickFromDone = false
            self.place_id = String(describing: (item[itemPosition].place_id!))
            self.hasLoadMore = true
            self.page = 1
            self.allCities = []
            self.tableResult.reloadData()
            self.mySearchTextField.text = item[itemPosition].title
            self.tableResult.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: CityCell.className)
            AppLoading.showLoading()
            self.getAllGroups(isSearshUrl: self.searchUrl)
            print("\(item[itemPosition].title)  \(item[itemPosition].place_id!)")
        }
       
    }

    //SearchObj
    fileprivate func animateDroupDwon() {
        if !self.isAnimating {
            self.isAnimating = true
            self.heightDroupDwon.constant = 100
            
            UIView.animate(withDuration: 0.2, animations: {
                self.dropDwonView.isHidden = false
            })
        }else {
            self.isAnimating = false
            self.heightDroupDwon.constant = 0
            
            UIView.animate(withDuration: 0.2, animations: {
                self.dropDwonView.isHidden = true
            })
            
        }
    }
    @objc func showAllFilters(){
        if showAllFilter.titleLabel?.text == "Show more options  "{
            self.scrollFilter.isScrollEnabled = true
            hightFilter.constant = exampView.frame.height
            self.scrollFilter.isScrollEnabled = true
            self.showAllFilter.setTitle("Show less options  ", for: .normal)
        }else {
            self.showAllFilter.setTitle("Show more options  ", for: .normal)
            self.scrollFilter.isScrollEnabled = false
            hightFilter.constant = 150
        }
        self.filterView.layoutIfNeeded()
    }
    @IBAction func dromDateClick(_ sender: Any) {
        
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.selectedStartDate = Date()
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
        
    }
    @IBAction func endDateClick(_ sender: Any) {
        
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.selectedStartDate = Date()
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    func didTapCancel() {
        dismiss(animated: false, completion: nil)
    }
    
    func didTapDoneWithDateRange(startDate: Date!, endDate: Date!) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        
        print(dateFormatterGet.string(from: startDate))
        startDateBt.setTitle("\(dateFormatterGet.string(from: startDate))", for: .normal)
        endDateBt.setTitle("\(dateFormatterGet.string(from: endDate))", for: .normal)
        
        isFilterSearch = true
        clickFromDone = false
        self.hasLoadMore = true
        self.page = 1
        self.allCities = []
        self.tableResult.reloadData()
        self.filterUrl = ""
        setFilterUrl(start_date: (dateFormatterGet.string(from: startDate)), end_date: dateFormatterGet.string(from: endDate))
        dismiss(animated: false, completion: nil)
        
    }
     @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
        self.groupIndex = Int(sender.index)
    }
    @objc func tourDurationFunc(_ sender: BetterSegmentedControl) {
    self.tourDurationIndex = Int(sender.index)
    }
    @objc func pricesFunc(_ sender: BetterSegmentedControl) {
        self.priceIndex = Int(sender.index)
    }
    fileprivate func setFilterUrl(start_date: String, end_date: String) {
        
        switch self.grroupsType[groupIndex] {
        case "Unique Groups":
            self.filterUrl = self.filterUrl + "&rotation=one_time"
        case "Reccuring Groups":
            self.filterUrl = self.filterUrl + "&rotation=reccuring"
        default:
            print("")
        }
        print("Start date \((startDateBt.titleLabel?.text)!)   end date \((endDateBt.titleLabel?.text)!)")
        if start_date != end_date {
            self.filterUrl = self.filterUrl + "&start_date=\((start_date))"
            self.filterUrl = self.filterUrl + "&end_date=\((end_date))"
        }
        if tourDurationIndex != 0 {

            
            switch self.tourDurationArray[tourDurationIndex] {
            case "Single Day":
                self.filterUrl = self.filterUrl + "&min_days=1&max_days=1"
            case "2-4 Days":
                self.filterUrl = self.filterUrl + "&min_days=2&max_days=4"
            case "5-8 Days":
                self.filterUrl = self.filterUrl + "&min_days=5&max_days=8"
            case "9+ Days":
                 self.filterUrl = self.filterUrl + "&min_days=9"
            default:
                print("")
            }
         
        }
        self.scrollFilter.setContentOffset(.zero, animated: true)
        getAllGroups(isSearshUrl: "")
    }
    
    fileprivate func hideFilterFunc() {
        if self.hightFilter.constant != 150 {
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                
                self.filterView.slideInFromLeft(type: "top")
            }) { (success) in
                
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
                    self.showAllFilter.setTitle("Show more options  ", for: .normal)
                    
                    self.hightFilter.constant = 150
                }, completion: nil)
            }
        }
        
    }
    
    
    
    
    
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        self.mySearchTextField.isHidden = true
    }
    @objc func updateFilterFunc() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        isFilterSearch = true
        clickFromDone = false
        self.hasLoadMore = true
        self.page = 1
        self.allCities = []
        self.tableResult.reloadData()
        self.filterUrl = ""
        setFilterUrl(start_date: "\(String(describing: (startDateBt.titleLabel?.text)!))", end_date: "\(String(describing: (endDateBt.titleLabel?.text)!))")
       
        hideFilterFunc()
        self.scrollFilter.isScrollEnabled = false
        //self.mySearchTextField.isHidden = true
    }
    @objc func resetFilterFunc() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        //self.mySearchTextField.isHidden = true
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        print(dateFormatterGet.string(from: Date()))
        startDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
        endDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
        tourDurationTypes.setIndex(0)
        groupsType.setIndex(1)
        pricesTypes.setIndex(0)
        self.groupIndex = 1
        self.priceIndex = 0
        self.tourDurationIndex = 0
        setFilterUrl(start_date: "\(String(describing: (startDateBt.titleLabel?.text)!))", end_date: "\(String(describing: (endDateBt.titleLabel?.text)!))")
        
        hideFilterFunc()
    }
    
    
    @objc func handleUpdatedCities(notification: NSNotification) {
        tableResult.reloadData()
        let obj = notification.object as? FCity
        if obj != nil {
            self.goto()
        }
    }
    func getCatgory(url: String){
        // TODO
        let urlCatg: String = ApiRouts.ApiV3 + "/groups/filters"
        print("Catgory url is \(urlCatg)")
        
        HTTP.GET(urlCatg, parameters: []) { response in
            
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
                return
            }
            do{
                self.filterRequset  = try JSONDecoder().decode(FilterGetSelect.self, from: response.data)
                self.filters = self.filterRequset?.categories
                
                DispatchQueue.main.sync {
                    
                    
                    self.arrData.append("Any")
                    for i in (0..<(self.filters?.count)!) {
                        self.arrData.append((self.filters?[i].title)! )
                        self.filters?[i].isChecked = false
                        self.filters?[i].isChecked = false
                        self.filters?[i].index = i
                        self.filters?[i].index = i
                    }
                    print("Array append \(self.arrData.count) \(self.multiSelectCollection.contentSize.height)")
                    self.multiSelectCollection.reloadData()
                    
                   // self.multySelctionH.constant = self.multiSelectCollection.contentSize.height
                    
                }
                
            }
            catch let error {
                
            }
            
        }
    }
    
    public func getAllGroups(isSearshUrl: String) {

        self.pageInten = self.page
        self.groupsNotFound.isHidden = true
        self.isLoading = true
        self.searchType(self.cuurrentText)
        
        print("Url Search is \(isSearshUrl)")

    }
  

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

    
    
    @IBAction func actionBack(_ sender: AnyObject) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}

extension SearchCityViewController : UITextFieldDelegate {
    func searchFunc(name: String){
        let seachText = name.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url: String = ApiRouts.ApiGroupsV6 + "/groups/search?q=\(seachText)"
        print("Im in Search func \(url)")
        HTTP.GET(url){response in
            
            if let err = response.error {
                print("error: \(err.localizedDescription)")
            }else {
                do{
                    let  resp = try JSONDecoder().decode(SearchObj.self, from: response.data)
                    self.serachArray = []
                    DispatchQueue.main.sync {
                        var c: Int = 0
                        for search in resp.autocomplete! {
                             c = c + 1
                            var newSearch = search
                            newSearch.type = "autocomplete"
                            if c > 3 {
                                break
                            }else {
                            self.serachArray?.append(newSearch)
                            }
                           
                        }
                        let newSearch1 = SearchStruct(description: "asd",place_id: "asd",name: "asd",title: "asd",image: "asd",type: "Line",group_id: 1)
                        self.serachArray?.append(newSearch1)
                        c = 0
                        for search in resp.groups! {
                            c = c + 1
                            let searchArra:SearchStruct = SearchStruct(description: "asd",place_id: "asd",name: search.title,title: search.title,image: search.image,type: "groups",group_id: (search.id!))
                            if c > 3 {
                                let newSearch = SearchStruct(description: "asd",place_id: "asd",name: "asd",title: "result",image: "asd",type: "",group_id: (search.id!))
                                self.serachArray?.append(newSearch)
                                break
                            }else {
                         self.serachArray?.append(searchArra)
                            }
                            
                        }
//
//                         c = 0
//                        for search in resp.companies! {
//                            c = c + 1
//                            let searchArra:SearchStruct = SearchStruct(description: "asd",place_id: "asd",name: search.name,title: search.name,image: search.image,type: "companies",group_id: (search.id!))
//
//                            if c > 3 {
//                                let newSearch = SearchStruct(description: "asd",place_id: "asd",name: "asd",title: "companies",image: "asd",type: "",group_id: 1)
//                                self.serachArray?.append(newSearch)
//                                break
//                            }else {
//                                self.serachArray?.append(searchArra)
//                            }
//
//                        }
                        self.loading.stopAnimating()
                        
                    self.newSearchTableView.reloadData()
                    }
                }catch {
                    
                }
            }
            
        }
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.loading.startAnimating()
        self.tableResult.isHidden = true
        self.newSearchTableView.isHidden = false
        let searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if searchString == "" {
            
            DispatchQueue.main.async {
                
                self.serachArray = []
                self.newSearchTableView.reloadData()
                self.loading.stopAnimating()
            }
        }else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            print("Im in text fild search")
            self.searchFunc(name: searchString)
            
        })
        }
        
        
        
//        if !self.dropDwonView.isHidden {
//            self.dropDwonView.isHidden = true
//            self.heightDroupDwon.constant = 0
//        }
//    //  print("Im in shouldChangeCharactersIn \(self.selctedType)")
//        if self.selctedType == "Loactions" {
//
//        let searchString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//            GMSPlacesClient.shared().autocompleteQuery(searchString, bounds: nil, filter: filter, callback: {(results, error) -> Void in
//            if let error = error {
//                print("Autocomplete error \(error)")
//                return
//            }
//
//            if let results = results {
//                self.googlePlace = results
//                  self.mySearchTextField.filterPlaces(places: results)
//            }
//        })
//
//        }else {
//            self.mySearchTextField.filterPlaces(places: [])
//            self.mySearchTextField.tableView?.isHidden = true
//        }
        
        return true
    }
    
    
    public func searchType(_ textField: String) {
        if clickFromDone {
        //print("Im heree in textFieldShouldReturn")
        switch self.selctedType {
        case "Loactions":
            self.searchUrl = ApiRouts.ApiGroups + "/groups?page=\(self.pageInten)&sort=created_at&order=des&destination=\(String(describing: (textField)))"
        // dont do anthing
        case "Tour Supplier":
            self.searchUrl = ApiRouts.ApiGroups + "/groups?page=\(self.pageInten)&sort=created_at&order=des&tour_supplier=\((textField))"
        default:
            self.searchUrl = ApiRouts.ApiGroups + "/groups?page=\(self.pageInten)&sort=created_at&order=des&search=\((textField))"
        }
        }else {
            if place_id == "" {
            self.searchUrl = ApiRouts.ApiGroups + "/groups?page=\(self.pageInten)&sort=created_at&order=des&search=\((textField))"

            }else {
                self.searchUrl = ApiRouts.ApiGroups + "/groups?page=\(self.pageInten)&sort=created_at&order=des&place_id=\(self.place_id)"

            }
            
    
        }
        if isFilterSearch {
            self.searchUrl = self.searchUrl +  self.filterUrl
        }
        print("Self page = \(self.page) \(self.searchUrl)")

        self.groupsNotFound.isHidden = true
        HTTP.GET(self.searchUrl) { response in
            if let error = response.error {
                DispatchQueue.main.async {
                    AppLoading.hideLoading()
                    self.groupsNotFound.isHidden = false
                }
                print("Error is \(error)")
              
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
                        self.tableResult.reloadData()
                    }
                    AppLoading.hideLoading()
                    
                    self.showAllFilter.isHidden = false
                    self.filterView.isHidden = false
                    self.scrollFilter.isHidden = false
                    
                    self.mySearchTextField.tableView?.isHidden = true
                    self.mySearchTextField.filterPlaces(places: [])
                   
                    
                    self.isLoading = false
                    if (groups2.total)! == 0
                    {
                        DispatchQueue.main.async {
                            self.groupsNotFound.isHidden = false
                            self.hasLoadMore = false
                        }
                        
                    }else {
                        
                        AppLoading.showSuccess()
                        
                    }
                    if self.page > (groups2.last_page!)
                    {
                        self.hasLoadMore = false
                        return
                    }
                    
                }
                DispatchQueue.main.async {
                    AppLoading.hideLoading()
                }
                
            }
            catch let error {
                 DispatchQueue.main.async {
                AppLoading.hideLoading()
                }
            }
            
        }
        
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

//
//        self.isFilterSearch = false
//         self.clickFromDone = true
//         self.place_id = ""
//        self.page = 1
//        self.hasLoadMore = true
//        self.showAllFilter.setTitle("Show more options  ", for: .normal)
//        self.hightFilter.constant = 150
//        self.scrollFilter.isScrollEnabled = false
//        self.allCities = []
//        self.tableResult.reloadData()
//        self.cuurrentText = textField.text!
//        self.cuurrentText = self.cuurrentText.replacingOccurrences(of: " ", with: "")
//        view.endEditing(true)
//        AppLoading.showLoading()
//        getAllGroups(isSearshUrl: self.searchUrl)
//        mySearchTextField.filterStrings([])
//

        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
       print("Im hereee textFieldShouldClear")
        DispatchQueue.main.async {
            self.serachArray = []
            self.newSearchTableView.reloadData()
            self.loading.stopAnimating()
        }
        
        return true
    }
    /*
 
     switch indexPath.row {
     case 0:
     //   cell.imageCell.image = UIImage(named: "k")
     urlGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des&place_id=\(String(describing: (self.googlePlace[indexPath.row].placeID)!))"
     case 1:
     //  cell.imageCell.image = UIImage(named: "k")
     urlGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des&tour_supplier=\(String(describing: (self.tfSearch.text)!))"
     default:
     // cell.imageCell.image = UIImage(named: "k")
     urlGroup = ApiRouts.ApiGroups + "/groups?page=\(self.page)&sort=created_at&order=des&search=\(String(describing: (self.tfSearch.text)!))"
     }
     
     
     */
}



extension SearchCityViewController : UITableViewDataSource,UITableViewDelegate {
    
    
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
                    let dashboard = DashboardViewController()
                    self.navigationController?.pushViewController(dashboard, animated: true)
                    
                }
            }
            catch let error{
                AppLoading.hideLoading()
                print("getGroup : \(error)")
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.tableResult {
            
            getGroup(group_id:(self.allCities[indexPath.row].id)!)
        }else {
          
            if indexPath.row > -1 && indexPath.row < (self.serachArray?.count)! {
            switch (self.serachArray?[indexPath.row].type)! {
            case "groups":
                getGroup(group_id:(self.serachArray?[indexPath.row].group_id)!)
            case "autocomplete":
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd"
                print(dateFormatterGet.string(from: Date()))
                self.startDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
                self.endDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
                self.tourDurationTypes.setIndex(0)
                self.groupsType.setIndex(1)
                self.pricesTypes.setIndex(0)
                self.groupIndex = 1
                self.priceIndex = 0
                self.tourDurationIndex = 0
                
                self.view.endEditing(true)
                self.isFilterSearch = false
                
                self.cuurrentText = ""
                self.clickFromDone = false
                self.place_id = String(describing: (self.serachArray?[indexPath.row].place_id)!)
                self.hasLoadMore = true
                self.page = 1
                self.allCities = []
                self.tableResult.reloadData()
                self.mySearchTextField.text = (self.serachArray?[indexPath.row].description)!
                self.tableResult.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: CityCell.className)
                AppLoading.showLoading()
                self.getAllGroups(isSearshUrl: self.searchUrl)
                self.tableResult.isHidden = false
                self.newSearchTableView.isHidden = true
            default:
                print("")
                if (self.serachArray?[indexPath.row].title)! == "result" {
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd"
                    self.startDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
                    self.endDateBt.setTitle(dateFormatterGet.string(from: Date()), for: .normal)
                    self.tourDurationTypes.setIndex(0)
                    self.groupsType.setIndex(1)
                    self.pricesTypes.setIndex(0)
                    self.groupIndex = 1
                    self.priceIndex = 0
                    self.tourDurationIndex = 0
                    self.view.endEditing(true)
                    self.isFilterSearch = false
                    self.cuurrentText = (self.mySearchTextField.text)!
                    self.clickFromDone = false
                    self.place_id = ""
                    self.hasLoadMore = true
                    self.page = 1
                    self.allCities = []
                    self.tableResult.reloadData()
                    self.tableResult.register(UINib(nibName: "CityCell", bundle: nil), forCellReuseIdentifier: CityCell.className)
                    AppLoading.showLoading()
                    self.getAllGroups(isSearshUrl: self.searchUrl)
                    self.tableResult.isHidden = false
                    self.newSearchTableView.isHidden = true
                }
            }
            }
        }
        
        
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if tableView == self.tableResult {
            return allCities.count

         }else {
              return (self.serachArray?.count)!

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableResult {
            return CityCell.cellHeight()
        }else {
            if indexPath.row > -1 && indexPath.row < (self.serachArray?.count)! {
            if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "groups") {
                return SearchGroupTableViewCell.cellHeight()
            }else {
                if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "autocomplete") {
                return SearchPlaceTableViewCell.cellHeight()
                }else {
                    if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "companies") {
                        return SearchGroupTableViewCell.cellHeight()
                    }else {
                    //
                    return 25
                    }
                }
            }
            }else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView ==  self.tableResult{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath) as! CityCell
            // parse data
            cell.selectionStyle = .none
            let city = allCities[indexPath.row]
            cell.makeCity(city)
            return cell
        }else {
            
            
            if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "groups") {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SearchGroupTableViewCell", for: indexPath) as! SearchGroupTableViewCell
                if indexPath.row > -1 && indexPath.row < (self.serachArray?.count)! {
                    cell.makeCity((self.serachArray?[indexPath.row])!)
                }
                 cell.selectionStyle = .none
                 return cell
            }else {
                if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "autocomplete") {
                 let cell = tableView.dequeueReusableCell(withIdentifier: "SearchPlaceTableViewCell", for: indexPath) as! SearchPlaceTableViewCell
                if indexPath.row > -1 && indexPath.row < (self.serachArray?.count)! {
                    cell.makeCity((self.serachArray?[indexPath.row])!)
                }
                     cell.selectionStyle = .none
                return cell
                }else {
                     if (self.serachArray?[indexPath.row].type != nil && self.serachArray?[indexPath.row].type! == "companies") {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchGroupTableViewCell", for: indexPath) as! SearchGroupTableViewCell
                        if indexPath.row > -1 && indexPath.row < (self.serachArray?.count)! {
                            cell.makeCity((self.serachArray?[indexPath.row])!)
                        }
                         cell.selectionStyle = .none
                        return cell
                    
                     }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "LineTableViewCell", for: indexPath) as! LineTableViewCell
                    if self.serachArray?[indexPath.row].type == "Line" {
                        cell.moreResult.isHidden = true
                         cell.line.isHidden = false
                    }else {
                        cell.moreResult.isHidden = false
                        cell.line.isHidden = true
                    }
                         cell.selectionStyle = .none
                    return cell
                    }
                }
               
            }
            
          
        }
    }
    
}
extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 0.5
      //  layer.cornerRadius = 15
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
extension SearchCityViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         print("CATGORY : \(self.arrData.count)")
        return (self.arrData.count)
       
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
            return 2
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
            
            let collectionViewSize = UIScreen.main.bounds.width - 27
            return CGSize(width: collectionViewSize/3, height: 30)
            //return CGSize(width: 100, height: 30)
            
        
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = multiSelectCollection.dequeueReusableCell(withReuseIdentifier: "MultipleSelectionsCell", for: indexPath) as! MultipleSelectionsCell
        
        cell.viewB.layer.cornerRadius = 0
        
        // border
        cell.viewB.layer.borderWidth = 1.0
        cell.viewB.layer.borderColor = UIColor.black.cgColor
        cell.label.text = (self.arrData[indexPath.row])
        // shadow
        cell.viewB.layer.shadowColor = UIColor.gray.cgColor
        cell.viewB.layer.shadowOffset = CGSize(width: 3, height: 3)
        // cell.viewB.layer.shadowOpacity = 0.7
        cell.viewB.layer.shadowRadius = 4.0
        if arrSelectedIndex.contains(indexPath) { // You need to check wether selected index array contain current index if yes then change the color
            cell.viewB.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
            cell.label.textColor = UIColor.white
            cell.viewB.layer.borderColor = UIColor.clear.cgColor
        }
        else {
            cell.viewB.layer.borderColor = UIColor.clear.cgColor
            cell.label.textColor = UIColor.black
            cell.viewB.backgroundColor = UIColor.clear
        }
//
//        cell.layoutSubviews()
        return cell
    }
    
    
}
public extension NSLayoutConstraint {
    
    func changeMultiplier(multiplier: CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        newConstraint.priority = priority
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        
        return newConstraint
}

}
extension Date {
    /// Returns a Date with the specified days added to the one it is called with
    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var targetDay: Date
        targetDay = Calendar.current.date(byAdding: .year, value: years, to: self)!
        targetDay = Calendar.current.date(byAdding: .month, value: months, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .day, value: days, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .hour, value: hours, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .minute, value: minutes, to: targetDay)!
        targetDay = Calendar.current.date(byAdding: .second, value: seconds, to: targetDay)!
        return targetDay
    }
    
    /// Returns a Date with the specified days subtracted from the one it is called with
    func subtract(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        let inverseYears = -1 * years
        let inverseMonths = -1 * months
        let inverseDays = -1 * days
        let inverseHours = -1 * hours
        let inverseMinutes = -1 * minutes
        let inverseSeconds = -1 * seconds
        return add(years: inverseYears, months: inverseMonths, days: inverseDays, hours: inverseHours, minutes: inverseMinutes, seconds: inverseSeconds)
    }
    
}
