//
//  MarqueeLabel.swift
//
//  Created by Charles Powell on 8/6/14.
//  Copyright (c) 2015 Charles Powell. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable

open class MarqueeLabel: UILabel, CAAnimationDelegate {
    
    /**
     An enum that defines the types of `MarqueeLabel` scrolling
     
     - Left: Scrolls left after the specified delay, and does not return to the original position.
     - LeftRight: Scrolls left first, then back right to the original position.
     - Right: Scrolls right after the specified delay, and does not return to the original position.
     - RightLeft: Scrolls right first, then back left to the original position.
     - Continuous: Continuously scrolls left (with a pause at the original position if animationDelay is set).
     - ContinuousReverse: Continuously scrolls right (with a pause at the original position if animationDelay is set).
     */
    public enum MarqueeType {
        case left
        case leftRight
        case right
        case rightLeft
        case continuous
        case continuousReverse
    }

    open var type: MarqueeType = .continuous {
        didSet {
            if type == oldValue {
                return
            }
            updateAndScroll()
        }
    }
    
    open var scrollSequence: [MarqueeStep]?

    open var animationCurve: UIView.AnimationCurve = .linear
    
    @IBInspectable open var labelize: Bool = false {
        didSet {
            if labelize != oldValue {
                updateAndScroll()
            }
        }
    }

    @IBInspectable open var holdScrolling: Bool = false {
        didSet {
            if holdScrolling != oldValue {
                if oldValue == true && !(awayFromHome || labelize ) && labelShouldScroll() {
                    updateAndScroll()
                }
            }
        }
    }
    
