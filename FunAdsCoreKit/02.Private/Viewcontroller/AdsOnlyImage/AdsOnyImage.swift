//
//  AdsOnyImage.swift
//  FunAdsCoreKit
//
//  Created by IT on 2/22/21.
//

import UIKit

class AdsOnyImage: MessageView {
    
    @IBOutlet weak var imageGame: UIImageView!
    
    @IBOutlet weak var offView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    var url: String = ""
    var gameTimer: Timer?
    var counter = 0
    var timeCountDown = 0.0
    var dataInventory = DetailInventory()
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        gameTimer?.invalidate()
        gameTimer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    func loadData(_ detailInventory: DetailInventory?) {
        self.dataInventory = detailInventory ?? DetailInventory()
        guard let urlBackgroundGame = URL(string: detailInventory?.data?.metaData?.imageBanner?.data ?? "") else { return }
        self.url = detailInventory?.data?.metaData?.cta0?.link ?? ""
        imageGame.load(url: urlBackgroundGame)
        if detailInventory?.data?.countdown_off?.value != 0 && detailInventory?.data?.countdown_off?.value != nil {
            offView.isHidden = false
            self.counter = detailInventory?.data?.countdown_off?.value ?? 0
            self.offLabel.text = "\(counter)"
        } else {
            offView.isHidden = true
        }
        self.backgroundHeight = self.getHeight(url: detailInventory?.data?.metaData?.imageBanner?.data ?? "")
    }
    
    func getHeight(url: String) -> CGFloat? {
        let urlBackgroundGame = URL(string: url)!
        return self.sizeOfImageAt(url: urlBackgroundGame)?.height
    }
    
    func sizeOfImageAt(url: URL) -> CGSize? {
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
        BLog("CTA")
        Storage.getCtaAction?(dataInventory)
    }
}
