//
//  ApiManager.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/19/21.
//

import UIKit
import Foundation

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}


enum DAPIDefine : String {
    case inventory = "/inventory/"
    case app = "/app/"
    case apps = "/apps"
    case trackingAds = "/tracking-ads?type=WATCHED_VIDEO"
    case traking = "https://storage.googleapis.com/prod-adsfun/pixel/pixel.jpg"
    
    func url() -> String {
        let HOST = "https://ads-api.playfun.vn/v3"
//        let HOST = "https://stg-ads-api.playfun.vn/v3"
        return HOST + self.rawValue
    }
}

typealias Completion = (_ succes: Bool, _ data: Any?) -> ()

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return true
    }
}

class APIManage: NSObject {
    fileprivate var queue:OperationQueue?
    fileprivate var listURLDownload:[URL] = []
    
    private let TIMEOUT_REQUEST:TimeInterval = 60
    
    //MARK: Shared Instance
    static let shared:APIManage = APIManage()
    
    //MAKR: private
    
    fileprivate func request(urlString: String,
                             paramJson: String,
                             method: HTTPMethod,
                             complete: Completion?) {
        if Connectivity.isConnectedToInternet() {
            var request:URLRequest!
            
            
            //MARK: Method GET
            if method == .get {
                if paramJson != "" {
                    request = URLRequest(url: URL(string:"\(urlString)?\((paramJson.data(using: .utf8))!)")!)
                }
                else {
                    guard let url = URL(string:urlString) else { return }
                    request = URLRequest(url: url)
                }
                let headers: Dictionary = ["Content-Type": "application/json; charset=utf-8",
                                           "version-ads": Storage.version_ads,
                                           "device-name": UIDevice.current.name,
                                           "device-os": UIDevice.current.systemVersion,
                                           "device-resolution": "\(UIDevice.screenSize)",
                                           "user-id": Storage.user_id,
                                           "bundle-id": Storage.bundleId,
                                           "version-name": Storage.version_name,
                                           "platform":"ios",
                                           "app-id": Storage.app_id,
                                           "inventory-id": Storage.inventory_id,
                                           "inventory-code": Storage.inventory_code,
                                           "orientation": Storage.orientation(),
                                           "character-id": Storage.character_id,
                                           "server-id": Storage.server_id,
                                           "token": Storage.token,
                                           "appkey": Storage.appKey
                                          ]
                request.allHTTPHeaderFields = headers
            } else if method == .post {
                guard let url = URL(string:urlString) else { return }
                request = URLRequest(url: url)
                
                // content-type
                let headers: Dictionary = ["Content-Type": "application/json; charset=utf-8",
                                           "version-ads": Storage.version_ads,
                                           "device-name": UIDevice.current.name,
                                           "device-os": UIDevice.current.systemVersion,
                                           "device-resolution": "\(UIDevice.screenSize)",
                                           "user-id": Storage.user_id,
                                           "bundle-id": Storage.bundleId,
                                           "version-name": Storage.version_name,
                                           "platform":"ios",
                                           "app-id": Storage.app_id,
                                           "inventory-id": Storage.inventory_id,
                                           "inventory-code": Storage.inventory_code,
                                           "orientation": Storage.orientation(),
                                           "character-id": Storage.character_id,
                                           "server-id": Storage.server_id,
                                           "token": Storage.token,
                                           "appkey": Storage.appKey
                                          ]
                request.allHTTPHeaderFields = headers
                if paramJson != "" {
                    request.httpBody = paramJson.data(using: .utf8)
                    BLogInfo(paramJson)
                }
            } else {
                guard let url = URL(string:urlString) else { return }
                request = URLRequest(url: url)
                
                // content-type
                let headers: Dictionary = ["Content-Type": "application/json; charset=utf-8",
                                           "version-ads": Storage.version_ads,
                                           "device-name": UIDevice.current.name,
                                           "device-os": UIDevice.current.systemVersion,
                                           "device-resolution": "\(UIDevice.screenSize)",
                                           "user-id": Storage.user_id,
                                           "bundle-id": Storage.bundleId,
                                           "version-name": Storage.version_name,
                                           "platform":"ios",
                                           "app-id": Storage.app_id,
                                           "inventory-id": Storage.inventory_id,
                                           "inventory-code": Storage.inventory_code,
                                           "orientation": Storage.orientation(),
                                           "character-id": Storage.character_id,
                                           "server-id": Storage.server_id,
                                           "token": Storage.token,
                                           "appkey": Storage.appKey
                                          ]
                request.allHTTPHeaderFields = headers
                if paramJson != "" {
                    request.httpBody = paramJson.data(using: .utf8)
                    BLogInfo(paramJson)
                }
            }
             
            //MARK: Set Header
//            request.allHTTPHeaderFields = Header.content()
            
            request.timeoutInterval = TIMEOUT_REQUEST
            request.httpMethod = method.rawValue
            
            
            //
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // check for fundamental networking error
                guard let data = data, error == nil else {
                    if let block = complete {
                        DispatchQueue.main.async {
                            block(false, error)
                        }
                    }
                    return
                }
                // check for http errors
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200, let res = response {
                    BLog("statusCode should be 200, but is \(httpStatus.statusCode)")
                    BLog("response = \(res)")
                }
                if let block = complete {
                    DispatchQueue.main.async {
                        if let json = self.dataToJSON(data: data) {
                            BLog("response json = \(json)")
                            block(true, String(data: data, encoding: .utf8))
                        }
                        else if let responseString = String(data: data, encoding: .utf8) {
                            BLog("response string = \(responseString)")
                            block(true, error)
                        }
                    }
                }
            }
            task.resume()
        } else {
            BLog("Error API")
        }
    }
    
    private func dataToJSON(data: Data) -> Any? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let myJSONError {
            BLog("convert to json error: \(myJSONError)")
        }
        return nil
    }
}

