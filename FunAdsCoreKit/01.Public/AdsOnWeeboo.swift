//
//  AdsOnWeeboo.swift
//  FunAdsCoreKit
//
//  Created by IT on 7/9/21.
//

import Foundation

public class WeebooAds: NSObject {
    public class func init_ads(api_key: String, completion: @escaping ([Inventory]) -> ()) {
        Storage.app_id = api_key
        APIManage.shared.getApp(ApiKey: api_key) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
                completion(Inventorys.data ?? [])
            }
        }
    }

    public class func showAdsOnWeebooApp(code: String, isPushToStore: Bool ,completion: @escaping (String) -> ()) {
        if let data = Storage.getInventorysWithCode(code: code) {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
            Storage.getCtaAction = { inventory in
                if isPushToStore {
                    completion(inventory.data?.metaData?.cta0?.link ?? "")
                    AdsIOSControl.openUrl(url: inventory.data?.metaData?.cta0?.link ?? "")
                }else {
                    completion(inventory.data?.metaData?.cta0?.link ?? "")
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
