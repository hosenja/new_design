//
//  SettingsViewController.swift
//  Snapgroup
//
//  Created by snapmac on 26/02/2019.
//  Copyright © 2019 Black. All rights reserved.
//

import UIKit
import McPicker
class SettingsViewController: UIViewController {

    @IBOutlet weak var cuurencyBt: UIButton!
    @IBOutlet weak var currencyPicker: UIPickerView!
    let gradePickerValues = ["Default", "Dollar $", "Euro €", "Pound £"]
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let currency_type = defaults.string(forKey: "currency_type")
        switch currency_type {
        case "$":
           self.cuurencyBt.setTitle("Dollar $", for: .normal)
        case "€":
           self.cuurencyBt.setTitle("Euro €", for: .normal)
        case "£":
           self.cuurencyBt.setTitle("Pound £", for: .normal)
        default:
            self.cuurencyBt.setTitle("Default", for: .normal)
        }
        
        
    }

    func getCurrancyByContry(contryName: String, type: String )  {
            let defaults1 = UserDefaults.standard
            switch type {
            case "Default":
                let countryLocale1 = NSLocale.current
                let countryCode1 = countryLocale1.regionCode
                let country2 = (countryLocale1 as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode1)
                
                let arrayEure: [String] = ["austria", "belgium", "bulgaria", "croatia", "cyprus", "czech republic", "denmark", "estonia", "finland", "france", "germany", "greece", "hungary", "ireland", "italy", "latvia", "lithuania", "luxembourg", "malta", "netherlands", "poland", "portugal", "romania", "slovakia", "slovenia", "spain", "sweden"]
                if arrayEure.contains(String(describing: country2).lowercased()) {
                    let curancy = defaults1.float(forKey: "eure")
                    setToUserDefaults(value: curancy, key: "current_currency")
                    setToUserDefaults(value: "€", key: "currency_type")
                    setToUserDefaults(value: "eur", key: "currentCurrency")
                }else {
                    if String(describing: country2).lowercased() == "united states" {
                        let curancy = defaults1.float(forKey: "dollar")
                        setToUserDefaults(value: "$", key: "currency_type")
                        setToUserDefaults(value: curancy, key: "current_currency")
                        setToUserDefaults(value: "usd", key: "currentCurrency")
                    }
                    else {
                        setToUserDefaults(value: "£", key: "currency_type")
                        setToUserDefaults(value: 1, key: "current_currency")
                        setToUserDefaults(value: "gbp", key: "currentCurrency")
                    }
                }
                
            case "Dollar $":
                let curancy = defaults1.float(forKey: "dollar")
                setToUserDefaults(value: "$", key: "currency_type")
                setToUserDefaults(value: curancy, key: "current_currency")
                setToUserDefaults(value: "usd", key: "currentCurrency")
            case "Euro €":
                let curancy = defaults1.float(forKey: "eure")
                setToUserDefaults(value: curancy, key: "current_currency")
                setToUserDefaults(value: "€", key: "currency_type")
                setToUserDefaults(value: "eur", key: "currentCurrency")
            case "Pound £":
                setToUserDefaults(value: "£", key: "currency_type")
                setToUserDefaults(value: 1, key: "current_currency")
                setToUserDefaults(value: "gbp", key: "currentCurrency")
                
            default:
                setToUserDefaults(value: "£", key: "currency_type")
                setToUserDefaults(value: 1, key: "current_currency")
                setToUserDefaults(value: "gbp", key: "currentCurrency")
            }
        NotificationCenter.default.post(name: NotificationKey.refreshData, object: false)
        
        
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
    @IBAction func currencyTypeClick(_ sender: Any) {
        McPicker.show(data: [gradePickerValues]) {  [weak self] (selections: [Int : String]) -> Void in
            if let name = selections[0] {
                self?.cuurencyBt.setTitle(name, for: .normal)
                self?.getCurrancyByContry(contryName: "", type: name)
               // self?.label.text = name
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.textColor = UIColor.darkGray
            pickerLabel?.font = UIFont(name: "Montserrat", size: 12)
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        pickerLabel?.text = gradePickerValues[row]
        
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.currencyPicker {
            return 1
        }else {
            return 0
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return gradePickerValues[row]
    }
    
    @objc func back(){
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }

    }

    @IBAction func backAction(_ sender: Any) {
        back()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
