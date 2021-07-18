//
//  AdsOnWeeboo.swift
//  FunAdsCoreKit
//
//  Created by IT on 7/9/21.
//

import Foundation

open class showWeebooAds {
     public static func ads(code: Inventory) {
        AdsIOSControl.showAdsSDK(code: code.code, id: code.id)
    }
}
open class WeebooAds {
    open class func creatAds(adsKey: String) {
        Storage.app_id = adsKey
        APIManage.shared.getApp(ApiKey: adsKey) { (status, Inventorys) in
            if status != false {
                Storage.setInventorys(Inventorys)
            }
        }
    }
    open class func showAdsOnWeeboo(InventoryCode code: String) {
        if let data = Storage.getInventorysWithCode(code: code) {
            showWeebooAds.ads(code: data)
        }
    }
}

