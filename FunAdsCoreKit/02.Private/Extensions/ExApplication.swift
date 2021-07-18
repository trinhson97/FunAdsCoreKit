//
//  ExApplication.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/13/21.
//

import UIKit
import Foundation

extension UIApplication {

    static func topViewController() -> UIViewController? {
        let keyWindow = shared.windows.filter {$0.isKeyWindow}.first
        guard var top = keyWindow?.rootViewController else {
            return nil
        }
        while let next = top.presentedViewController {
            top = next
        }
        return top
    }
}

