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

    // MARK: ACtion when user click to CTA and return callback
    // ctaType:
    //   + all: open to browser/ open to store Apple + return jsonbase64 on CMS
    //   + only_callback: only return jsonbase64 (not open to browser)
    //   + only_browser: only open to browser (not return jsonbase64)
    // if ctaType different from the above 3 cases ads will dont show
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
    
    // MARK: Close ads
    public class func closeAds(completion: @escaping () -> ()) {
        SwiftMessages.hide()
        completion()
    }
    
    
    public class func saveUserInfor(user_id: String?) {
        Storage.user_id = user_id ?? ""
    }
}


