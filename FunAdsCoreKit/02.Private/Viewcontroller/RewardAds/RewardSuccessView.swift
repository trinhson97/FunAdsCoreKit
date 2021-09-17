//
//  RewardSuccessView.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/5/21.
//

import UIKit

class RewardSuccessView: MessageView {

    @IBOutlet weak var messageLabel: UILabel!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func loadData(_ message: String) {
        messageLabel.text = message
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        SwiftMessages.hide()
    }
}
