//
//  AdsDropDownView.swift
//  Ads_ios_demo
//
//  Created by IT on 2/19/21.
//

import UIKit

class AdsDropDownView: BaseView {

    @IBOutlet weak var CtaButtom: UIButton! {
        didSet {
            CtaButtom.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var bgAdsView: MessageView! {
        didSet {
            bgAdsView.layer.cornerRadius = 8
            bgAdsView.clipsToBounds = true
        }
    }
    @IBOutlet weak var iconGameImage: UIImageView!{
        didSet {
            iconGameImage.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var iconButton: UIImageView!
    @IBOutlet weak var ctaLabel: UILabel!
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var descriptionGameLabel: UILabel!
    var url: String?
    var count: Double?
    var gameTimer: Timer?
    var data: DetailInventory?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    override func draw(_ rect: CGRect) {
        bgAdsView.configureDropShadow()
        if let datas = self.data {
            if let isClose = datas.data?.countdown_off?.do_show_close {
                if isClose {
                    self.iconButton.isHidden = true
                    self.closeButton.isHidden = true
                    gameTimer?.invalidate()
                    gameTimer =  Timer.scheduledTimer(timeInterval: self.count ?? 0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: false)
                }else {
                    self.iconButton.isHidden = true
                    self.closeButton.isHidden = true
                }
            }
        }
    }
    
    @objc func updateCounter() {
        //example functionality
        self.iconButton.isHidden = false
        self.closeButton.isHidden = false

    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.data = detailInventory
        self.count = Double(detailInventory?.data?.countdown_off?.value ?? 0)
        guard let url = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        iconGameImage.load(url: url)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        self.url = detailInventory?.data?.metaData?.cta0?.link
        ctaLabel.text = detailInventory?.data?.metaData?.cta0?.label ?? ""
    }

    @IBAction func ACT(_ sender: Any) {
        Storage.getCtaAction?(data ?? DetailInventory())
    }
    @IBAction func ActionCTA(_ sender: Any) {
        Storage.getCtaAction?(data ?? DetailInventory())
//        if let url = URL(string: "\(url ?? "")") {
//            UIApplication.shared.open(url)
//        }
    }
    @IBAction func ActionClose(_ sender: Any) {
        SwiftMessages.hide()
    }
    
}
