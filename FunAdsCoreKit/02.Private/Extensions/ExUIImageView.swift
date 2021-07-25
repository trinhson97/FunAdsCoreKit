//
//  ExUIImageView.swift
//  FunAdsCoreKit
//
//  Created by IT on 5/12/21.
//

import UIKit
import Foundation

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
