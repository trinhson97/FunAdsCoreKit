//
//  MetaData.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import Foundation

class MetaData: Mappable, Codable {
    
    var logoImage: DataImageVsPlayer?
    var shortDescription: DataText?
    var shortTitle: DataText?
    var imageBanner: DataImageVsPlayer?
    var image: DataImageVsPlayer?
    var video: DataImageVsPlayer?
    var longTitle: DataText?
    var waitingTime: DataText?
    var additionData: AdditionData?
    var cta0: Cta0?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        logoImage <- (map["logoImage"])
        shortDescription <- (map["shortDescription"])
        shortTitle <- (map["shortTitle"])
        imageBanner <- (map["imageBanner"])
        video <- (map["video"])
        waitingTime <- (map["waitingTime"])
        longTitle <- (map["longTitle"])
        image <- (map["image"])
        additionData <- (map["additionData"])
        cta0 <- (map["cta0"])
    }
    
}

class DataImageVsPlayer: Mappable, Codable {
    
    var label: String?
    var name: String?
    var type: String?
    var limit_dimension: String?
    var limit_size: String?
    var data: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        label <- (map["label"])
        name <- (map["name"])
        type <- (map["type"])
        limit_dimension <- (map["limit_dimension"])
        limit_size <- (map["limit_size"])
        data <- (map["data"])
    }
}


class DataText: Mappable, Codable {
    var label: String?
    var name: String?
    var type: String?
    var limit_text: String?
    var data: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        label <- (map["label"])
        name <- (map["name"])
        type <- (map["type"])
        limit_text <- (map["limit_text"])
        data <- (map["data"])
    }
}

class Cta0: Mappable, Codable {
    var label: String?
    var link: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        label <- (map["label"])
        link <- (map["link"])
    }
}

class AdditionData: Mappable, Codable {
    var data: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        data <- (map["data"])
    }
}

