//
//  AdsSDK9Pay.swift
//  FunAdsCoreKit
//
//  Created by Trịnh Bảo Sơn'Mac on 30/07/2021.
//
import Foundation

open class NinePayAds: NSObject {
    open class func initAds(api_key: String, completion: @escaping ([Inventory]) -> ()) {
        Storage.app_id = api_key
        APIManage.shared.getApp(ApiKey: api_key) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
//                Storage.requestPermission()
                completion(Inventorys.data ?? [])
            }
        }
    }

    open class func showAdsOn9payApp(code: String, ctaType: String ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithCode(code: code) {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
            Storage.getCtaAction = { inventory in
                if ctaType == "all" {
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                }
                switch ctaType {
                case "all":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                case "only_callback":
                    completion(inventory.data?.metaData?.additionData?.data ?? "")
                case "only_browser":
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                default:
                    print("type empty")
                }
            }
        }
    }
    
    open class func closeAds(completion: @escaping () -> ()) {
        SwiftMessages.hide()
        completion()
    }
    
    open class func saveUserInfor(user_id: String?) {
        Storage.user_id = user_id ?? ""
    }
}


