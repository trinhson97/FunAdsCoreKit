//
//  AdsDropDownHorizontalView.swift
//  Ads_ios_demo
//
//  Created by IT on 2/19/21.
//

import UIKit

class AdsDropDownVerticalView: BaseView {

    @IBOutlet weak var countDownView: CircularProgressView! {
        didSet{
            countDownView.layer.backgroundColor = UIColor(hex: "#646464")?.cgColor
            countDownView.clipsToBounds = true
        }
        
        
    }
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
    @IBOutlet weak var countDownLabek: UILabel!
    @IBOutlet weak var iconGameImage: UIImageView!{
        didSet {
            iconGameImage.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var descriptionGameLabel: UILabel!
    @IBOutlet weak var CtaLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var iconButton: UIImageView!
    var timeCountDown: Double?
    var url: String?
    var counter = 0
    var count = 0
    var gameTimer: Timer?
    var gameTimers: Timer?
    var data: DetailInventory?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    override func draw(_ rect: CGRect) {
        bgAdsView.configureDropShadow()
        gameTimer?.invalidate()
        settingCountDownView(timeCountDown ?? 0)
        if let datas = self.data {
            if let isClose = datas.data?.countdown_off?.do_show_close {
                if isClose {
                    self.iconButton.isHidden = true
                    self.closeButton.isHidden = true
                    gameTimers?.invalidate()
                    gameTimers =  Timer.scheduledTimer(timeInterval: TimeInterval(self.count), target: self, selector: #selector(updateCounters), userInfo: nil, repeats: false)
                }else {
                    self.iconButton.isHidden = true
                    self.closeButton.isHidden = true
                }
            }
        }
    }
    
    @objc func updateCounters() {
        //example functionality
        self.iconButton.isHidden = false
        self.closeButton.isHidden = false

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func settingCountDownView(_ time: Double) {
        self.counter = Int(time)
        countDownView.trackColor = UIColor.clear
        countDownView.progressColor = UIColor(hex: "#FFC61B") ?? .orange
        self.countDownLabek.text = "\(Int(self.counter))"
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        countDownView.setProgressWithAnimation(duration: TimeInterval(time + 0.5), value: 0)
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.data = detailInventory
        self.count = detailInventory?.data?.countdown_off?.value ?? 0
        guard let url = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        iconGameImage.load(url: url)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        timeCountDown = Double(detailInventory?.data?.countdown_off?.value ?? 0)
        CtaLabel.text = detailInventory?.data?.metaData?.cta0?.label ?? ""
        self.url = detailInventory?.data?.metaData?.cta0?.link
    }

    @objc func updateCounter() {
        //example functionality
        if counter > 0 {
            counter -= 1
            self.countDownLabek.text = "\(counter)"
            if counter == 0 {
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (time) in
                    self.gameTimer?.invalidate()
                    self.countDownLabek.isHidden = true
                    self.countDownView.isHidden = true
                }
            }
        }
    }
    
    @IBAction func close(_ sender: Any) {
        SwiftMessages.hide()
    }
    @IBAction func CTA(_ sender: Any) {
        Storage.getCtaAction?(data ?? DetailInventory())
    }
    @IBAction func ActionCTA(_ sender: Any) {
        BLog("CTA")
        Storage.getCtaAction?(data ?? DetailInventory())
    }
}
