
import UIKit

class AdsLongImageVerticalViewController: UIViewController {
    
    @IBOutlet weak var iconGameImage: UIImageView! {
        didSet {
            iconGameImage.layer.cornerRadius = 19
        }
    }
    
    @IBOutlet weak var dLb: UILabel!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet var longImg: UIImageView!
    @IBOutlet weak var imgBanner: UIImageView!
    
    @IBOutlet var heightImg: NSLayoutConstraint!
    @IBOutlet weak var scollView: UIScrollView!
    @IBOutlet weak var cta1Label: UILabel!
    @IBOutlet weak var vddImage: UIImageView!
    
    var detailInven: DetailInventory?
    var urlLongImage: String?
    var url: String?
    var PiWarLast: CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scollView.delegate = self
        loadData(detailInven)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let urlBanner = URL(string: detailInven?.data?.metaData?.imageBanner?.data ?? "") else { return }
        imgBanner.load(url: urlBanner)
        
    }
    
    func showAds() {
        UIApplication.topViewController()?.presentInFullScreen(self, animated: true, completion: nil)
    }
    
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.detailInven = detailInventory
        guard let url = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        guard let urlLongImage = URL(string: detailInventory?.data?.metaData?.image?.data ?? "") else { return }
        self.url = detailInventory?.data?.metaData?.cta0?.link
        dLb.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameLB.text = detailInventory?.data?.metaData?.shortTitle?.data
        cta1Label.text = detailInventory?.data?.metaData?.cta0?.label
        heightImg.constant = CGFloat((sizeOfImageAt(url: urlLongImage)?.height ?? 0))
        iconGameImage.load(url: url)
        longImg.load(url: urlLongImage)
    }
    
    func sizeOfImageAt(url: URL) -> CGSize? {
         // with CGImageSource we avoid loading the whole image into memory
         guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
             return nil
         }

         let propertiesOptions = [kCGImageSourceShouldCache: false] as CFDictionary
         guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, propertiesOptions) as? [CFString: Any] else {
             return nil
         }

         if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
             let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
             return CGSize(width: width, height: height)
         } else {
             return nil
         }
     }
    
    @IBAction func ActionCta(_ sender: Any) {
        Storage.getCtaAction?(detailInven ?? DetailInventory())
    }
    
    @IBAction func ActionCLose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
extension AdsLongImageVerticalViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        let currentBottomY = scrollView.frame.size.height + currentY
        if currentBottomY == scrollView.contentSize.height + scrollView.contentInset.bottom {
            self.vddImage.isHidden = true
        }else {
            self.vddImage.isHidden = false
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.vddImage.isHidden = true
    }
}
