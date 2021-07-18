//
//  AdsDropDownText.swift
//  Ads_ios_demo
//
//  Created by IT on 2/25/21.
//

import UIKit

class AdsDropDownText: MessageView {

    @IBOutlet weak var dropDownTextLabel: MarqueeLabel!
    
    @IBOutlet weak var bgDropDownView: UIView! {
        didSet {
            bgDropDownView.clipsToBounds = true
        }
    }
    
    var text = ""
    var countDown: Double?
    var data: DetailInventory?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dropDownTextLabel.type = .continuous
        dropDownTextLabel.speed = .duration(CGFloat(countDown ?? 0.0) * 3)
        dropDownTextLabel.animationCurve = .linear
        dropDownTextLabel.leadingBuffer = 10
        dropDownTextLabel.text = text + "                                                  "
    }

    override func draw(_ rect: CGRect) {
        super .draw(rect)
    }
    
    @IBAction func CTA(_ sender: Any) {
        Storage.getCtaAction?(data ?? DetailInventory())
    }
}
