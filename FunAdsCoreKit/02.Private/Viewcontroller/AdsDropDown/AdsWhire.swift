//
//  AdsWhire.swift
//  AdsIOSSDK
//
//  Created by IT on 4/14/21.
//

import UIKit

class AdsWhire: BaseView {

    @IBOutlet weak var ImageIcon: UIImageView! {
        didSet {
            ImageIcon.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var iconButton: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dLabel: UILabel!
    @IBOutlet weak var ctaLabel: UILabel!
    var count: Double?
    var gameTimer: Timer?
    var url: String?
    var data = DetailInventory()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    
    override func draw(_ rect: CGRect) {
        if self.count ?? 0 <= 0{
            self.iconButton.isHidden = false
            self.closeButton.isHidden = false
        }else{
            self.iconButton.isHidden = true
            self.closeButton.isHidden = true
            gameTimer?.invalidate()
            gameTimer =  Timer.scheduledTimer(timeInterval: self.count ?? 0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: false)
        }
    }
    
    @objc func updateCounter() {
        //example functionality
        self.iconButton.isHidden = false
        self.closeButton.isHidden = false

    }
    
    @IBAction func ActionCloé(_ sender: Any) {
        SwiftMessages.hide()
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.data = detailInventory ?? DetailInventory()
        self.count = Double(detailInventory?.data?.countdown_off?.value ?? 0)
        guard let url = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        ImageIcon.load(url: url)
        dLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        self.url = detailInventory?.data?.metaData?.cta0?.link
        ctaLabel.text = detailInventory?.data?.metaData?.cta0?.label ?? ""
    }

    @IBAction func cta(_ sender: Any) {
        Storage.getCtaAction?(data)
    }
}
