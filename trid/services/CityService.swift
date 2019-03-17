//
//  CityService.swift
//  trid
//
//  Created by Black on 9/29/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase

protocol CityServiceProtocol {
    func cityServiceAdded(_ city : FCity)
    func cityServiceChangedAt(index: Int)
    func cityServiceRemovedAt(index : Int)
}

class CityService: NSObject {
    // Path to table
    let path = "city"
    
    // Singleton
    static let shared = CityService()
    
    // ref
    var ref : DatabaseReference!
    var subpath = ""
    var delegate : CityServiceProtocol?
    
    // data
    var cities : [FCity] = []
    
    var works: [DispatchWorkItem] = []
    var queue: OperationQueue = OperationQueue()
    var count = 0
    
    // init
    override init() {
        super.init()
    }
    
    public func configureDatabase(countrykey: String, finish: @escaping () -> Void) { // _ block: @escaping () -> Void
        subpath = path + "/" + countrykey
        cities.removeAll()
        // ref
        ref = Database.database().reference(withPath: subpath)
        ref.keepSynced(true)
        var syncing = true
        // remove all observe
        ref.removeAllObservers()
        // register listener
        ref.observe(.childAdded, with: {snapshot in
            let city = FCity(path: self.subpath, snapshot: snapshot)
            self.cities.append(city)
            if !syncing {
                self.delegate?.cityServiceAdded(city)
            }
        })
        ref.observe(.childChanged, with: {snapshot in
            for i in (0 ..< self.cities.count) {
                let city = self.cities[i]
                if city.objectId! == snapshot.key {
                    self.cities[i] = FCity(path: self.subpath, snapshot: snapshot)
                    if !syncing {
                        self.delegate?.cityServiceChangedAt(index: i)
                    }
                    break
                }
            }
        })
        ref.observe(.childRemoved, with: {snapshot in
            for i in (0 ..< self.cities.count) {
                let city = self.cities[i]
                if city.objectId! == snapshot.key {
                    self.cities.remove(at: i)
                    if !syncing {
                        self.delegate?.cityServiceRemovedAt(index: i)
                    }
                    break
                }
            }
        })
        ref.observeSingleEvent(of: .value, with: {snapshot in
            debugPrint("DONE GET City")
            self.cities =  self.cities.sorted(by: {$0.getPriority() > $1.getPriority()})
            finish()
            syncing = false
            /// Perform remove data
            #if DEBUG
            self.deleteData()
            #endif
        })
    }
}

extension CityService {
    func deleteData() {
        //queue.maxConcurrentOperationCount = 1
        cities.forEach { (city) in
            guard let key = city.objectId else {
                return
            }
            if city.objectId == "-KSVJj2K_2G2Be0P284R" // sapa
                || city.objectId == "-KS_EQvtmpeFtkOhGCRH" // da nang
                || city.objectId == "-KSZVQGInPqd5XcLCw6q" // hue
                || city.objectId == "-KXxedQ8VWngYa86dkHA" // Mui ne
                || city.objectId == "-KfL8FT21IFiTmW_Zb7O" // Vung tau
            {
                return
            }
            let workItem = DispatchWorkItem(block: {
                PlaceService.shared.configureDatabase(citykey: key, finish: {
                    let places = PlaceService.shared.places
                    places.forEach({ (place) in
                        self.queue.addOperation {
                            place.deleteInBackground()
                            debugPrint("Deleting \(self.count)", place.getName())
                            self.count += 1
                        }
                    })
                    self.queue.addOperation {
                         city.deleteInBackground()
                        debugPrint("Deleting CITY", city.getName())
                    }
                    self.works.removeFirst()
                    self.works.first?.perform()
                })
            })
            self.works.append(workItem)
        }
        
        let deleteUser = DispatchWorkItem {
            let users = UserService.shared.users.filter({$0.objectId != "dO24LNmQrQOYup7p73z4KfyLtui1"})
            users.forEach({ (user) in
                guard user.getEmail() != "demo@tridme.com" && user.getUserId() != "dO24LNmQrQOYup7p73z4KfyLtui1" else {
                    return
                }
                self.queue.addOperation {
                    user.deleteInBackground()
                    debugPrint("Deleting ", user.getName())
                }
            })
        }
        
        if UserService.shared.users.count > 0 {
            deleteUser.perform()
        }
        else {
            UserService.shared.configureDatabase {
                deleteUser.perform()
            }
        }
        
        self.works.first?.perform()
    }
}
