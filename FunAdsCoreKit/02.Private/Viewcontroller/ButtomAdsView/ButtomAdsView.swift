
import UIKit

class ButtomAdsView: MessageView {
    
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var descriptionGameLabel: UILabel!
   
    @IBOutlet weak var offView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var avatarGameImage: UIImageView! {
        didSet {
            avatarGameImage.layer.cornerRadius = 19
        }
    }
    
    @IBOutlet weak var backgroundDowloadButton: UIView! {
        didSet {
            backgroundDowloadButton.layer.cornerRadius = 4
        }
    }
    @IBOutlet weak var backgroundGameImage: UIImageView!
    @IBOutlet weak var ButtonLabel: UILabel!
    
    @IBOutlet weak var backgroundImageGameView: UIView! {
        didSet {
            backgroundImageGameView.layer.cornerRadius = 4
            backgroundImageGameView.layer.borderWidth = 1
            backgroundImageGameView.layer.borderColor = UIColor(red: 0.898, green: 0.898, blue: 0.918, alpha: 1).cgColor
            backgroundImageGameView.clipsToBounds = true
        }
    }
    
    var url: String?
    var gameTimer: Timer?
    var counter = 0
    var timeCountDown = 0.0
    var data = DetailInventory()
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        gameTimer?.invalidate()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.data = detailInventory ?? DetailInventory()
        guard let urlAvatarGameImage = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        guard let urlBackgroundGame = URL(string: detailInventory?.data?.metaData?.imageBanner?.data ?? "") else { return }
        avatarGameImage.load(url: urlAvatarGameImage)
        backgroundGameImage.load(url: urlBackgroundGame)
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
        
    @IBAction func ActionDowloadGame(_ sender: Any) {
        Storage.getCtaAction?(data)
    }
}
