//
//  AppsModel.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import Foundation

class AppsModel: BaseModelJSON {
    
    var data: [App]?
    
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

class App: Mappable, Codable {
    var name: String?
    var api_kep: String?
    var alias: String?

    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        name <- (map["name"])
        api_kep <- (map["api_kep"])
        alias <- (map["alias"])
    }
    
    init() {}
}
