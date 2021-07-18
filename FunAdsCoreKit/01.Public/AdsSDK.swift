//
//  AdsSDK.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/13/21.
//

import Foundation
import UIKit

// Test on devices team
public class FunAdsTest: NSObject {
    public class func initAds(api_key: String, appKey: String?) {
        Storage.appKey = appKey ?? ""
        Storage.app_id = api_key
        APIManage.shared.getApp(ApiKey: api_key) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
            }
        }
    }
}

public class FunAdsWithConditionsTest: NSObject{
    public class func saveUserInfor(token: String?, server_id: String?, character_id: String?, user_id: String?) {
        Storage.token = token ?? ""
        Storage.server_id = server_id ?? ""
        Storage.character_id = character_id ?? ""
        Storage.user_id = user_id ?? ""
    }
    
    public class func adsLevelUp(value: Int, ctaStyle: String ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithConditions(conditions: "level_up", value: value) {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
            Storage.getCtaAction = { inventory in
                if ctaStyle == "all" {
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                }
                switch ctaStyle {
                case "all":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                case "only_callback":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                case "only_browser":
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                default:
                    print("Style empty")
                }
            }
        }
    }
    
    public class func adsSaveCharacter(ctaStyle: String ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithConditions(conditions: "save_character", value: 0) {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
            Storage.getCtaAction = { inventory in
                if ctaStyle == "all" {
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                }
                switch ctaStyle {
                case "all":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                case "only_callback":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                case "only_browser":
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                default:
                    print("Style empty")
                }
            }
        }
    }
    
    public class func showAdsPeriod(ctaStyle: String ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithConditions(conditions: "period", value: 0) {
            if let foo = data.conditions?.first(where: {$0.type == "period"}) {
                AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
                Storage.getCtaAction = { inventory in
                    if ctaStyle == "all" {
                        completion(inventory.data?.metaData?.additionData?.data ?? "")
                        AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                    }
                    switch ctaStyle {
                    case "all":
                        completion(inventory.data?.metaData?.additionData?.data ?? "")
                        AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                    case "only_callback":
                        completion(inventory.data?.metaData?.additionData?.data ?? "")
                    case "only_browser":
                        AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                    default:
                        print("Style empty")
                    }
                }
                
                Timer.scheduledTimer(withTimeInterval: Double(foo.value ?? 0), repeats: true) { (timer) in
                    AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
                    Storage.getCtaAction = { inventory in
                        if ctaStyle == "all" {
                            completion(inventory.data?.metaData?.additionData?.data ?? "")
                            AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                        }
                        switch ctaStyle {
                        case "all":
                            completion(inventory.data?.metaData?.additionData?.data ?? "")
                            AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                        case "only_callback":
                            completion(inventory.data?.metaData?.additionData?.data ?? "")
                        case "only_browser":
                            AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                        default:
                            print("Style empty")
                        }
                    }
                }
            }
        }
    }
    
    public class func showAdsExtractData(ctaStyle: String ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithConditions(conditions: "extract_data", value: 0) {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
            Storage.getCtaAction = { inventory in
                if ctaStyle == "all" {
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                }
                switch ctaStyle {
                case "all":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                case "only_callback":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                case "only_browser":
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                default:
                    print("Style empty")
                }
            }
        }
    }
    
    public class func closeAds() {
        SwiftMessages.hide()
    }
}

// Public to mobile

@objc public class FunAds: NSObject {
    @objc public func init_ads(api_key: String, appKey: String?) {
        Storage.appKey = appKey ?? ""
        Storage.app_id = api_key
        APIManage.shared.getApp(ApiKey: api_key) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
            }
        }
    }
}

@objc public class FunAdsWithConditions: NSObject{
    @objc public func saveUserInfor(token: String?, server_id: String?, character_id: String?, user_id: String?) {
        Storage.token = token ?? ""
        Storage.server_id = server_id ?? ""
        Storage.character_id = character_id ?? ""
        Storage.user_id = user_id ?? ""
    }
    
    @objc public func showAdsLevelUp(value: Int) {
        if let data = Storage.getInventorysWithConditions(conditions: "level_up", value: value) {
            actionShowAds.ads(code: data)
        }
    }
    
    @objc public func showAdsSaveCharacter() {
        if let data = Storage.getInventorysWithConditions(conditions: "save_character", value: 0) {
            actionShowAds.ads(code: data)
        }
    }
    
    @objc public func showAdsPeriod() {
        if let data = Storage.getInventorysWithConditions(conditions: "period", value: 0) {
            if let foo = data.conditions?.first(where: {$0.type == "period"}) {
                actionShowAds.ads(code: data)
                Timer.scheduledTimer(withTimeInterval: Double(foo.value ?? 0), repeats: false) { (timer) in
                    actionShowAds.ads(code: data)
                }
            }
        }
    }
        
    @objc public func showAdsExtractData() {
        if let data = Storage.getInventorysWithConditions(conditions: "extract_data", value: 0) {
            actionShowAds.ads(code: data)
        }
    }
}

@objc open class actionShowAds: NSObject {
    @objc public static func ads(code: Inventory) {
        AdsIOSControl.showAdsSDK(code: code.code, id: code.id)
    }
}
