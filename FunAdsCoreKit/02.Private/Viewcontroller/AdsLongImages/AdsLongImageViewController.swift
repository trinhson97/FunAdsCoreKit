
import UIKit

class AdsLongImageViewController: UIViewController {

    @IBOutlet weak var iconGameImage: UIImageView! {
        didSet {
            iconGameImage.layer.cornerRadius = 19
        }
    }
    @IBOutlet weak var nameGameLabel: UILabel!
    @IBOutlet weak var descriptionGameLabel: UILabel!
    @IBOutlet weak var longImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var icong: UIImageView!{
        didSet {
            icong.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var namel: UILabel!
    @IBOutlet weak var dlbel: UILabel!
    @IBOutlet weak var viePiwar: UIView!
    @IBOutlet weak var imgBanner: UIImageView!
    @IBOutlet weak var heightImage: NSLayoutConstraint!
    @IBOutlet weak var cta1Label: UILabel!
    @IBOutlet weak var ctaL: UILabel!
    
    @IBOutlet weak var bt1: UIImageView!
    @IBOutlet weak var bt2: UIButton!
    @IBOutlet weak var bt2CLose: UIImageView!
    
    var detailInven: DetailInventory?
    var urlLongImage: String?
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        // Do any additional setup after loading the view.
        loadData(detailInven)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        guard let urlLongImage = URL(string: urlLongImage ?? "") else { return }
//        heightImage.constant = CGFloat(sizeOfImageAt(url: urlLongImage)?.height ?? 0)
    }
    
    func showAds() {
        UIApplication.topViewController()?.presentInFullScreen(self, animated: true, completion: nil)
    }

    func loadData(_ detailInventory: DetailInventory?) {
        self.detailInven = detailInventory
        guard let url = URL(string: detailInventory?.data?.metaData?.logoImage?.data ?? "") else { return }
        guard let urlBanner = URL(string: detailInventory?.data?.metaData?.imageBanner?.data ?? "") else { return }
        guard let urlLongImage = URL(string: detailInventory?.data?.metaData?.image?.data ?? "") else { return }
        self.url = detailInventory?.data?.metaData?.cta0?.link
        imgBanner.load(url: urlBanner)
        descriptionGameLabel.text = detailInventory?.data?.metaData?.shortDescription?.data
        dlbel.text = detailInventory?.data?.metaData?.shortDescription?.data
        nameGameLabel.text = detailInventory?.data?.metaData?.shortTitle?.data
        namel.text = detailInventory?.data?.metaData?.shortTitle?.data
        cta1Label.text = detailInventory?.data?.metaData?.cta0?.label
        ctaL.text = detailInventory?.data?.metaData?.cta0?.label
        heightImage.constant = CGFloat((sizeOfImageAt(url: urlLongImage)?.height ?? 0))
        iconGameImage.load(url: url)
        icong.load(url: url)
        longImage.load(url: urlLongImage)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func ActionCta(_ sender: Any) {
        Storage.getCtaAction?(detailInven ?? DetailInventory())
    }
    
    @IBAction func ActionClose(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
extension AdsLongImageViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        let currentBottomY = scrollView.frame.size.height + currentY
        if currentBottomY == scrollView.contentSize.height + scrollView.contentInset.bottom {
            self.viePiwar.isHidden = true
        }else {
            self.viePiwar.isHidden = false
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.viePiwar.isHidden = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        if currentY >= 420 {
            self.bt2CLose.isHidden = false
            self.bt2.isHidden = false
            self.bt1.isHidden = true
        }else {
            self.bt2CLose.isHidden = true
            self.bt2.isHidden = true
            self.bt1.isHidden = false
        }
    }
}
