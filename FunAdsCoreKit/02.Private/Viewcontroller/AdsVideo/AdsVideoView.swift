
import UIKit

class AdsVideoView: MessageView {

    @IBOutlet weak var iconGameImage: UIImageView! {
        didSet {
            iconGameImage.layer.cornerRadius = 19
            iconGameImage.clipsToBounds = true
        }
    }
    @IBOutlet weak var bgButtonDownload: UIView! {
        didSet {
            bgButtonDownload.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var ButtonLabel: UILabel!
    
    @IBOutlet weak var offView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    
    var isPause: Bool = true
    var url: String?
    var urlVideo: String?
    var gameTimer: Timer?
    var counter = 0
    var timeCountDown = 0.0
    var data = DetailInventory()
    
    @IBOutlet weak var nameGameLabel: UILabel!
    
    @IBOutlet weak var descriptionGameLabel: UILabel!
    @IBOutlet weak var videoView: VideoView! {
        didSet {
            videoView.layer.cornerRadius = 4
            videoView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var pauseImage: UIImageView!
    @IBOutlet weak var PlayImage: UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    */
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        videoView.delegate = self
        videoView.play()
        let gesture = UITapGestureRecognizer(target: self, action:  #selector(self.checkAction))
        self.videoView.addGestureRecognizer(gesture)
        gameTimer?.invalidate()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func loadDataAds(_ detailInventory: DetailInventory?) {
        self.data = detailInventory ?? DetailInventory()
        guard let urlImage = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        iconGameImage.load(url: urlImage)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        self.url = detailInventory?.data?.metaData?.cta0?.link
        self.urlVideo = detailInventory?.data?.metaData?.video?.data
        if detailInventory?.data?.metaData?.cta0?.label == "" || detailInventory?.data?.metaData?.cta0?.label == nil {
            ButtonLabel.isHidden = true
        }else {
            ButtonLabel.isHidden = false
            ButtonLabel.text = detailInventory?.data?.metaData?.cta0?.label
        }
        loadVideo(url: self.urlVideo ?? "")
        videoView.stop()
        if detailInventory?.data?.countdown_off?.value != 0 && detailInventory?.data?.countdown_off?.value != nil {
            offView.isHidden = false
            self.counter = detailInventory?.data?.countdown_off?.value ?? 0
            self.offLabel.text = "\(counter)"
        }else {
            offView.isHidden = true
        }
    }
    
    func loadVideo(url: String) {
        guard let urlVideo = URL(string: url ) else { return }
        videoView.setItem(urlVideo)
        videoView.isLoop = false
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
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        if isPause {
            self.isPause = false
            pauseImage.isHidden = false
            PlayImage.isHidden = true
            videoView.pause()
        }else {
            self.isPause = true
            pauseImage.isHidden = true
            PlayImage.isHidden = false
            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.myPerformeCode), userInfo: nil, repeats: false)
            videoView.play()
        }
    }
    
    @objc func myPerformeCode() {
        PlayImage.isHidden = true
    }
    @IBAction func CTA(_ sender: Any) {
        Storage.getCtaAction?(data)
    }
    
    @IBAction func ActionCTA(_ sender: Any) {
        Storage.getCtaAction?(data)
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        self.videoView.pause()
        SwiftMessages.hide()
    }
}
//extension AdsVideoView: VideoViewDelegate {
//    func endVideo() {
//        self.videoView.reset()
//        self.isPause = true
//        pauseImage.isHidden = true
//        PlayImage.isHidden = false
//    }
//}
extension AdsVideoView: VideoViewDelegate {
    func runTheEndOfTheVideo() {
        self.videoView.reset()
        self.isPause = true
        pauseImage.isHidden = true
        PlayImage.isHidden = false
    }
}
