//
//  AdsIOSControl.swift
//  FunAdsCoreKit
//
//  Created by IT on 4/13/21.
//

import Foundation
import UIKit

@objc public class AdsIOSControl: NSObject {
    @objc public class func showAdsSDK(code: String, id: Int) {
        Storage.inventory_id = "\(id)"
        Storage.inventory_code = code
        APIManage.shared.getinventory(code: code) { (status, DetailInventory) in
            if status != false {
                if DetailInventory.data == nil || DetailInventory.code == 1001 {
                    BLog(DetailInventory.message ?? "")
                }
                Storage.raa_id = "\(DetailInventory.data?.raa_id ?? 0)"
                Storage.params_tracking = DetailInventory.data?.params_tracking ?? ""
                Storage.tracking_view_url = DetailInventory.data?.tracking_view_url ?? ""
                if DetailInventory.data?.templateType == "popup-dropdown" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    if UIApplication.shared.statusBarOrientation.isPortrait {
                        self.showAdsDropDownAndBanner(isDropDown: true, DetailInventory)
                    }else {
                        self.showAdsDropDownVertical(DetailInventory)
                    }
                }else if DetailInventory.data?.templateType?.contains("inline") == true{
                    if DetailInventory.data?.templateType?.contains("dashboard") == true {
                        return
                    }
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    if DetailInventory.data?.templateType == "inline-blur" {
                        self.showAdsDropDownAndInline(isDropDown: false, DetailInventory)
                    }else {
                        self.showAdsDropDownAndBanner(isDropDown: false, DetailInventory)
                    }
                }else if DetailInventory.data?.templateType?.contains("videos") == true {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    if UIApplication.shared.statusBarOrientation.isPortrait {
                        self.showVideoAds(DetailInventory)
                    }else {
                        self.showVideoAdsHorizontal(DetailInventory)
                    }
                }else if DetailInventory.data?.templateType == "only_image" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    self.showOnlyImageAds(DetailInventory)
                }else if DetailInventory.data?.templateType == "banner-call-action" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    if UIApplication.shared.statusBarOrientation.isPortrait {
                        self.showPopupButtomAds(DetailInventory)
                    }else {
                        self.showPopupButtomAdsHorizontal(DetailInventory)
                    }
                }else if DetailInventory.data?.templateType == "popup-dropdown-text" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    self.showAdsDropdownText(data: DetailInventory, Double(DetailInventory.data?.countdown_off?.value ?? 0))
                }else if DetailInventory.data?.templateType == "reward" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    self.showRewadView(DetailInventory)
                }else if DetailInventory.data?.templateType == "reward-video" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    if UIApplication.shared.statusBarOrientation.isPortrait {
                        self.showRewadsAds(DetailInventory)
                    }else {
                        self.showRewadsAdsHorizontal(DetailInventory)
                    }
                }else if DetailInventory.data?.templateType == "long-images" {
                    self.trackingView(raa_id: Storage.raa_id, inventory_id: "\(id)", inventory_code: code)
                    self.showPopupCountDown(Double(DetailInventory.data?.countdown?.value ?? 0))
                    Timer.scheduledTimer(withTimeInterval: Double(DetailInventory.data?.countdown?.value ?? 0), repeats: false) { (timer) in
                        if UIApplication.shared.statusBarOrientation.isPortrait {
                            self.showAdsLongImage(DetailInventory)
                        }else {
                            self.showAdsLongImageH(DetailInventory)
                        }
                    }
                }
            }
        }
    }
    
    @objc public class func openUrl(url : String) {
        if let url = URL(string: "\(url)") {
            UIApplication.shared.open(url)
        }
    }

    //MARk: Tracking view
    private class func trackingView(raa_id: String?, inventory_id: String?, inventory_code: String?) {
        APIManage.shared.trackingAds(raa_id: "\(raa_id ?? "")", inventory_id: "\(inventory_id ?? "")", inventory_code: "\(inventory_code ?? "")") {
            BLog("Done Tracking")
        }
    }

    // MARK: Count down
    class func showPopupCountDown(_ timeCountDown: Double) {
        if timeCountDown == 0 {
            return
        }
        let view: PopupCountDown = try! SwiftMessages.viewFromNib()
        let messageView = BaseView(frame: .zero)
        view.backgroundHeight = 25
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            if UIApplication.shared.statusBarOrientation.isPortrait {
                messageView.installBackgroundView(backgroundView)
                messageView.layoutMarginAdditions = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10)
            }else{
                messageView.installBackgroundVerticalView(backgroundView, insets: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 10))
            }
            messageView.installContentView(view)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
        config.duration = .forever
        config.presentationStyle = .top
        config.interactiveHide = false
        config.dimMode = .none
        view.timeCountDown = timeCountDown
        SwiftMessages.show(config: config, view: messageView)
    }
    
    // MARK: Control Only Image
    private class func showOnlyImageAds(_ detailInventory: DetailInventory?) {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            let view: AdsOnyImage = try! SwiftMessages.viewFromNib()
            view.loadData(detailInventory)
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
            config.duration = .forever
            config.presentationStyle = .center
            config.interactiveHide = false
            config.dimMode = .gray(interactive: false)
            let messageView = BaseView(frame: .zero)
            view.backgroundHeight = UIScreen.main.bounds.size.width - 30
            do {
                let backgroundView = CornerRoundingView()
                messageView.installBackgroundView(backgroundView)
                messageView.installContentView(view)
                messageView.layoutMarginAdditions = UIEdgeInsets(top: 38, left: 15, bottom: 0, right: 15)
            }
            Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
                SwiftMessages.show(config: config, view: messageView)
            }
        }else {
            let view: AdsOnlyImageVerticalView = try! SwiftMessages.viewFromNib()
            view.loadData(detailInventory)
            var config = SwiftMessages.defaultConfig
            config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
            config.duration = .forever
            config.presentationStyle = .center
            config.interactiveHide = false
            config.dimMode = .gray(interactive: false)
            let messageView = BaseView(frame: .zero)
            do {
                let backgroundView = CornerRoundingView()
                messageView.installBackgroundVerticalViewImage(backgroundView)
                messageView.installContentView(view)
                messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 32)
            }
            Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
                SwiftMessages.show(config: config, view: messageView)
            }
        }
    }
    
    //MARK: Control Long Image
    
    private class func showAdsLongImage(_ detailInventory: DetailInventory?) {
        let ctrl = AdsLongImageViewController.loadFromNib()
        ctrl.detailInven = detailInventory
        ctrl.showAds()
    }
    
    private class func showAdsLongImageH(_ detailInventory: DetailInventory?) {
        let ctrl = AdsLongImageVerticalViewController.loadFromNib()
        ctrl.detailInven = detailInventory
        ctrl.showAds()
    }
    
    // MARK: Control Rewads Ads
    
    class func showRewadView(_ detailInventory: DetailInventory?) {
        let view: RewardView = try! SwiftMessages.viewFromNib()
        view.loadData(detailInventory)
        let messageView = BaseView(frame: .zero)
        do {
            let backgroundView = CornerRoundingView()
            messageView.installBackgroundVerticalView(backgroundView, insets: UIEdgeInsets(top: 50, left: 30, bottom: 0, right: 30))
            messageView.installContentView(view)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .top
        config.interactiveHide = false
        config.dimMode = .none
        SwiftMessages.show(config: config, view: messageView)
    }
    
    class func showRewadsAdsHorizontal(_ detailInventory: DetailInventory?) {
        let view: RewarAdsVertical = try! SwiftMessages.viewFromNib()
        view.loadDataAds(detailInventory)
        let messageView = BaseView(frame: .zero)
        do {
            messageView.installContentViewReward(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    class func showRewadsAds(_ detailInventory: DetailInventory?) {
        let view: RewardsAds = try! SwiftMessages.viewFromNib()
        view.loadDataAds(detailInventory)
        let messageView = BaseView(frame: .zero)
        do {
            messageView.installContentViewReward(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    // MARK:  Control Ads Dropdown Text
    
    private class func showAdsDropdownText(data: DetailInventory? ,_ timeCountDown: Double) {
        let view: AdsDropDownText = try! SwiftMessages.viewFromNib()
        let messageView = BaseView(frame: .zero)
        view.backgroundHeight = 30
        view.data = data
        view.text = data?.data?.metaData?.longTitle?.data ?? ""
        view.countDown = timeCountDown
        do {
            let backgroundView = CornerRoundingView()
            messageView.installBackgroundView(backgroundView, insets: UIEdgeInsets(top: 70, left: 0, bottom: 0, right: 0))
            messageView.installContentView(view)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.presentationStyle = .top
        config.interactiveHide = false
        config.dimMode = .none
        config.duration = .seconds(seconds: timeCountDown)
        SwiftMessages.show(config: config, view: messageView)
    }
    
    // MARK: Control Video Ads
    
    private class func showVideoAds(_ detailInventory: DetailInventory?) {
        let view: AdsVideoView = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.loadDataAds(detailInventory)
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 31, bottom: 0, right: 31)
        }
        messageView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    private class func showVideoAdsHorizontal(_ detailInventory: DetailInventory?) {
        let view: AdsVideoViewVertical = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.loadDataAds(detailInventory)
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 63, bottom: 0, right: 0)
        }
        messageView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    // MARK: Control Popup Buttom Ads
    
    private class func showPopupButtomAds(_ detailInventory: DetailInventory?) {
        let view: ButtomAdsView = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.loadData(detailInventory)
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        messageView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    private class func showPopupButtomAdsHorizontal(_ detailInventory: DetailInventory?) {
        let view: ButtomAdsDownVerticalView = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.loadData(detailInventory)
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 0, left: 78, bottom: 0, right: 0)
        }
        messageView.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.duration = .forever
        config.presentationStyle = .center
        config.interactiveHide = false
        config.dimMode = .gray(interactive: false)
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    // MARK: Control Ads Drop Down
    
    private class func showAdsDropDownAndBanner(isDropDown: Bool ,_ detailInventory: DetailInventory?) {
        let view: AdsDropDownView = try! SwiftMessages.viewFromNib()
        view.loadData(detailInventory)
        view.backgroundHeight = 71
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 30, left: 5, bottom: 10, right: 5)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.interactiveHide = false
        config.dimMode = .none
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            if isDropDown {
                config.presentationStyle = .top
            }else {
                config.presentationStyle = .bottom
            }
            if let closeButton = detailInventory?.data?.countdown_off?.do_show_close{
                if closeButton {
                    config.duration = .forever
                }else {
                    config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
                }
            }else {
                config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
            }
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    private class func showAdsDropDownAndInline(isDropDown: Bool ,_ detailInventory: DetailInventory?) {
        let view: AdsWhire = try! SwiftMessages.viewFromNib()
        view.loadData(detailInventory)
        view.backgroundHeight = 71
        // config layout
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 30, left: 5, bottom: 10, right: 5)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.interactiveHide = false
        config.dimMode = .none
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            if isDropDown {
                config.presentationStyle = .top
            }else {
                config.presentationStyle = .bottom
            }
            if let closeButton = detailInventory?.data?.countdown_off?.do_show_close{
                if closeButton {
                    config.duration = .forever
                }else {
                    config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
                }
            }else {
                config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
            }
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    private class func showAdsDropDownVertical(_ detailInventory: DetailInventory?) {
        let view: AdsDropDownVerticalView = try! SwiftMessages.viewFromNib()
        view.loadData(detailInventory)
        view.backgroundHeight = 71
        // config layout
        let messageView = BaseView(frame: .zero)
        messageView.layoutMargins = .zero
        do {
            let backgroundView = CornerRoundingView()
            backgroundView.layer.masksToBounds = true
            messageView.installBackgroundView(backgroundView)
            messageView.installContentView(view)
            messageView.layoutMarginAdditions = UIEdgeInsets(top: 6, left: 0, bottom: 0, right: 0)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindow.Level.normal)
        config.presentationStyle = .top
        config.interactiveHide = false
        config.dimMode = .none
        Timer.scheduledTimer(withTimeInterval: Double(detailInventory?.data?.countdown?.value ?? 0), repeats: false) { timer in
            if let closeButton = detailInventory?.data?.countdown_off?.do_show_close{
                if closeButton {
                    config.duration = .forever
                }else {
                    config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
                }
            }else {
                config.duration = .seconds(seconds: Double(detailInventory?.data?.countdown_off?.value ?? 0))
            }
            SwiftMessages.show(config: config, view: messageView)
        }
    }
}
