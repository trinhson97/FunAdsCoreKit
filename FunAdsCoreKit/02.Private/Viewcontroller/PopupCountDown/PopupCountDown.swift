//
//  PopupCountDown.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/13/21.
//

import UIKit

class PopupCountDown: MessageView {
    
    @IBOutlet weak var countDownLabel: UILabel!
    var gameTimer: Timer?
    var closeAction: (() -> Void)?
    var counter = 0
    var timeCountDown = 0.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateView(timeCountDown)
    }
    
    func updateView(_ timeCountDown: Double) {
        self.counter = Int(timeCountDown)
        self.countDownLabel.text = "Ads sẽ hiển thị sau " + "\(Int(timeCountDown))"
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        //example functionality
        if counter > 0 {
            print("\(counter) seconds to the end of the world")
            counter -= 1
            self.countDownLabel.text = "Ads sẽ hiển thị sau " + "\(counter)"
            if counter == 0 {
                gameTimer?.invalidate()
                SwiftMessages.hide()
            }
        }
    }
}