    @IBInspectable open var tapToScroll: Bool = false {
        didSet {
            if tapToScroll != oldValue {
                if tapToScroll {
                    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(MarqueeLabel.labelWasTapped(_:)))
                    self.addGestureRecognizer(tapRecognizer)
                    isUserInteractionEnabled = true
                } else {
                    if let recognizer = self.gestureRecognizers!.first as UIGestureRecognizer? {
                        self.removeGestureRecognizer(recognizer)
                    }
                    isUserInteractionEnabled = false
                }
            }
        }
    }

    open var isPaused: Bool {
        return (sublabel.layer.speed == 0.0)
    }
    
    open var awayFromHome: Bool {
        if let presentationLayer = sublabel.layer.presentation() {
            return !(presentationLayer.position.x == homeLabelFrame.origin.x)
        }
        
        return false
    }

    public enum SpeedLimit {
        case rate(CGFloat)
        case duration(CGFloat)
        
        var value: CGFloat {
            switch self {
            case .rate(let rate):
                return rate
            case .duration(let duration):
                return duration
            }
        }
    }

    open var speed: SpeedLimit = .duration(7.0) {
        didSet {
            switch (speed, oldValue) {
            case (.rate(let a), .rate(let b)) where a == b:
                return
            case (.duration(let a), .duration(let b)) where a == b:
                return
            default:
                updateAndScroll()
            }
        }
    }
    
    @available(*, deprecated, message: "Use speed property instead")
    @IBInspectable open var scrollDuration: CGFloat {
        get {
            switch speed {
            case .duration(let duration): return duration
            case .rate(_): return 0.0
            }
        }
        set {
            speed = .duration(newValue)
        }
    }
    
    @available(*, deprecated, message : "Use speed property instead")
    @IBInspectable open var scrollRate: CGFloat {
        get {
            switch speed {
            case .duration(_): return 0.0
            case .rate(let rate): return rate
            }
        }
        set {
            speed = .rate(newValue)
        }
    }

    @IBInspectable open var leadingBuffer: CGFloat = 0.0 {
        didSet {
            if leadingBuffer != oldValue {
                updateAndScroll()
            }
        }
    }
  
    @IBInspectable open var trailingBuffer: CGFloat = 0.0 {
        didSet {
            if trailingBuffer != oldValue {
                updateAndScroll()
            }
        }
    }
    
    @IBInspectable open var fadeLength: CGFloat = 0.0 {
        didSet {
            if fadeLength != oldValue {
                applyGradientMask(fadeLength, animated: true)
                updateAndScroll()
            }
        }
    }
    
    @IBInspectable open var animationDelay: CGFloat = 1.0
    
    public var animationDuration: CGFloat {
        switch self.speed {
        case .rate(let rate):
            return CGFloat(abs(self.awayOffset) / rate)
        case .duration(let duration):
            return duration
        }
    }
 
    open class func restartLabelsOfController(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Restart)
    }
    
    open class func controllerViewWillAppear(_ controller: UIViewController) {
        MarqueeLabel.restartLabelsOfController(controller)
    }
    
    open class func controllerViewDidAppear(_ controller: UIViewController) {
        MarqueeLabel.restartLabelsOfController(controller)
    }
    
    open class func controllerLabelsLabelize(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Labelize)
    }
    
    open class func controllerLabelsAnimate(_ controller: UIViewController) {
        MarqueeLabel.notifyController(controller, message: .Animate)
    }

    public init(frame: CGRect, rate: CGFloat, fadeLength fade: CGFloat) {
        speed = .rate(rate)
        fadeLength = CGFloat(min(fade, frame.size.width/2.0))
        super.init(frame: frame)
        setup()
    }
    
    public init(frame: CGRect, duration: CGFloat, fadeLength fade: CGFloat) {
        speed = .duration(duration)
        fadeLength = CGFloat(min(fade, frame.size.width/2.0))
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    convenience public override init(frame: CGRect) {
        self.init(frame: frame, duration:7.0, fadeLength:0.0)
    }
    
    private func setup() {
        // Create sublabel
        sublabel = UILabel(frame: self.bounds)
        sublabel.tag = 700
        sublabel.layer.anchorPoint = CGPoint.zero

        // Add sublabel
        addSubview(sublabel)
        
        // Configure self
        super.clipsToBounds = true
        super.numberOfLines = 1
        
        // Add notification observers
        // Custom class notifications
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.restartForViewController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Restart.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.labelizeForController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Labelize.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.animateForController(_:)), name: NSNotification.Name(rawValue: MarqueeKeys.Animate.rawValue), object: nil)
        // UIApplication state notifications
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.restartLabel), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MarqueeLabel.shutdownLabel), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        forwardPropertiesToSublabel()
    }
    
    @available(iOS 8.0, *)
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        forwardPropertiesToSublabel()
    }
    
    private func forwardPropertiesToSublabel() {
        let properties = ["baselineAdjustment", "enabled", "highlighted", "highlightedTextColor",
                          "minimumFontSize", "shadowOffset", "textAlignment",
                          "userInteractionEnabled", "adjustsFontSizeToFitWidth",
                          "lineBreakMode", "numberOfLines", "contentMode"]
        
        // Iterate through properties
        sublabel.text = super.text
        sublabel.font = super.font
        sublabel.textColor = super.textColor
        sublabel.backgroundColor = super.backgroundColor ?? UIColor.clear
        sublabel.shadowColor = super.shadowColor
        sublabel.shadowOffset = super.shadowOffset
        for prop in properties {
            let value = super.value(forKey: prop)
            sublabel.setValue(value, forKeyPath: prop)
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        updateAndScroll()
    }

    override open func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            shutdownLabel()
        }
    }
    
    override open func didMoveToWindow() {
        if self.window == nil {
            shutdownLabel()
        } else {
            updateAndScroll()
        }
    }
    
    private func updateAndScroll() {
        updateAndScroll(overrideHold: false)
    }
    
    private func updateAndScroll(overrideHold: Bool) {
        if !labelReadyForScroll() {
            return
        }
        
        let expectedLabelSize = sublabelSize()
        
        invalidateIntrinsicContentSize()
        
        // Move label to home
        returnLabelToHome()
        
        // Check if label should scroll
        // Note that the holdScrolling propery does not affect this
        if !labelShouldScroll() {
            // Set text alignment and break mode to act like a normal label
            sublabel.textAlignment = super.textAlignment
            sublabel.lineBreakMode = super.lineBreakMode
            
            let labelFrame: CGRect
            switch type {
            case .continuousReverse, .rightLeft:
                labelFrame = bounds.divided(atDistance: leadingBuffer, from: CGRectEdge.maxXEdge).remainder.integral
            default:
                labelFrame = CGRect(x: leadingBuffer, y: 0.0, width: bounds.size.width - leadingBuffer, height: bounds.size.height).integral
            }
            
            homeLabelFrame = labelFrame
            awayOffset = 0.0
            
            // Remove an additional sublabels (for continuous types)
            repliLayer?.instanceCount = 1

            // Set the sublabel frame to calculated labelFrame
            sublabel.frame = labelFrame
            
            // Remove fade, as by definition none is needed in this case
            removeGradientMask()
            
            return
        }
        
        // Label DOES need to scroll
        
        // Spacing between primary and second sublabel must be at least equal to leadingBuffer, and at least equal to the fadeLength
        let minTrailing = max(max(leadingBuffer, trailingBuffer), fadeLength)
        
        // Determine positions and generate scroll steps
        let sequence: [MarqueeStep]
        
        switch type {
        case .continuous, .continuousReverse:
            if type == .continuous {
                homeLabelFrame = CGRect(x: leadingBuffer, y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = -(homeLabelFrame.size.width + minTrailing)
            } else { // .ContinuousReverse
                homeLabelFrame = CGRect(x: bounds.size.width - (expectedLabelSize.width + leadingBuffer), y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = (homeLabelFrame.size.width + minTrailing)
            }
            
            // Find when the lead label will be totally offscreen
            let offsetDistance = awayOffset
            let offscreenAmount = homeLabelFrame.size.width
            let startFadeFraction = abs(offscreenAmount / offsetDistance)
            // Find when the animation will hit that point
            let startFadeTimeFraction = timingFunctionForAnimationCurve(animationCurve).durationPercentageForPositionPercentage(startFadeFraction, duration: (animationDelay + animationDuration))
            let startFadeTime = startFadeTimeFraction * animationDuration
            
            sequence = scrollSequence ?? [
                ScrollStep(timeStep: 0.0, position: .home, edgeFades: .trailing),                   // Starting point, at home, with trailing fade
                ScrollStep(timeStep: animationDelay, position: .home, edgeFades: .trailing),        // Delay at home, maintaining fade state
                FadeStep(timeStep: 0.2, edgeFades: [.leading, .trailing]),                          // 0.2 sec after scroll start, fade leading edge in as well
                FadeStep(timeStep: (startFadeTime - animationDuration),                             // Maintain fade state until just before reaching end of scroll animation
                         edgeFades: [.leading, .trailing]),
                ScrollStep(timeStep: animationDuration, timingFunction: animationCurve,             // Ending point (back at home), with animationCurve transition, with trailing fade
                           position: .away, edgeFades: .trailing)
            ]
            
            // Set frame and text
            sublabel.frame = homeLabelFrame
            
            // Configure replication
            repliLayer?.instanceCount = 2
            repliLayer?.instanceTransform = CATransform3DMakeTranslation(-awayOffset, 0.0, 0.0)
            
        case .leftRight, .left, .rightLeft, .right:
            if type == .leftRight || type == .left {
                homeLabelFrame = CGRect(x: leadingBuffer, y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = bounds.size.width - (expectedLabelSize.width + leadingBuffer + trailingBuffer)
                // Enforce text alignment for this type
                sublabel.textAlignment = NSTextAlignment.left
            } else {
                homeLabelFrame = CGRect(x: bounds.size.width - (expectedLabelSize.width + leadingBuffer), y: 0.0, width: expectedLabelSize.width, height: bounds.size.height).integral
                awayOffset = (expectedLabelSize.width + trailingBuffer + leadingBuffer) - bounds.size.width
                // Enforce text alignment for this type
                sublabel.textAlignment = NSTextAlignment.right
            }
            // Set frame and text
            sublabel.frame = homeLabelFrame
            
            // Remove any replication
            repliLayer?.instanceCount = 1

            if type == .leftRight || type == .rightLeft {
                sequence = scrollSequence ?? [
                    ScrollStep(timeStep: 0.0, position: .home, edgeFades: .trailing),               // Starting point, at home, with trailing fade
                    ScrollStep(timeStep: animationDelay, position: .home, edgeFades: .trailing),    // Delay at home, maintaining fade state
                    FadeStep(timeStep: 0.2, edgeFades: [.leading, .trailing]),                      // 0.2 sec after delay ends, fade leading edge in as well
                    FadeStep(timeStep: -0.2, edgeFades: [.leading, .trailing]),                     // Maintain fade state until 0.2 sec before reaching away position
                    ScrollStep(timeStep: animationDuration, timingFunction: animationCurve,         // Away position, using animationCurve transition, with only leading edge faded in
                        position: .away, edgeFades: .leading),
                    ScrollStep(timeStep: animationDelay, position: .away, edgeFades: .leading),     // Delay at away, maintaining fade state (leading only)
                    FadeStep(timeStep: 0.2, edgeFades: [.leading, .trailing]),                      // 0.2 sec after delay ends, fade trailing edge back in as well
                    FadeStep(timeStep: -0.2, edgeFades: [.leading, .trailing]),                     // Maintain fade state until 0.2 sec before reaching home position
                    ScrollStep(timeStep: animationDuration, timingFunction: animationCurve,         // Ending point, back at home, with only trailing fade
                        position: .home, edgeFades: .trailing)
                ]
            } else { // .left or .right
                sequence = scrollSequence ?? [
                    ScrollStep(timeStep: 0.0, position: .home, edgeFades: .trailing),               // Starting point, at home, with trailing fade
                    ScrollStep(timeStep: animationDelay, position: .home, edgeFades: .trailing),    // Delay at home, maintaining fade state
                    FadeStep(timeStep: 0.2, edgeFades: [.leading, .trailing]),                      // 0.2 sec after delay ends, fade leading edge in as well
                    FadeStep(timeStep: -0.2, edgeFades: [.leading, .trailing]),                     // Maintain fade state until 0.2 sec before reaching away position
                    ScrollStep(timeStep: animationDuration, timingFunction: animationCurve,         // Away position, using animationCurve transition, with only leading edge faded in
                        position: .away, edgeFades: .leading),
                    ScrollStep(timeStep: animationDelay, position: .away, edgeFades: .leading),     // "Delay" at away, maintaining fade state
                ]
            }
        }
        
        
        
        // Configure gradient for current condition
        applyGradientMask(fadeLength, animated: !self.labelize)
        
        if overrideHold || (!holdScrolling && !overrideHold) {
            beginScroll(sequence)
        }
    }
    
    private func sublabelSize() -> CGSize {
        // Bound the expected size
        let maximumLabelSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        // Calculate the expected size
        var expectedLabelSize = sublabel.sizeThatFits(maximumLabelSize)
        
        #if os(tvOS)
            // Sanitize width to 16384.0 (largest width a UILabel will draw on tvOS)
            expectedLabelSize.width = min(expectedLabelSize.width, 16384.0)
        #else
            // Sanitize width to 5461.0 (largest width a UILabel will draw on an iPhone 6S Plus)
            expectedLabelSize.width = min(expectedLabelSize.width, 5461.0)
        #endif

        // Adjust to own height (make text baseline match normal label)
        expectedLabelSize.height = bounds.size.height
        return expectedLabelSize
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        var fitSize = sublabel.sizeThatFits(size)
        fitSize.width += leadingBuffer
        return fitSize
    }
    
    //
    // MARK: - Animation Handling
    //
    
    open func labelShouldScroll() -> Bool {
        // Check for nil string
        if sublabel.text == nil {
            return false
        }
        
        // Check for empty string
        if sublabel.text!.isEmpty {
            return false
        }
        
        // Check if the label string fits
        let labelTooLarge = (sublabelSize().width + leadingBuffer) > self.bounds.size.width + CGFloat.ulpOfOne
        let animationHasDuration = speed.value > 0.0
        return (!labelize && labelTooLarge && animationHasDuration)
    }
    
    private func labelReadyForScroll() -> Bool {
        // Check if we have a superview
        if superview == nil {
            return false
        }
        
        // Check if we are attached to a window
        if window == nil {
            return false
        }
        
        // Check if our view controller is ready
        let viewController = firstAvailableViewController()
        if viewController != nil {
            if !viewController!.isViewLoaded {
                return false
            }
        }
        
        return true
    }
    
    private func returnLabelToHome() {
        // Remove any gradient animation
        maskLayer?.removeAllAnimations()
        
        // Remove all sublabel position animations
        sublabel.layer.removeAllAnimations()
        
        // Remove completion block
        scrollCompletionBlock = nil
    }
    
    private func beginScroll(_ sequence: [MarqueeStep]) {
        let scroller = generateScrollAnimation(sequence)
        let fader = generateGradientAnimation(sequence, totalDuration: scroller.duration)
        
        scroll(scroller, fader: fader)
    }
    
    private func scroll(_ scroller: MLAnimation, fader: MLAnimation?) {
        // Check for conditions which would prevent scrolling
        if !labelReadyForScroll() {
            return
        }
        // Convert fader to var
        var fader = fader
        
        // Call pre-animation hook
        labelWillBeginScroll()
        
        // Start animation transactions
        CATransaction.begin()
        CATransaction.setAnimationDuration(TimeInterval(scroller.duration))
        
        // Create gradient animation, if needed
        let gradientAnimation: CAKeyframeAnimation?
        // Check for IBDesignable
        #if !TARGET_INTERFACE_BUILDER
            if fadeLength > 0.0 {
                // Remove any setup animation, but apply final values
                if let setupAnim = maskLayer?.animation(forKey: "setupFade") as? CABasicAnimation, let finalColors = setupAnim.toValue as? [CGColor] {
                    maskLayer?.colors = finalColors
                }
                maskLayer?.removeAnimation(forKey: "setupFade")
                
                // Generate animation if needed
                if let previousAnimation = fader?.anim {
                    gradientAnimation = previousAnimation
                } else {
                    gradientAnimation = nil
                }
                
                // Apply fade animation
                maskLayer?.add(gradientAnimation!, forKey: "gradient")
            } else {
                // No animation needed
                fader = nil
            }
        #else
            fader = nil
        #endif

        scrollCompletionBlock = { [weak self] (finished: Bool) in
            guard self != nil else {
                return
            }
            
            // Call returned home function
            self!.labelReturnedToHome(finished)
            
            // Check to ensure that:
            
            // 1) The instance is still attached to a window - this completion block is called for
            //    many reasons, including if the animation is removed due to the view being removed
            //    from the UIWindow (typically when the view controller is no longer the "top" view)
            guard self!.window != nil else {
                return
            }
            // 2) We don't double fire if an animation already exists
            guard self!.sublabel.layer.animation(forKey: "position") == nil else {
                return
            }
            // 3) We don't not start automatically if the animation was unexpectedly interrupted
            guard finished else {
                // Do not continue into the next loop
                return
            }
            // 4) A completion block still exists for the NEXT loop. A notable case here is if
            // returnLabelToHome() was called during a subclass's labelReturnToHome() function
            guard self!.scrollCompletionBlock != nil else {
                return
            }
            
            // Begin again, if conditions met
            if self!.labelShouldScroll() && !self!.tapToScroll && !self!.holdScrolling {
                // Perform completion callback
                self!.scroll(scroller, fader: fader)
            }
        }
        
        // Perform scroll animation
        scroller.anim.setValue(true, forKey: MarqueeKeys.CompletionClosure.rawValue)
        scroller.anim.delegate = self
        if type == .left || type == .right {
            // Make it stay at away permanently
            scroller.anim.isRemovedOnCompletion = false
            scroller.anim.fillMode = .forwards
        }
        sublabel.layer.add(scroller.anim, forKey: "position")
        
        CATransaction.commit()
    }
    
    private func generateScrollAnimation(_ sequence: [MarqueeStep]) -> MLAnimation {
        // Create scroller, which defines the animation to perform
        let homeOrigin = homeLabelFrame.origin
        let awayOrigin = offsetCGPoint(homeLabelFrame.origin, offset: awayOffset)
        
        let scrollSteps = sequence.filter({ $0 is ScrollStep }) as! [ScrollStep]
        let totalDuration = scrollSteps.reduce(0.0) { $0 + $1.timeStep }
        
        // Build scroll data
        var totalTime: CGFloat = 0.0
        var scrollKeyTimes = [NSNumber]()
        var scrollKeyValues = [NSValue]()
        var scrollTimingFunctions = [CAMediaTimingFunction]()
        
        for (offset, step) in scrollSteps.enumerated() {
            // Scroll Times
            totalTime += step.timeStep
            scrollKeyTimes.append(NSNumber(value:Float(totalTime/totalDuration)))
            
            // Scroll Values
            let scrollPosition: CGPoint
            switch step.position {
            case .home:
                scrollPosition = homeOrigin
            case .away:
                scrollPosition = awayOrigin
            case .partial(let frac):
                scrollPosition = offsetCGPoint(homeOrigin, offset: awayOffset*frac)
            }
            scrollKeyValues.append(NSValue(cgPoint:scrollPosition))
            
            // Scroll Timing Functions
            // Only need n-1 timing functions, so discard the first value as it's unused
            if offset == 0 { continue }
            scrollTimingFunctions.append(timingFunctionForAnimationCurve(step.timingFunction))
        }
        
        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "position")
        // Set values
        animation.keyTimes = scrollKeyTimes
        animation.values = scrollKeyValues
        animation.timingFunctions = scrollTimingFunctions
        
        return (anim: animation, duration: totalDuration)
    }
    
    private func generateGradientAnimation(_ sequence: [MarqueeStep], totalDuration: CGFloat) -> MLAnimation {
        // Setup
        var totalTime: CGFloat = 0.0
        var stepTime: CGFloat = 0.0
        var fadeKeyValues = [[CGColor]]()
        var fadeKeyTimes = [NSNumber]()
        var fadeTimingFunctions = [CAMediaTimingFunction]()
        let transp = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        // Filter to get only scroll steps and valid precedent/subsequent fade steps
        let fadeSteps = sequence.enumerated().filter { (arg: (offset: Int, element: MarqueeStep)) -> Bool in
            let (offset, element) = arg
            
            // Include all Scroll Steps
            if element is ScrollStep { return true }
            
            // Include all Fade Steps that have a directly preceding or subsequent Scroll Step
            // Exception: Fade Step cannot be first step
            if offset == 0 { return false }
            
            // Subsequent step if 1) positive/zero time step and 2) follows a Scroll Step
            let subsequent = element.timeStep >= 0 && (sequence[max(0, offset - 1)] is ScrollStep)
            // Precedent step if 1) negative time step and 2) precedes a Scroll Step
            let precedent = element.timeStep < 0 && (sequence[min(sequence.count - 1, offset + 1)] is ScrollStep)
            
            return (precedent || subsequent)
        }
        
        for (offset, step) in fadeSteps {
            // Fade times
            if step is ScrollStep {
                totalTime += step.timeStep
                stepTime = totalTime
            } else {
                if step.timeStep >= 0 {
                    // Is a Subsequent
                    stepTime = totalTime + step.timeStep
                } else {
                    // Is a Precedent, grab next step
                    stepTime = totalTime + fadeSteps[offset + 1].element.timeStep + step.timeStep
                }
            }
            fadeKeyTimes.append(NSNumber(value:Float(stepTime/totalDuration)))
            
            // Fade Values
            let values: [CGColor]
            let leading = step.edgeFades.contains(.leading) ? transp : opaque
            let trailing = step.edgeFades.contains(.trailing) ? transp : opaque
            switch type {
            case .leftRight, .left, .continuous:
                values = [leading, opaque, opaque, trailing]
            case .rightLeft, .right, .continuousReverse:
                values = [trailing, opaque, opaque, leading]
            }
            fadeKeyValues.append(values)
            
            // Fade Timing Function
            // Only need n-1 timing functions, so discard the first value as it's unused
            if offset == 0 { continue }
            fadeTimingFunctions.append(timingFunctionForAnimationCurve(step.timingFunction))
        }
        
        // Create new animation
        let animation = CAKeyframeAnimation(keyPath: "colors")
        
        animation.values = fadeKeyValues
        animation.keyTimes = fadeKeyTimes
        animation.timingFunctions = fadeTimingFunctions

        return (anim: animation, duration: max(totalTime, totalDuration))
    }
    
    private func applyGradientMask(_ fadeLength: CGFloat, animated: Bool, firstStep: MarqueeStep? = nil) {
        // Remove any in-flight animations
        maskLayer?.removeAllAnimations()
        
        // Check for zero-length fade
        if fadeLength <= 0.0 {
            removeGradientMask()
            return
        }
        
        // Configure gradient mask without implicit animations
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // Determine if gradient mask needs to be created
        let gradientMask: CAGradientLayer
        if let currentMask = self.maskLayer {
            // Mask layer already configured
            gradientMask = currentMask
        } else {
            // No mask exists, create new mask
            gradientMask = CAGradientLayer()
            gradientMask.shouldRasterize = true
            gradientMask.rasterizationScale = UIScreen.main.scale
            gradientMask.startPoint = CGPoint(x:0.0, y:0.5)
            gradientMask.endPoint = CGPoint(x:1.0, y:0.5)
        }
        
        // Check if there is a mask to layer size mismatch
        if gradientMask.bounds != self.layer.bounds {
            // Adjust stops based on fade length
            let leftFadeStop = fadeLength/self.bounds.size.width
            let rightFadeStop = 1.0 - fadeLength/self.bounds.size.width
            gradientMask.locations = [0.0, leftFadeStop, rightFadeStop, 1.0].map { NSNumber(value: Float($0)) }
        }
        
        gradientMask.bounds = self.layer.bounds
        gradientMask.position = CGPoint(x:self.bounds.midX, y:self.bounds.midY)
        
        // Set up colors
        let transparent = UIColor.clear.cgColor
        let opaque = UIColor.black.cgColor
        
        // Set mask
        self.layer.mask = gradientMask
        
        // Determine colors for non-scrolling label (i.e. at home)
        let adjustedColors: [CGColor]
        let trailingFadeNeeded = self.labelShouldScroll()

        switch type {
        case .continuousReverse, .rightLeft:
            adjustedColors = [(trailingFadeNeeded ? transparent : opaque), opaque, opaque, opaque]
        
        // .Continuous, .LeftRight
        default:
            adjustedColors = [opaque, opaque, opaque, (trailingFadeNeeded ? transparent : opaque)]
        }
        
        // Check for IBDesignable
        #if TARGET_INTERFACE_BUILDER
            gradientMask.colors = adjustedColors
            CATransaction.commit()
        #else
            if animated {
                // Finish transaction
                CATransaction.commit()
                
                // Create animation for color change
                let colorAnimation = GradientSetupAnimation(keyPath: "colors")
                colorAnimation.fromValue = gradientMask.colors
                colorAnimation.toValue = adjustedColors
                colorAnimation.fillMode = .forwards
                colorAnimation.isRemovedOnCompletion = false
                colorAnimation.delegate = self
                gradientMask.add(colorAnimation, forKey: "setupFade")
            } else {
                gradientMask.colors = adjustedColors
                CATransaction.commit()
            }
        #endif
    }
    
    private func removeGradientMask() {
        self.layer.mask = nil
    }
    
    private func timingFunctionForAnimationCurve(_ curve: UIView.AnimationCurve) -> CAMediaTimingFunction {
        let timingFunction: CAMediaTimingFunctionName?
        
        switch curve {
        case .easeIn:
            timingFunction = .easeIn
        case .easeInOut:
            timingFunction = .easeInEaseOut
        case .easeOut:
            timingFunction = .easeOut
        default:
            timingFunction = .linear
        }
        
        return CAMediaTimingFunction(name: timingFunction!)
    }
    
    private func transactionDurationType(_ labelType: MarqueeType, interval: CGFloat, delay: CGFloat) -> TimeInterval {
        switch labelType {
        case .leftRight, .rightLeft:
            return TimeInterval(2.0 * (delay + interval))
        default:
            return TimeInterval(delay + interval)
        }
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if let setupAnim = anim as? GradientSetupAnimation {
            if let finalColors = setupAnim.toValue as? [CGColor] {
                maskLayer?.colors = finalColors
            }
            // Remove regardless, since we set removeOnCompletion = false
            maskLayer?.removeAnimation(forKey: "setupFade")
        } else {
            scrollCompletionBlock?(flag)
        }
    }
    
    
    //
    // MARK: - Private details
    //
    
    private var sublabel = UILabel()
    
    fileprivate var homeLabelFrame = CGRect.zero
    fileprivate var awayOffset: CGFloat = 0.0
    
    override open class var layerClass: AnyClass {
        return CAReplicatorLayer.self
    }
    
    fileprivate weak var repliLayer: CAReplicatorLayer? {
        return self.layer as? CAReplicatorLayer
    }
    
    fileprivate weak var maskLayer: CAGradientLayer? {
        return self.layer.mask as! CAGradientLayer?
    }
    
    fileprivate var scrollCompletionBlock: MLAnimationCompletionBlock?
    
    override open func draw(_ layer: CALayer, in ctx: CGContext) {
        // Do NOT call super, to prevent UILabel superclass from drawing into context
        // Label drawing is handled by sublabel and CAReplicatorLayer layer class
        
        // Draw only background color
        if let bgColor = backgroundColor {
            ctx.setFillColor(bgColor.cgColor)
            ctx.fill(layer.bounds)
        }
    }
    
    fileprivate enum MarqueeKeys: String {
        case Restart = "MLViewControllerRestart"
        case Labelize = "MLShouldLabelize"
        case Animate = "MLShouldAnimate"
        case CompletionClosure = "MLAnimationCompletion"
    }
    
    class fileprivate func notifyController(_ controller: UIViewController, message: MarqueeKeys) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: message.rawValue), object: nil, userInfo: ["controller" : controller])
    }
    
    @objc public func restartForViewController(_ notification: Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.restartLabel()
            }
        }
    }
    
    @objc public func labelizeForController(_ notification: Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.labelize = true
            }
        }
    }
    
    @objc public func animateForController(_ notification: Notification) {
        if let controller = (notification as NSNotification).userInfo?["controller"] as? UIViewController {
            if controller === self.firstAvailableViewController() {
                self.labelize = false
            }
        }
    }
    public func triggerScrollStart() {
        if labelShouldScroll() && !awayFromHome {
            updateAndScroll()
        }
    }
    
    @objc public func restartLabel() {
        // Shutdown the label
        shutdownLabel()
        // Restart scrolling if appropriate
        if labelShouldScroll() && !tapToScroll && !holdScrolling {
            updateAndScroll()
        }
    }
   
    @available(*, deprecated, message : "Use the shutdownLabel function instead")
    public func resetLabel() {
        returnLabelToHome()
        homeLabelFrame = CGRect.null
        awayOffset = 0.0
    }
    
    @objc public func shutdownLabel() {
        // Bring label to home location
        returnLabelToHome()
        // Apply gradient mask for home location
        applyGradientMask(fadeLength, animated: false)
    }
    
    public func pauseLabel() {
        // Prevent pausing label while not in scrolling animation, or when already paused
        guard !isPaused && awayFromHome else {
            return
        }
        
        // Pause sublabel position animations
        let labelPauseTime = sublabel.layer.convertTime(CACurrentMediaTime(), from: nil)
        sublabel.layer.speed = 0.0
        sublabel.layer.timeOffset = labelPauseTime
        
        // Pause gradient fade animation
        let gradientPauseTime = maskLayer?.convertTime(CACurrentMediaTime(), from:nil)
        maskLayer?.speed = 0.0
        maskLayer?.timeOffset = gradientPauseTime!
    }
    
   
    public func unpauseLabel() {
        // Only unpause if label was previously paused
        guard isPaused else {
            return
        }
        
        // Unpause sublabel position animations
        let labelPausedTime = sublabel.layer.timeOffset
        sublabel.layer.speed = 1.0
        sublabel.layer.timeOffset = 0.0
        sublabel.layer.beginTime = 0.0
        sublabel.layer.beginTime = sublabel.layer.convertTime(CACurrentMediaTime(), from:nil) - labelPausedTime
        
        // Unpause gradient fade animation
        let gradientPauseTime = maskLayer?.timeOffset
        maskLayer?.speed = 1.0
        maskLayer?.timeOffset = 0.0
        maskLayer?.beginTime = 0.0
        maskLayer?.beginTime = maskLayer!.convertTime(CACurrentMediaTime(), from:nil) - gradientPauseTime!
    }
    
    @objc public func labelWasTapped(_ recognizer: UIGestureRecognizer) {
        if labelShouldScroll() && !awayFromHome {
            // Set shouldBeginScroll to true to begin single scroll due to tap
            updateAndScroll(overrideHold: true)
        }
    }
    
    
    open func labelWillBeginScroll() {
        // Default implementation does nothing - override to customize
        return
    }

    open func labelReturnedToHome(_ finished: Bool) {
        // Default implementation does nothing - override to customize
        return
    }
    
   
    #if os(iOS)
    override open func forBaselineLayout() -> UIView {
        // Use subLabel view for handling baseline layouts
        return sublabel
    }
    
    override open var forLastBaselineLayout: UIView {
        // Use subLabel view for handling baseline layouts
        return sublabel
    }
    #endif

    override open var text: String? {
        get {
            return sublabel.text
        }
        
        set {
            if sublabel.text == newValue {
                return
            }
            sublabel.text = newValue
            updateAndScroll()
            super.text = text
        }
    }
    
    override open var attributedText: NSAttributedString? {
        get {
            return sublabel.attributedText
        }
        
        set {
            if sublabel.attributedText == newValue {
                return
            }
            sublabel.attributedText = newValue
            updateAndScroll()
            super.attributedText = attributedText
        }
    }
    
    override open var font: UIFont! {
        get {
            return sublabel.font
        }
        
        set {
            if sublabel.font == newValue {
                return
            }
            sublabel.font = newValue
            super.font = newValue
            
            updateAndScroll()
        }
    }
    
    override open var textColor: UIColor! {
        get {
            return sublabel.textColor
        }
        
        set {
            sublabel.textColor = newValue
            super.textColor = newValue
        }
    }
    
    override open var backgroundColor: UIColor? {
        get {
            return sublabel.backgroundColor
        }
        
        set {
            sublabel.backgroundColor = newValue
            super.backgroundColor = newValue
        }
    }
    
    override open var shadowColor: UIColor? {
        get {
            return sublabel.shadowColor
        }
        
        set {
            sublabel.shadowColor = newValue
            super.shadowColor = newValue
        }
    }
    
    override open var shadowOffset: CGSize {
        get {
            return sublabel.shadowOffset
        }
        
        set {
            sublabel.shadowOffset = newValue
            super.shadowOffset = newValue
        }
    }
    
    override open var highlightedTextColor: UIColor? {
        get {
            return sublabel.highlightedTextColor
        }
        
        set {
            sublabel.highlightedTextColor = newValue
            super.highlightedTextColor = newValue
        }
    }
    
    override open var isHighlighted: Bool {
        get {
            return sublabel.isHighlighted
        }
        
        set {
            sublabel.isHighlighted = newValue
            super.isHighlighted = newValue
        }
    }
    
    override open var isEnabled: Bool {
        get {
            return sublabel.isEnabled
        }
        
        set {
            sublabel.isEnabled = newValue
            super.isEnabled = newValue
        }
    }
    
    override open var numberOfLines: Int {
        get {
            return super.numberOfLines
        }
        
        set {
            // By the nature of MarqueeLabel, this is 1
            super.numberOfLines = 1
        }
    }
    
    override open var adjustsFontSizeToFitWidth: Bool {
        get {
            return super.adjustsFontSizeToFitWidth
        }
        
        set {
            // By the nature of MarqueeLabel, this is false
            super.adjustsFontSizeToFitWidth = false
        }
    }
    
    override open var minimumScaleFactor: CGFloat {
        get {
            return super.minimumScaleFactor
        }
        
        set {
            super.minimumScaleFactor = 0.0
        }
    }
    
    override open var baselineAdjustment: UIBaselineAdjustment {
        get {
            return sublabel.baselineAdjustment
        }
        
        set {
            sublabel.baselineAdjustment = newValue
            super.baselineAdjustment = newValue
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        var content = sublabel.intrinsicContentSize
        content.width += leadingBuffer
        return content
    }
    
    override open var tintColor: UIColor! {
        get {
            return sublabel.tintColor
        }
        
        set {
            sublabel.tintColor = newValue
            super.tintColor = newValue
        }
    }
    
    override open func tintColorDidChange() {
        super.tintColorDidChange()
        sublabel.tintColorDidChange()
    }
    
    override open var contentMode: UIView.ContentMode {
        get {
            return sublabel.contentMode
        }
        
        set {
            super.contentMode = contentMode
            sublabel.contentMode = newValue
        }
    }
    
    open override var isAccessibilityElement: Bool {
        didSet {
            sublabel.isAccessibilityElement = self.isAccessibilityElement
        }
    }

    //
    // MARK: - Support
    //
    
    fileprivate func offsetCGPoint(_ point: CGPoint, offset: CGFloat) -> CGPoint {
        return CGPoint(x: point.x + offset, y: point.y)
    }
    
    //
    // MARK: - Deinit
    //
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


//
// MARK: - Support
//
public protocol MarqueeStep {
    var timeStep: CGFloat { get }
    var timingFunction: UIView.AnimationCurve { get }
    var edgeFades: EdgeFade { get }
}


public struct ScrollStep: MarqueeStep {
  
    public enum Position {
        case home
        case away
        case partial(CGFloat)
    }
    
    
    public let timeStep: CGFloat
    
    
    public let timingFunction: UIView.AnimationCurve
    
    public let position: Position
    
    public let edgeFades: EdgeFade
    
    public init(timeStep: CGFloat, timingFunction: UIView.AnimationCurve = .linear, position: Position, edgeFades: EdgeFade) {
        self.timeStep = timeStep
        self.position = position
        self.edgeFades = edgeFades
        self.timingFunction = timingFunction
    }
}


public struct FadeStep: MarqueeStep {
   
    public let timeStep: CGFloat
   
    public let timingFunction: UIView.AnimationCurve
    
    public let edgeFades: EdgeFade
    
    public init(timeStep: CGFloat, timingFunction: UIView.AnimationCurve = .linear, edgeFades: EdgeFade) {
        self.timeStep = timeStep
        self.timingFunction = timingFunction
        self.edgeFades = edgeFades
    }
}

public struct EdgeFade: OptionSet {
    public let rawValue: Int
    public static let leading = EdgeFade(rawValue: 1 << 0)
    public static let trailing = EdgeFade(rawValue: 1 << 1)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

// Define helpful typealiases
fileprivate typealias MLAnimationCompletionBlock = (_ finished: Bool) -> Void
fileprivate typealias MLAnimation = (anim: CAKeyframeAnimation, duration: CGFloat)

fileprivate class GradientSetupAnimation: CABasicAnimation {
}

fileprivate extension UIResponder {
    // http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone
    
    func firstAvailableViewController() -> UIViewController? {
        // convenience function for casting and to "mask" the recursive function
        return self.traverseResponderChainForFirstViewController()
    }
    
    func traverseResponderChainForFirstViewController() -> UIViewController? {
        if let nextResponder = self.next {
            if nextResponder is UIViewController {
                return nextResponder as? UIViewController
            } else if nextResponder is UIView {
                return nextResponder.traverseResponderChainForFirstViewController()
            } else {
                return nil
            }
        }
        return nil
    }
}

fileprivate extension CAMediaTimingFunction {
    
    func durationPercentageForPositionPercentage(_ positionPercentage: CGFloat, duration: CGFloat) -> CGFloat {
        
        let controlPoints = self.controlPoints()
        let epsilon: CGFloat = 1.0 / (100.0 * CGFloat(duration))
        
        let t_found = solveTforY(positionPercentage, epsilon: epsilon, controlPoints: controlPoints)
        
        let durationPercentage = XforCurveAt(t_found, controlPoints: controlPoints)
        
        return durationPercentage
    }
    
    func solveTforY(_ y_0: CGFloat, epsilon: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        var t0 = y_0
        var t1 = y_0
        var f0, df0: CGFloat
        
        for _ in 0..<15 {
            t0 = t1
            // Calculate f(t0)
            f0 = YforCurveAt(t0, controlPoints:controlPoints) - y_0
            // Check if this is close (enough)
            if abs(f0) < epsilon {
                // Done!
                return t0
            }
            df0 = derivativeCurveYValueAt(t0, controlPoints:controlPoints)
            // Check if derivative is small or zero ( http://en.wikipedia.org/wiki/Newton's_method#Failure_analysis )
            if abs(df0) < 1e-6 {
                break
            }
            // Else recalculate t1
            t1 = t0 - f0/df0
        }
        
        // Give up - shouldn't ever get here...I hope
        print("MarqueeLabel: Failed to find t for Y input!")
        return t0
    }

    func YforCurveAt(_ t: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        // Per http://en.wikipedia.org/wiki/Bezier_curve#Cubic_B.C3.A9zier_curves
        let y0 = (pow((1.0 - t), 3.0) * P0.y)
        let y1 = (3.0 * pow(1.0 - t, 2.0) * t * P1.y)
        let y2 = (3.0 * (1.0 - t) * pow(t, 2.0) * P2.y)
        let y3 = (pow(t, 3.0) * P3.y)
        
        return y0 + y1 + y2 + y3
    }
    
    func XforCurveAt(_ t: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        // Per http://en.wikipedia.org/wiki/Bezier_curve#Cubic_B.C3.A9zier_curves

        let x0 = (pow((1.0 - t), 3.0) * P0.x)
        let x1 = (3.0 * pow(1.0 - t, 2.0) * t * P1.x)
        let x2 = (3.0 * (1.0 - t) * pow(t, 2.0) * P2.x)
        let x3 = (pow(t, 3.0) * P3.x)
        
        return x0 + x1 + x2 + x3
    }
    
    func derivativeCurveYValueAt(_ t: CGFloat, controlPoints: [CGPoint]) -> CGFloat {
        let P0 = controlPoints[0]
        let P1 = controlPoints[1]
        let P2 = controlPoints[2]
        let P3 = controlPoints[3]
        
        let dy0 = (P0.y + 3.0 * P1.y + 3.0 * P2.y - P3.y) * -3.0
        let dy1 = t * (6.0 * P0.y + 6.0 * P2.y)
        let dy2 = (-3.0 * P0.y + 3.0 * P1.y)

        return dy0 * pow(t, 2.0) + dy1 + dy2
    }
    
    func controlPoints() -> [CGPoint] {
        // Create point array to point to
        var point: [Float] = [0.0, 0.0]
        var pointArray = [CGPoint]()
        for i in 0...3 {
            self.getControlPoint(at: i, values: &point)
            pointArray.append(CGPoint(x: CGFloat(point[0]), y: CGFloat(point[1])))
        }
        
        return pointArray
    }
}

