//
//  DetailInventoryModel.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import Foundation

class DetailInventory: BaseModelJSON {
    var data: DataShowOnAds?
    
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
    }
}

class DataShowOnAds: Mappable, Codable {
    
    var htmlData: String?
    var metaData: MetaData?
    var templateType: String?
    var compress: Int?
    var limit: Limit?
    var raa_id: Int?
    var dimension: String?
    var next_step: String?
    var params_tracking: String?
    var even_id: String?
    var countdown: Countdown?
    var countdown_off: CountdownOff?
    var tracking_view_url: String?
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        htmlData <- (map["htmlData"])
        metaData <- (map["metaData"])
        templateType <- (map["templateType"])
        compress <- (map["compress"])
        limit <- (map["limit"])
        raa_id <- (map["raa_id"])
        dimension <- (map["dimension"])
        next_step <- (map["next_step"])
        countdown <- (map["countdown"])
        params_tracking <- (map["params_tracking"])
        tracking_view_url <- (map["tracking_view_url"])
        even_id <- (map["even_id"])
        countdown_off <- (map["countdown_off"])
    }
    
}

class Countdown: Mappable, Codable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        value <- (map["value"])
    }
    
    var value: Int?
    
}

class CountdownOff: Mappable, Codable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        value <- (map["value"])
        do_show_close <- (map["do_show_close"])
    }
    
    var value: Int?
    var do_show_close: Bool?
}

class Limit: Mappable, Codable {
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id <- (map["id"])
        end_time <- (map["end_time"])
        max_on_day <- (map["max_on_day"])
        distance <- (map["distance"])
    }
    
    var id: Int!
    var end_time: String?
    var max_on_day: String?
    var distance: String?
    
}
