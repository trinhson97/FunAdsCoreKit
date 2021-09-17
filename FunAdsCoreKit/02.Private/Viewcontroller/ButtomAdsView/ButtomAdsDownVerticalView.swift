

import UIKit

class ButtomAdsDownVerticalView: MessageView {
    @IBOutlet weak var bannerGameView: UIImageView!
    
    @IBOutlet weak var bgDownloadView: UIView! {
        didSet {
            bgDownloadView.layer.cornerRadius = 8
            bgDownloadView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor
        }
    }
    @IBOutlet weak var iconGameImage: UIImageView! {
        didSet {
            iconGameImage.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var bgButtonDownload: UIView! {
        didSet {
            bgButtonDownload.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var offView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var descriptionGameLabel: UILabel!
    @IBOutlet weak var ButtonLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        gameTimer?.invalidate()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    var url: String?
    var gameTimer: Timer?
    var counter = 0
    var timeCountDown = 0.0
    var data = DetailInventory()
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.data = detailInventory ?? DetailInventory()
        guard let urlAvatarGameImage = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        guard let urlBackgroundGame = URL(string: detailInventory?.data?.metaData?.imageBanner?.data ?? "") else { return }
        iconGameImage.load(url: urlAvatarGameImage)
        bannerGameView.load(url: urlBackgroundGame)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        if detailInventory?.data?.metaData?.cta0?.label == "" || detailInventory?.data?.metaData?.cta0?.label == nil {
            ButtonLabel.isHidden = true
        }else {
            ButtonLabel.isHidden = false
            ButtonLabel.text = detailInventory?.data?.metaData?.cta0?.label
        }
        self.url = detailInventory?.data?.metaData?.cta0?.link
        if detailInventory?.data?.countdown_off?.value != 0 && detailInventory?.data?.countdown_off?.value != nil {
            offView.isHidden = false
            self.counter = detailInventory?.data?.countdown_off?.value ?? 0
            self.offLabel.text = "\(counter)"
        }else {
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
        Storage.getCtaAction?(data)
    }
}
