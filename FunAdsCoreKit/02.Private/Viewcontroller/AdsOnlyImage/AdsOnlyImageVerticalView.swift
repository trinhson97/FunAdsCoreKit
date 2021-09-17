//
//  AdsOnlyImageHorizontal.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/22/21.
//

import UIKit

class AdsOnlyImageVerticalView: MessageView {

    var url: String = ""
    var additionData: String = ""
    var gameTimer: Timer?
    var counter = 0
    var timeCountDown = 0.0
    var dataInventory = DetailInventory()
        
    @IBOutlet weak var offView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var imageGame: UIImageView!
    
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        gameTimer?.invalidate()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.dataInventory = detailInventory ?? DetailInventory()
        guard let urlBackgroundGame = URL(string: detailInventory?.data?.metaData?.imageBanner?.data ?? "") else { return }
        self.url = detailInventory?.data?.metaData?.cta0?.link ?? ""
        self.additionData = detailInventory?.data?.metaData?.additionData?.data ?? ""
        imageGame.load(url: urlBackgroundGame)
        if detailInventory?.data?.countdown_off?.value != 0 && detailInventory?.data?.countdown_off?.value != nil {
            offView.isHidden = false
            self.counter = detailInventory?.data?.countdown_off?.value ?? 0
            self.offLabel.text = "\(counter)"
        } else {
            offView.isHidden = true
        }
    }
    
    @objc func updateCounter() {
        //example functionality
        if counter > 0 {
            counter -= 1
            self.offLabel.text = "\(counter)"
            if counter == 0 {
                gameTimer?.invalidate()
                offView.isHidden = true
            }
        }
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        SwiftMessages.hide()
    }
    
    @IBAction func ActionCTA(_ sender: Any) {
        Storage.getCtaAction?(dataInventory)
    }
}
