//
//  RewardsAdsVView.swift
//  FunAdsCoreKit
//
//  Created by IT on 3/2/21.
//

import UIKit

class RewardsAds: MessageView {
    
    @IBOutlet weak var iconGameImage: UIImageView! {
        didSet {
            iconGameImage.layer.cornerRadius = 10
            iconGameImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var iconGameWhenEndVideoImage: UIImageView! {
        didSet {
            iconGameWhenEndVideoImage.layer.cornerRadius = 19
            iconGameWhenEndVideoImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var CircularProgressView: CircularProgressRewardView! {
        didSet {
            CircularProgressView.clipsToBounds = true
        }
    }
    
    @IBOutlet var replayVideoView: UIView!
    @IBOutlet weak var cta1Label: UILabel!
    @IBOutlet weak var cta2Label: UILabel!
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var nameGameReplayLabel: UILabel!
    
    @IBOutlet weak var descriptionGameLabel: UILabel!
    @IBOutlet weak var descriptionGameReplayLabel: UILabel!
    @IBOutlet weak var videoView: VideoView!

    @IBOutlet weak var djdfhskdjfhskjdfhds: UIView!
    @IBOutlet weak var confirmLabel: UILabel!
    @IBOutlet weak var pauseImage: UIImageView!
    @IBOutlet weak var PlayImage: UIImageView!

    var isPause: Bool = true
    var isFirst: Bool = true
    var url: String?
    var counter = 0
    var gameTimer: Timer?
    var urlVideo: String?
    var timer: Double?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        videoView.delegate = self
        if isFirst {
            videoView.play()
            isFirst = false
        }
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.videoView.addGestureRecognizer(gesture)
        CircularProgressView.trackColor = UIColor(hex: "#FFC61B") ?? .orange
        CircularProgressView.progressColor = UIColor.black
        CircularProgressView.setProgressWithAnimation(duration: timer ?? 0, value: 0)
        Timer.scheduledTimer(withTimeInterval: timer ?? 0, repeats: false) { (timer) in
            self.CircularProgressView.isHidden = true
        }
    }
    
    func loadDataAds(_ detailInventory: DetailInventory?) {
        guard let urlImage = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        cta1Label.text = detailInventory?.data?.metaData?.cta0?.label ?? ""
        cta2Label.text = detailInventory?.data?.metaData?.cta0?.label ?? ""
        iconGameImage.load(url: urlImage)
        iconGameWhenEndVideoImage.load(url: urlImage)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        descriptionGameReplayLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameReplayLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        self.url = detailInventory?.data?.metaData?.cta0?.link
        self.urlVideo = detailInventory?.data?.metaData?.video?.data ?? ""
        self.counter = Int(detailInventory?.data?.metaData?.waitingTime?.data ?? "") ?? 0
        self.timer = Double((detailInventory?.data?.countdown_off?.value ?? 0)+1)
        loadVideo(url: urlVideo ?? "")
        videoView.stop()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func getTimeLabel() -> NSMutableAttributedString {
        var str = "Xem thêm "
        str += "\(counter)s để nhận phần quà hấp dẫn "
        let range = str.range(of: "\(counter)s")
        let attribute = NSMutableAttributedString(string: str)
        attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: "#EE4623") ?? .red , range: str.nsRange(from: range!))
        return attribute
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        if isPause {
            self.isPause = false
            self.pauseImage.isHidden = false
            gameTimer?.invalidate()
            videoView.pause()
        }else {
            self.isPause = true
            self.pauseImage.isHidden = true
            self.PlayImage.isHidden = false
            counter -= 1
            self.countDownLabel.text = "Nhận quà sau: " + "\(counter)s"
            gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.myPerformeCode), userInfo: nil, repeats: false)
            videoView.play()
        }
    }
    
    func loadVideo(url: String) {
        guard let urlVideo = URL(string: url ) else { return }
        videoView.setItem(urlVideo)
        videoView.isLoop = false
    }
    
    @objc func myPerformeCode() {
        PlayImage.isHidden = true
    }
    
    @objc func updateCounter() {
        if counter > 0 {
            print("\(counter) seconds to the end of the world")
            counter -= 1
            self.countDownLabel.text = "Nhận quà sau: " + "\(counter)s"
            if counter == 0 {
                gameTimer?.invalidate()
            }
        }
    }
    
    @IBOutlet weak var turnOffButton: UIButton!
    @IBAction func turnOffVolum(_ sender: Any) {
        videoView.turnOnVolun()
        turnOnButton.isHidden = false
    }
    
    @IBOutlet weak var turnOnButton: UIButton!
    @IBAction func turnOnVolum(_ sender: Any) {
        videoView.turnOffVolum()
        turnOnButton.isHidden = true
    }
    
    @IBAction func ActionTurnAds(_ sender: Any) {
        videoView.pause()
        SwiftMessages.hide()
    }
    @IBAction func ActionCTA(_ sender: Any) {
        if let url = URL(string: "\(url ?? "")") {
            self.isPause = false
            self.pauseImage.isHidden = false
            gameTimer?.invalidate()
            videoView.pause()
            UIApplication.shared.open(url)
        }
    }
    @IBAction func ActionClose2(_ sender: Any) {
        let trackingAdsParam = TTrackingAdss(event_id: Storage.even_id)
        APIManage.shared.trackingRewardAds(trackingAdsParam: trackingAdsParam) { (status, detail) in
            self.videoView.pause()
            SwiftMessages.hide()
            if status == true && detail.success == true {
                let view: RewardSuccessView = try! SwiftMessages.viewFromNib()
                view.loadData(detail.data?.detail ?? "")
                let messageView = BaseView(frame: .zero)
                do {
                    messageView.installContentView(view)
                    messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                var config = SwiftMessages.defaultConfig
                config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
                config.duration = .forever
                config.presentationStyle = .center
                config.interactiveHide = false
                config.dimMode = .gray(interactive: false)
                SwiftMessages.show(config: config, view: messageView)
            }else {
                let view: RewardErrorView = try! SwiftMessages.viewFromNib()
                view.loađata(detail.message ?? "", detail.data?.detail ?? "")
                let messageView = BaseView(frame: .zero)
                do {
                    messageView.installContentView(view)
                    messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }
                var config = SwiftMessages.defaultConfig
                config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
                config.duration = .forever
                config.presentationStyle = .center
                config.interactiveHide = false
                config.dimMode = .gray(interactive: false)
                SwiftMessages.show(config: config, view: messageView)
            }
        }
    }
    @IBAction func ActionNext(_ sender: Any) {
        self.isPause = true
        djdfhskdjfhskjdfhds.isHidden = true
        self.countDownLabel.text = "Nhận quà sau: " + "\(counter)s"
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.myPerformeCode), userInfo: nil, repeats: false)
        videoView.play()
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        if self.counter > 0 {
            djdfhskdjfhskjdfhds.isHidden = false
            self.confirmLabel.attributedText = self.getTimeLabel()
            self.isPause = false
            videoView.pause()
            gameTimer?.invalidate()
        }else {
            videoView.pause()
            SwiftMessages.hide()
        }
    }
    
}
extension RewardsAds: VideoViewDelegate {
    func runTheEndOfTheVideo() {
        self.replayVideoView.tag = 1002
        self.replayVideoView.frame = CGRect(x: 0, y: 0, width: Int(self.frame.width), height: Int(self.frame.height))
        self.addSubview(replayVideoView)
    }
}
