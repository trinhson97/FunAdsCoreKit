//
//  TTrackingAds.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/9/21.
//

import Foundation

class TTrackingAdss {
    var raa_id = Storage.raa_id
    var event_id: String?
    
    init(event_id:String?) {
        self.event_id = event_id
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "raa_id": raa_id,
            "event_id": event_id == nil ? "" : event_id!,
        ]
    }
    
    func toString() -> String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.toDictionary(), options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}

class trackingAdss: BaseModelJSON {
    var data: dataTracking?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        code <- (map["code"])
        message <- (map["message"])
        data <- (map["data"])
        success <- (map["success"])
    }
}

class dataTracking: Mappable{
    var detail: String?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        detail <- (map["detail"])
    }
}
