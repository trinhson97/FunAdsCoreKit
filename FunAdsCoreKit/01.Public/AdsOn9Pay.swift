//
//  AdsOn9Pay.swift
//  FunAdsCoreKit
//
//  Created by IT on 6/23/21.
//

import Foundation

public class NinePayAds: NSObject {
    public class func init_ads(api_key: String, completion: @escaping ([Inventory]) -> ()) {
        Storage.app_id = api_key
        APIManage.shared.getApp(ApiKey: api_key) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
                completion(Inventorys.data ?? [])
            }
        }
    }

    public class func showAdsOn9payApp(code: String, ctaType: String ,completion: @escaping (String) -> ()) {
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
    
    public class func closeAds(completion: @escaping () -> ()) {
        SwiftMessages.hide()
        completion()
    }
    
    public class func saveUserInfor(user_id: String?) {
        Storage.user_id = user_id ?? ""
    }
}


