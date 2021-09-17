//
//  RewardErrorView.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/5/21.
//

import UIKit

class RewardErrorView: MessageView {

    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func loađata(_ message: String, _ detail: String) {
        messageLabel.text = message
        detailLabel.text = detail
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        SwiftMessages.hide()
    }
}
