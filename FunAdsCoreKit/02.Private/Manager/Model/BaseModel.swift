//
//  BaseModel.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import Foundation

public class BaseModelJSON: Mappable {
    
    var code: Int!
    var message: String?
    var success: Bool?
    
    public func mapping(map: Map) {
        code <- (map["code"])
        message <- (map["message"])
        success <- (map["success"])
    }
    
    init() {}
    
    public required init?(map: Map) {
    }
}
