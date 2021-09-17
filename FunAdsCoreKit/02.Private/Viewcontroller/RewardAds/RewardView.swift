//
//  RewardView.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/2/21.
//

import UIKit
import Foundation

class RewardView: MessageView {
    
    @IBOutlet weak var imageAds: UIImageView!
    
    var detailInventory: DetailInventory?
    var adsAction: (() -> Void)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        guard let urlImage = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        self.detailInventory = detailInventory
        imageAds.load(url: urlImage)
    }
    
    @IBAction func ActionAds(_ sender: Any) {
        SwiftMessages.hide()
        if let data = Storage.getInventorysWithCode(code: self.detailInventory?.data?.next_step ?? "") {
            AdsIOSControl.showAdsSDK(code: data.code, id: data.id)
        }
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        SwiftMessages.hide()
    }
}
