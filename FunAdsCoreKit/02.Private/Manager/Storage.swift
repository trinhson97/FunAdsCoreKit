//
//  Storage.swift
//  FunAdsCoreKit
//
//  Created by IT on 3/3/21.
//

import Foundation
import UIKit

@objc public class Storage: NSObject {
    static let KEY_DB_LOCAL = "playfun_list_conditions"
    static let version_ads = "1.0.1"
    static var user_id = ""
    static let version_name: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    static var app_id = ""
    static let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as! String
    static var inventory_id = ""
    static var inventory_code = ""
    static var character_id = ""
    static var server_id = ""
    static var token = ""
    static var raa_id = ""
    static var even_id = ""
    static var params_tracking = ""
    static var tracking_view_url = ""
    static var appKey = ""
    static func orientation() -> String {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            return "1"
        }else {
            return "0"
        }
    }
    
    static var getCtaAction: ((_ data: DetailInventory) -> Void)?
    
    static func setInventorys(_ data: Inventorys) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: KEY_DB_LOCAL)
        }
    }
    
    static func getInventorys(conditions: String, value: Int) -> Inventorys? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: KEY_DB_LOCAL) as? Data {
            let decoder = JSONDecoder()
            if let loadedInventorys = try? decoder.decode(Inventorys.self, from: savedPerson) {
                return loadedInventorys
            }
        }
        return nil
    }
    
    static func getInventorysWithConditions(conditions: String, value: Int) -> Inventory? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: KEY_DB_LOCAL) as? Data {
            let decoder = JSONDecoder()
            if let loadedInventorys = try? decoder.decode(Inventorys.self, from: savedPerson) {
                if let listInventorysLocal = loadedInventorys.data {
                    for i in listInventorysLocal {
                        if ((i.conditions?.first(where: {$0.type == "\(conditions)"})) != nil){
                            if conditions == "save_character" {
                                return i
                            }
                        }
                        if ((i.conditions?.first(where: {$0.type == "\(conditions)"})) != nil){
                            if conditions == "extract_data" {
                                return i
                            }
                        }
                        if let foo = i.conditions?.first(where: {$0.type == "\(conditions)"}) {
                            if conditions == "period" {
                                foo.value = foo.value! * 60
                                return i
                            }
                        }
                        if let foo = i.conditions?.first(where: {$0.type == "\(conditions)"}) {
                            if foo.value == value {
                                return i
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    static func getInventorysWithCode(code: String) -> Inventory? {
        let defaults = UserDefaults.standard
        if let savedPerson = defaults.object(forKey: KEY_DB_LOCAL) as? Data {
            let decoder = JSONDecoder()
            if let loadedInventorys = try? decoder.decode(Inventorys.self, from: savedPerson) {
                if let listInventorysLocal = loadedInventorys.data {
                    for i in listInventorysLocal {
                        if i.code == code {
                            return i
                        }
                    }
                }
            }
        }
        return nil
    }
}
