//
//  FCity.swift
//  trid
//
//  Created by Black on 12/27/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import SwiftHTTP
import Firebase

enum FCityState : Int {
    case Free = 0
    case Paid = 1
    case Purchased = 2
    case Offline = 3
}
struct GroupItemObject: Codable {
    var id: Int?
    var start_date: String?
    var end_date: String?
    var registration_end_date: String?
    var is_company: Int?
    var open: Bool?
    var rotation: String?
    var start_time: String?
    var end_time: String?
    var frequency: String?
    var special_price: Float?
    var hours_of_operation: String?
    var group_leader_id: Int?
    var days: Int?
    var group_leader: GroupLeaderStruct?
    var translations: [GroupTranslation]?
    var images: [ImageStruct]?
    var image: String?
    var role: String?
    var price: String?
    var prices: [PriceObject]?
}
struct TourGroup: Codable {
    var id: Int?
    var title: String?
    var image: String?
    var phone: String?
    var days_count: Int?
    var has_services: Bool?
    var interested: Int?
    var description: String?
    var open: Bool?
    var role: String?
    var price: String?
    var registration_end_date: String?
    var start_date: String?
    var target_members: Int?
    var max_members: Int?
    var end_date: String?
    var is_company: Int?
    var group_leader: GroupLeaderStruct?
    var rotation: String?
    var hours_of_operation: String?
    var frequency: String?
    var start_time: String?
    var end_time: String?
    var group_leader_id: Int?
    var special_price: Float?
    var special_price_tagline: String?
    var translations: [GroupTranslation]?
    var group_tools: GroupTools?
    var group_settings: GroupSettings?
    var chat: ChatObject?
    var group_conditions: String?
    var categories: [Categories]
    var prices: [PriceObject]?
    var images: [GroupImage]?

    
}
func setCheckTrue(type:String,groupID: Int) {
    var params: [String : Any] = ["" : ""]
    if groupID == -1 {
        params = [type : true]
    }else {
        params = [type : true, "group_id" : groupID]
    }
    print("Type : \(type) , group _ id : \(groupID)")
    let strMethod: String = ApiRouts.Api + "/downloads/\(UIDevice.current.identifierForVendor!.uuidString)"
    HTTP.PUT(strMethod, parameters: params) { response in
        if response.error != nil {
            print("error \(String(describing: response.error?.localizedDescription))")
            return
        }
        print("SETchek true \(response.description)")
        
    }
    
}
func setCheckGroupTrue(member_id:Int,groupID: Int) {
    var params: [String : Any] = ["" : ""]
    params = ["device_id" : "\(UIDevice.current.identifierForVendor!.uuidString)","group_id" : groupID]
    let strMethod: String = ApiRouts.Api + "/clicks"
    HTTP.POST(strMethod, parameters: params) { response in
        if response.error != nil {
            print("error \(String(describing: response.error?.localizedDescription))")
            return
        }
        print("SETchek true \(response.description)")
        
    }
    
}
struct Currancy : Codable{
    var rates: CurrancyObj?
}
struct CurrancyObj : Codable{
    var USD: Float?
    var GBP: Float?
    var EUR: Float?
}
func getCurrancy() {
    let defaults = UserDefaults.standard
    let currentCurrency = defaults.string(forKey: "currentCurrency")
    print("currentCurrency \(currentCurrency)")
    if currentCurrency != nil && currentCurrency != "" {
        
    }else {
    let strMethod: String = "https://api.exchangeratesapi.io/latest?base=GBP"
    HTTP.GET(strMethod, parameters: []) { response in
        if response.error != nil {
            print("error \(String(describing: response.error?.localizedDescription))")
            return
        }
        do {
            let currncy_rate = try JSONDecoder().decode(Currancy.self, from: response.data)
            print("Im in currncy_rate \(currncy_rate)  \(currncy_rate.rates)")
            
            setToUserDefaults(value: (currncy_rate.rates?.EUR)!, key: "eure")
            setToUserDefaults(value: (currncy_rate.rates?.USD)!, key: "dollar")
            
            let countryLocale1 = NSLocale.current
            let countryCode1 = countryLocale1.regionCode
            let country2 = (countryLocale1 as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: countryCode1)
            print("countryCode = \(String(describing: countryCode1)), country2 = \(String(describing: country2))")
            getCurrancyByContry(contryName: country2!, type: "")
        }catch{
            
        }
    }
    }
    
}
func setToUserDefaults(value: Any?, key: String){
    if value != nil {
        print("before insert")
        let defaults = UserDefaults.standard
        defaults.set(value!, forKey: key)
        print("After insert")
    }
    else{
        let defaults = UserDefaults.standard
        defaults.set("no value", forKey: key)
    }
    
    
}
func getCurrancyByContry(contryName: String, type: String )  {
    // usd
    //eur
    //gbp
    if contryName != "" {
        let defaults1 = UserDefaults.standard
        let arrayEure: [String] = ["austria", "belgium", "bulgaria", "croatia", "cyprus", "czech republic", "denmark", "estonia", "finland", "france", "germany", "greece", "hungary", "ireland", "italy", "latvia", "lithuania", "luxembourg", "malta", "netherlands", "poland", "portugal", "romania", "slovakia", "slovenia", "spain", "sweden"]
        if arrayEure.contains(contryName.lowercased()) {
            let curancy = defaults1.float(forKey: "eure")
            setToUserDefaults(value: curancy, key: "current_currency")
            setToUserDefaults(value: "eur", key: "currentCurrency")
            setToUserDefaults(value: "€", key: "currency_type")
        }else {
            if contryName.lowercased() == "united states" {
                
                let curancy = defaults1.float(forKey: "dollar")
                setToUserDefaults(value: "$", key: "currency_type")
                setToUserDefaults(value: curancy, key: "current_currency")
                setToUserDefaults(value: "usd", key: "currentCurrency")
            }
            else {
                setToUserDefaults(value: "gbp", key: "currentCurrency")
                setToUserDefaults(value: "£", key: "currency_type")
                setToUserDefaults(value: 1, key: "current_currency")
            }
        }
    }else {
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
                setToUserDefaults(value: "eur", key: "currentCurrency")
                setToUserDefaults(value: "€", key: "currency_type")
            }else {
                if String(describing: country2).lowercased() == "united states" {
                    let curancy = defaults1.float(forKey: "dollar")
                    setToUserDefaults(value: "$", key: "currency_type")
                    setToUserDefaults(value: curancy, key: "current_currency")
                    setToUserDefaults(value: "usd", key: "currentCurrency")
                }
                else {
                    setToUserDefaults(value: "gbp", key: "currentCurrency")
                    setToUserDefaults(value: "£", key: "currency_type")
                    setToUserDefaults(value: 1, key: "current_currency")
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
        
        // switch ""
    }
    
}
struct Categories: Codable {
    var id: Int?
    var title: String?
    var slug: String?
}
struct GroupTools: Codable {
    var itinerary: Bool?
    var map: Bool?
    var members: Bool?
    var chat: Bool?
    var documents: Bool?
    var checklist: Bool?
    var services: Bool?
    var group_leader: Bool?
    var rooming_list: Bool?
    var voting: Bool?
    var arrival_confirmation: Bool?
    var payments: Bool?
    
}
struct GroupImage: Codable {
    var id: Int?
    var path: String?
}
struct PriceObject: Codable{
    var type: String?
    var currencies: [CurrenciesObj]?
}
struct CurrenciesObj: Codable {
    var type: String?
     var special_price: Float?
     var price: Float?
}
struct AccessToken: Codable {
    var token_type: String?
    var expires_in: Int?
    var access_token: String?
}
struct GroupLeaderStruct: Codable{
    var id: Int?
    var email: String?
    var rating: Float?
    var phone: String?
    var company: CompanyStruct?
    var profile: GroupLeaderProfileStruct?
    var images: [ImageStruct]?
}
struct ImageStruct: Codable{
    var path: String?
}
struct RatingModel: Codable {
    var first_name: String?
    var last_name: String?
    var image_path: String?
    var reviewer_id: Int?
    var fullname: String?
    var id: Int?
    var rating: Float?
    var review: String?
}
struct RatingsStrubs: Codable {
    var ratings: [RatingModel]?
}
struct CompanyStruct: Codable{
    var name: String?
    var website: String?
    var about: String?
    var phone: String?
    var address: String?
     var rating: Float?
    var images: [ImageStruct]?
}
struct GroupLeaderProfileStruct: Codable{
    var first_name: String?
    var last_name: String?
    var about: String?
    var linkedin: String?
     var google_plus: String?
     var instagram: String?
    var facebook: String?
     var youtube: String?
     var twitter: String?

    
}
struct GroupSettings: Codable{
    var payments_url: String?
}
struct ChatObject: Codable{
    var id: Int?
}

struct GroupTranslation: Codable {
    var locale: String?
    var title: String?
    var description: String?
    var origin: String?
    var destination: String?
     var destination_place_id: String?
    
}
struct PlanDays: Codable{
    var days: [Day]?
}
struct PlanStruct: Codable{
    var days: [DayInterry]?
}

struct DayInterry: Codable{
    var id: Int?
    var group_id: Int?
    var day_number: Int?
    var date: String?
    var title: String?
    var images: [DayImage]?
    var services: [ServiceCollection]?
    var description: String?
    var destination_place_id: String?
    

}
struct ServiceCollection: Codable {
    var image: String?
    var name: String?
    var service_id: Int?
    var service_type: String?
    var type: String?
    var broadcastable_id: Int?
    
    var image_path: String?

}
struct FilterGetSelect: Codable{
    
    var categories: [FilterCatgory]?
    var companies: [FilterCompanies]?
}
struct FilterCatgory: Codable{
    var id: Int?
    var title: String?
    var index: Int? = 0
    var indexPath: IndexPath?
    var isChecked: Bool? = false
}
struct SearchObj: Codable{
    var autocomplete: [SearchStruct]?
    var groups: [StructGroup]?
    var companies: [StructGroup]?
}

struct SearchStruct: Codable{
    var description: String?
    var place_id: String?
    var name: String?
    var title: String?
    var image: String?
    var type: String?
    var group_id: Int?

}
struct StructGroup: Codable{
    var name: String?
    var title: String?
    var image: String?
    var type: String?
    var id: Int?
    var description: String?
    var place_id: String?
}
struct FilterCompanies: Codable{
    var name: String?
    var index: Int? = 0
    var isChecked: Bool? = false
}

struct ServiceHttp: Codable {
    var services: [ServiceCollection]?
}
struct ProviderModel: Codable {
    var id: Int?
    var images: [GroupImage]?
    var contacts: [ContactsModel]?
    var translations: [ServiceTranslations]?
    var name: String?
    var lat: String?
    var long: String?
    var company_name: String?
    var phone: String?
    var first_name: String?
    var last_name: String?
    var bio: String?
    var rating: Float?
    var city: String?
    var description: String?
    var website: String?
}
struct ProviderImages: Codable {
    var id: Int?
    var path: String?
}

struct ContactsModel: Codable {
    var email: String?
}


struct Day: Codable{
    var id: Int?
    var group_id: Int?
    var day_number: Int?
    var date: String?
    var title: String?
    var images: [DayImage]?
    var description: String?
    var hotels: [ServiceModel]?
    var restaurants: [ServiceModel]?
    var tour_guides: [ServiceModel]?
    var places: [ServiceModel]?
    var transports: [ServiceModel]?
    var activities: [ServiceModel]?
    var locations: [dayLocation]?
}

struct dayLocation: Codable{
    var id: Int?
    var day_id: Int?
    var location: String?
    var lat: String?
    var long: String?
    var title: String?
}
struct DayImage: Codable {
    var id : Int?
    var path: String?
}
struct ServiceModel: Codable {
    var id: Int?
    //  var age: Int?
    var translations: [ServiceTranslations]?
    var name: String?
    var phone: String?
    var first_day: Int?
    var last_day: Int?
    var company_name: String?
    var city: String?
    var rating: Double?
    var booking_rating: Double?
}
struct ServiceTranslations: Codable {
    var name: String?
    var first_name: String?
    var last_name: String?
    var languages: String?
    var city: String?
    var company_name: String?
    
}





class FCity: FObject {
    // KEY -----------------------------------------------------
    
    struct GroupItem: Codable {
        var data: [GroupItemObject]?
        var last_page: Int?
        var current_page: Int?
        var total: Int?
        
    }
   
    static let name = "name"
    static let intro = "intro"
    static let photourl = "photourl"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let zoom = "zoom"
    static let priority = "priority"
    static let weatherUrl = "weatherUrl"
    static let purchaseId = "applePurchaseId"
    static let videoIntroUrl = "videoIntroUrl"
    static let deactived = "deactived"
    // banner
    static let bannerUrl = "bannerUrl"
    static let bannerPhotoUrl = "bannerPhotoUrl"
    // KEY -----------------------------------------------------
    
    // Variables
    var weather : FWeather?
    
    // Banner
    func getBannerUrl() -> String? {
        return self[FCity.bannerUrl] as? String
    }
    
    
    func getBannerPhoto() -> String? {
        return self[FCity.bannerPhotoUrl] as? String
    }
    
    // MARK: - Get city info
    func getVideoIntroUrl() -> String? {
//        return "https://video.xx.fbcdn.net/v/t43.1792-2/18297340_460689054274572_5965548422676086784_n.mp4?efg=eyJybHIiOjE1MDAsInJsYSI6Mzc0MCwidmVuY29kZV90YWciOiJzdmVfaGQifQ%3D%3D&rl=1500&vabr=877&oh=42b063788c2bad55efef31ca55947647&oe=591BC782"
        return self[FCity.videoIntroUrl] as? String
    }
    
    func getName() -> String{
        return dictionary[FCity.name] as? String ?? ""
    }
    
    func getPurchaseId() -> String {
        return self[FCity.purchaseId] as? String ?? ""
    }
    
    func getState() -> FCityState {
        if getAvailableOffline() {
            return .Offline
        }
        if checkPurchased() {
            return.Purchased
        }
        let id = getPurchaseId()
        if id == "" {
            return .Free
        }
        return .Paid
    }
    
    func getPriority() -> Int {
        let p = self[FCity.priority]
        if p != nil {
            if p is NSNumber {
                return (p as! NSNumber).intValue
            }
            if p is Int {
                return p as! Int
            }
            if p is String {
                return Int(p as! String)!
            }
        }
        return  0
    }
    
    func getIntro() -> String{
        return dictionary[FCity.intro] as? String ?? ""
    }
    
    func getLongitute() -> Double {
        return self[FCity.longitude] != nil ? (self[FCity.longitude] as! NSString).doubleValue : 0
    }
    
    func getLatitude() -> Double {
        return self[FCity.latitude] != nil ? (self[FCity.latitude] as! NSString).doubleValue : 0
    }
    
    func getZoom() -> Float {
        return self[FCity.zoom] != nil ? (self[FCity.zoom] as! NSString).floatValue : 0.0
    }
    
    func getPhotoUrl() -> String {
        return self[FCity.photourl] as? String ?? ""
    }
    
    func getWeatherConditionsApi() -> String? {
        let long = self.getLongitute()
        let lat = self.getLatitude()
        if long == 0 || lat == 0 {
            return nil
        }
        return AppSetting.Weather.buildConditionApi(lat: lat, long: long)
    }
    
    func getWeatherForecastApi() -> String? {
        let long = self.getLongitute()
        let lat = self.getLatitude()
        if long == 0 || lat == 0 {
            return nil
        }
        return AppSetting.Weather.buildForecastApi(lat: lat, long: long)
    }
    
    func getDeactived() -> Bool {
        return self[FCity.deactived] as? Bool ?? false
    }
    
    // MARK: - Utility functions
    // MARK: - Check available offline by id
    func setAvailableOffline(){
        if objectId == nil {
            return
        }
        UserDefaults.standard.set(true, forKey: objectId!)
        UserDefaults.standard.synchronize()
    }
    
    func getAvailableOffline() -> Bool {
        if objectId == nil {
            return false
        }
        let offline = UserDefaults.standard.object(forKey: objectId!)
        return offline as? Bool ?? false
    }
    
    func setPurchased(){
        let id = getPurchaseId()
        if id != "" {
            PurchaseManager.savePurchasedItem(id: id)
        }
    }
    
    func checkPurchased() -> Bool {
        let id = getPurchaseId()
        return PurchaseManager.checkPurchasedItem(id: id)
    }
}
