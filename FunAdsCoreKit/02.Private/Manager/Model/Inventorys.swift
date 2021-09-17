//
//  InventoryModel.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import Foundation

class Inventorys: BaseModelJSON, Codable {
    
    var data: [Inventory]?
    
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

@objc public class Inventory: NSObject, Mappable, Codable  {
    public var id: Int!
    public var code: String!
    public var name: String?
    public var alias: String?
    public var conditions: [Conditions]?
        
    override init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        id <- (map["id"])
        code <- (map["code"])
        name <- (map["name"])
        alias <- (map["alias"])
        conditions <- (map["conditions"])
    }
}

@objc public class Conditions:NSObject, Mappable, Codable  {
    public var type: String?
    public var value: Int?
    
    override init() {}
    
    required public init?(map: Map) {}
    
    public func mapping(map: Map) {
        type <- (map["type"])
        value <- (map["value"])
    }
}