extension APIManage {
    func trackingAds(raa_id: String?, inventory_id: String?, inventory_code: String?,complete: @escaping () -> ()){
        Storage.inventory_id = inventory_id ?? ""
        Storage.inventory_code = inventory_code ?? ""
        var url = ""
        if Storage.tracking_view_url != "" {
            url = Storage.tracking_view_url
        }else {
            var url = DAPIDefine.traking.rawValue
            if Storage.params_tracking != "" {
                url = url + Storage.params_tracking
            }else {
                url = url + "?raaId=\(raa_id ?? "")" + "&inventoryId=\(inventory_id ?? "")" + "&inventoryCode=\(inventory_code ?? "")"
            }
        }
        let paramJSOn: String = ""
        request(urlString: url, paramJson: paramJSOn, method: .get) { (success, data) in
            if success {
                BLog("Oke")
            }else {
                BLog("Tạch")
            }
            complete()
        }
    }
    
    func getAllApp(complete: @escaping (Bool, AppsModel) -> ()){
        let url = DAPIDefine.apps.url()
        let paramJSOn: String = ""
        request(urlString: url, paramJson: paramJSOn, method: .get) { (success, data) in
            if data == nil {
                complete(false, AppsModel())
            }else {
                if (data as? String) == nil {
                    complete(false, AppsModel())
                    return
                } else {
                    complete(success, AppsModel(JSONString: (data as! String))!)
                }
            }
        }
    }
    
    func getApp(ApiKey: String ,complete: @escaping (Bool, Inventorys) -> ()){
        Storage.app_id = ApiKey
        let url = DAPIDefine.app.url() + ApiKey
        let paramJSOn: String = ""
        request(urlString: url, paramJson: paramJSOn, method: .get) { (success, data) in
            if data == nil {
                complete(false, Inventorys())
            }else {
                if (data as? String) == nil {
                    complete(false, Inventorys())
                    return
                } else {
                    complete(success, Inventorys(JSONString: (data as! String))!)
                }
            }
        }
    }
    
    func getinventory(code: String ,complete: @escaping (Bool, DetailInventory) -> ()){
        let url = DAPIDefine.inventory.url() + code + "/fetch-ads"
        let paramJSOn: String = ""
        request(urlString: url, paramJson: paramJSOn, method: .get) { (success, data) in
            if data == nil {
                complete(false, DetailInventory())
            }else {
                if (data as? String) == nil {
                    complete(false, DetailInventory())
                    return
                } else {
                    complete(success, DetailInventory(JSONString: (data as! String))!)
                }
            }
        }
    }
    
    func trackingRewardAds(trackingAdsParam: TTrackingAdss, complete: @escaping (Bool, trackingAdss) -> ()){
        let url = DAPIDefine.trackingAds.url()
        let paramJSOn: String = trackingAdsParam.toString()
        request(urlString: url, paramJson: paramJSOn, method: .post) { (success, data) in
            if data == nil {
                complete(false, trackingAdss());
            }else {
                if (data as? String) == nil {
                    complete(false, trackingAdss())
                    return
                } else {
                    complete(success, trackingAdss(JSONString: (data as! String))!)
                }
            }
        }
    }

}
