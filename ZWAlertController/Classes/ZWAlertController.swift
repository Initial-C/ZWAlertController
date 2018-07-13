//
//  ZWAlertController.swift
//  ZWAlertController
//
//  Created by InitialC. on 2016/12/20.
//  Copyright (c) 2016 InitialC. All rights reserved.
//
//  This software is released under the MIT License.
//
//

import Foundation
import UIKit

let ZWAlertActionEnabledDidChangeNotification = "ZWAlertActionEnabledDidChangeNotification"
let zwAlert = ZWAlertController()
private let isIPhoneXSpec = UIScreen.main.bounds.height == 812
public enum ZWAlertActionStyle : Int {
    case `default`
    case cancel
    case destructive
    case simplifyCancel
    case simplifyDefault
    case simplifyDestructive
}

public enum ZWAlertControllerStyle : Int {
    case actionSheet
    case alert
    case customActionSheet
    case simplify
    case customCardSheet
}

// MARK: ZWAlertAction Class
@objc(ZWAlertAction)
open class ZWAlertAction : NSObject, NSCopying {
    var title: String
    var image: UIImage?
    public var style: ZWAlertActionStyle
    public var handler: ((ZWAlertAction?) -> Void)!
    open var enabled: Bool {
        didSet {
            if (oldValue != enabled) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ZWAlertActionEnabledDidChangeNotification), object: nil)
            }
        }
    }
    
    public init(title: String, style: ZWAlertActionStyle, handler: ((ZWAlertAction?) -> Void)!) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
    required public init(title: String, image: UIImage?, style: ZWAlertActionStyle, handler: ((ZWAlertAction?) -> Void)!) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
        self.image = image
    }
    
    public func copy(with zone: NSZone?) -> Any {
        let copy = type(of: self).init(title: title, image: image, style: style, handler: handler)
        copy.enabled = self.enabled
        return copy
    }
}

// MARK: ZWAlertAnimation Class

class ZWAlertAnimation : NSObject, UIViewControllerAnimatedTransitioning {

    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if (isPresenting) {
            return 0.45
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if (isPresenting) {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ZWAlertController
        let containerView = transitionContext.containerView
        
        alertController.overlayView.alpha = 0.0
        if (alertController.isAlert()) {
            alertController.alertView.alpha = 0.0
            alertController.alertView.center = alertController.view.center
            alertController.alertView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } else {
            alertController.alertView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
        }
        containerView.addSubview(alertController.view)
        
        UIView.animate(withDuration: 0.25,
            animations: {
                alertController.overlayView.alpha = 1.0
                if (alertController.isAlert()) {
                    alertController.alertView.alpha = 1.0
                    alertController.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } else {
                    let bounce = alertController.alertView.frame.height / 480 * 10.0 + 10.0
                    alertController.alertView.transform = CGAffineTransform(translationX: 0, y: -bounce)
                }
            },
            completion: { finished in
                UIView.animate(withDuration: 0.2,
                    animations: {
                        alertController.alertView.transform = CGAffineTransform.identity
                    },
                    completion: { finished in
                        if (finished) {
                            transitionContext.completeTransition(true)
                        }
                    })
            })
    }
    
    func dismissAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ZWAlertController
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
            animations: {
                alertController.overlayView.alpha = 0.0
                if (alertController.isAlert()) {
                    alertController.alertView.alpha = 0.0
                    alertController.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                } else {
                    alertController.containerView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
                }
            },
            completion: { finished in
                transitionContext.completeTransition(true)
            })
    }
}

// MARK: ZWAlertController Class
@objc(ZWAlertController)
open class ZWAlertController : UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // Message
    open var message: String?
    
    // AlertController Style
    fileprivate(set) var preferredStyle: ZWAlertControllerStyle?
    
    // OverlayView
    fileprivate var overlayView = UIView()
    open var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    // ContainerView
    fileprivate var containerView = UIView()
    fileprivate var containerViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // AlertView
    fileprivate var alertView = UIView()
    open var alertViewBgColor = UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    fileprivate var alertViewWidth: CGFloat = 270.0
    fileprivate var alertViewHeightConstraint: NSLayoutConstraint!
    fileprivate var alertViewPadding: CGFloat = 15.0
    fileprivate var innerContentWidth: CGFloat = 240.0
    fileprivate let actionSheetBounceHeight: CGFloat = 20.0
    
    // TextAreaScrollView
    fileprivate var textAreaScrollView = UIScrollView()
    fileprivate var textAreaHeight: CGFloat = 0.0
    
    // TextAreaView
    fileprivate var textAreaView = UIView()
    
    // TextContainer
    fileprivate var textContainer = UIView()
    fileprivate var textContainerHeightConstraint: NSLayoutConstraint!
    
    // TitleLabel
    fileprivate var titleLabel = UILabel()
    open var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    open var titleTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // MessageView
    fileprivate var messageView = UILabel()
    open var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    open var messageTextColor = UIColor(red:77/255, green:77/255, blue:77/255, alpha:1.0)
    
    // TextFieldContainerView
    fileprivate var textFieldContainerView = UIView()
    open var textFieldBorderColor = UIColor(red: 203.0/255, green: 203.0/255, blue: 203.0/255, alpha: 1.0)
    
    // TextFields
//    fileprivate(set)
    open var textFields: [AnyObject]?
    fileprivate let textFieldHeight: CGFloat = 30.0
    open var textFieldBgColor = UIColor.white
    fileprivate let textFieldCornerRadius: CGFloat = 4.0
    fileprivate var _textLimit : Int32?
    // ButtonAreaScrollView
    fileprivate var buttonAreaScrollView = UIScrollView()
    fileprivate var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    fileprivate var buttonAreaHeight: CGFloat = 0.0
    
    // ButtonAreaView
    fileprivate var buttonAreaView = UIView()
    
    // ButtonContainer
    fileprivate var buttonContainer = UIView()
    fileprivate var buttonContainerHeightConstraint: NSLayoutConstraint!
    fileprivate var buttonHeight: CGFloat = 44.0
    fileprivate var buttonMargin: CGFloat = 10.0
    fileprivate var squareButtonHeight : CGFloat = 55
    fileprivate var squareButtonMargin : CGFloat = 2.0
    fileprivate let squareButtonFont = UIFont.systemFont(ofSize: 14)
    fileprivate let squareIconButtonFont = UIFont.systemFont(ofSize: 15)
    fileprivate let squareIconNormalTextColor = UIColor(red:102/255, green:102/255, blue:102/255, alpha:1.0)
    fileprivate let squareNormalTextColor = UIColor(red:51/255, green:51/255, blue:51/255, alpha:1.0)
    fileprivate let squareDestructiveTextColor = UIColor(red:255/255, green:93/255, blue:93/255, alpha:1.0)
    
    // Actions
    fileprivate(set) var actions: [AnyObject] = []
    
    // Buttons
    fileprivate var buttons = [UIButton]()
    
    open var textLimit : Int32? {
        set {
            self._textLimit = newValue
        }
        get {
            return self._textLimit
        }
    }
    class open func getInstance() -> ZWAlertController {
        return zwAlert
    }
    public var buttonFont: [ZWAlertActionStyle : UIFont?] = [
        .default : UIFont(name: "HelveticaNeue-Bold", size: 15),
        .cancel  : UIFont(name: "HelveticaNeue-Bold", size: 15),
        .destructive  : UIFont(name: "HelveticaNeue-Bold", size: 15),
        .simplifyCancel : UIFont(name: "PingFangSC-Medium", size: 15),
        .simplifyDefault : UIFont(name: "PingFangSC-Medium", size: 15),
        .simplifyDestructive : UIFont(name: "PingFangSC-Medium", size: 15)
    ]
    public var buttonTextColor: [ZWAlertActionStyle : UIColor] = [
        .default : UIColor.white,
        .cancel  : UIColor.white,
        .destructive  : UIColor.white,
        .simplifyDefault : UIColor.init(red: 255/255.0, green: 204/255.0, blue: 0/255.0, alpha: 1.0),
        .simplifyDestructive : UIColor(red:255/255, green:93/255, blue:93/255, alpha:1.0),
        .simplifyCancel : UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    ]
    public var buttonBgColor: [ZWAlertActionStyle : UIColor] = [
        .default : UIColor(red:52/255, green:152/255, blue:219/255, alpha:1),
        .cancel  : UIColor(red:127/255, green:140/255, blue:141/255, alpha:1),
        .destructive  : UIColor(red:231/255, green:76/255, blue:60/255, alpha:1),
        .simplifyDefault : UIColor.white,
        .simplifyDestructive : UIColor.white,
        .simplifyCancel : UIColor.white
    ]
    public var buttonBgColorHighlighted: [ZWAlertActionStyle : UIColor] = [
        .default : UIColor(red:74/255, green:163/255, blue:223/255, alpha:1),
        .cancel  : UIColor(red:140/255, green:152/255, blue:153/255, alpha:1),
        .destructive  : UIColor(red:234/255, green:97/255, blue:83/255, alpha:1),
        .simplifyDefault : UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0),
        .simplifyDestructive : UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0),
        .simplifyCancel : UIColor(red:239/255, green:240/255, blue:242/255, alpha:1.0)
    ]
    fileprivate var buttonCornerRadius: CGFloat = 4.0
    fileprivate var layoutFlg = false
    fileprivate var keyboardHeight: CGFloat = 0.0
    fileprivate var cancelButtonTag = 0
    fileprivate var currentAction : ZWAlertAction?
    // Initializer
    convenience public init(title: String?, message: String?, preferredStyle: ZWAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.resizeProperties()
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        
        // NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(ZWAlertController.handleAlertActionEnabledDidChangeNotification(_:)), name: NSNotification.Name(rawValue: ZWAlertActionEnabledDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ZWAlertController.handleKeyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ZWAlertController.handleKeyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Delegate
        self.transitioningDelegate = self
        
        // Screen Size
        var screenSize = UIScreen.main.bounds.size
        if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                screenSize = CGSize(width: screenSize.height, height: screenSize.width)
            }
        }
        
        // variable for ActionSheet
        if (!isAlert()) {
            if !isCustomSheet() && !isCardSheet {
                alertViewWidth =  screenSize.width
                alertViewPadding = 8.0
                innerContentWidth = (screenSize.height > screenSize.width) ? screenSize.width - alertViewPadding * 2 : screenSize.height - alertViewPadding * 2
                buttonMargin = 8.0
                buttonCornerRadius = 6.0
            } else {
                alertViewBgColor = UIColor(red:238/255, green:238/255, blue:238/255, alpha:1.0)
                alertViewWidth = screenSize.width
                alertViewPadding = 0.0
                innerContentWidth = (screenSize.height > screenSize.width) ? screenSize.width : screenSize.height
                if isCustomSheet() {
                    buttonMargin = 5.0  // cancel button margin
                    squareButtonMargin = 2.0
                    buttonCornerRadius = 0.0
                    squareButtonHeight = 55
                } else {
                    buttonMargin = 0  // cancel button margin
                    squareButtonMargin = 0.5
                    buttonCornerRadius = 15
                    squareButtonHeight = 45
                }
            }
        }
        
        // self.view
        self.view.frame.size = screenSize
        
        // OverlayView
        self.view.addSubview(overlayView)
        
        // ContainerView
        self.view.addSubview(containerView)
        
        // AlertView
        containerView.addSubview(alertView)
        
        // TextAreaScrollView
        alertView.addSubview(textAreaScrollView)
        
        // TextAreaView
        textAreaScrollView.addSubview(textAreaView)
        
        // TextContainer
        textAreaView.addSubview(textContainer)
        
        // ButtonAreaScrollView
        alertView.addSubview(buttonAreaScrollView)
        
        // ButtonAreaView
        buttonAreaScrollView.addSubview(buttonAreaView)
        
        // ButtonContainer
        buttonAreaView.addSubview(buttonContainer)
        
        //------------------------------
        // Layout Constraint
        //------------------------------
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        textAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // self.view
        let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint, containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        if (isAlert()) {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint])
            
            // AlertView
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: alertViewWidth)
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraints([alertViewWidthConstraint, alertViewHeightConstraint])
            
        } else {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let alertViewBottomSpaceConstraint = NSLayoutConstraint(item: alertView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: actionSheetBounceHeight)
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomSpaceConstraint, alertViewWidthConstraint])
            
            // AlertView
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraint(alertViewHeightConstraint)
        }
        
        // AlertView
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .top, relatedBy: .equal, toItem: alertView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .right, relatedBy: .equal, toItem: alertView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .left, relatedBy: .equal, toItem: alertView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .bottom, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .right, relatedBy: .equal, toItem: alertView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .left, relatedBy: .equal, toItem: alertView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .bottom, relatedBy: .equal, toItem: alertView, attribute: .bottom, multiplier: 1.0, constant: isAlert() ? 0.0 : -actionSheetBounceHeight)
        alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint])
        
        // TextAreaScrollView
        let textAreaViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .top, relatedBy: .equal, toItem: textAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textAreaViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .right, relatedBy: .equal, toItem: textAreaScrollView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let textAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .left, relatedBy: .equal, toItem: textAreaScrollView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let textAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .bottom, relatedBy: .equal, toItem: textAreaScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let textAreaViewWidthConstraint = NSLayoutConstraint(item: textAreaView, attribute: .width, relatedBy: .equal, toItem: textAreaScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
        textAreaScrollView.addConstraints([textAreaViewTopSpaceConstraint, textAreaViewRightSpaceConstraint, textAreaViewLeftSpaceConstraint, textAreaViewBottomSpaceConstraint, textAreaViewWidthConstraint])
        
        // TextArea
        let textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView, attribute: .height, relatedBy: .equal, toItem: textContainer, attribute: .height, multiplier: 1.0, constant: 0.0)
        let textContainerTopSpaceConstraint = NSLayoutConstraint(item: textContainer, attribute: .top, relatedBy: .equal, toItem: textAreaView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textContainerCenterXConstraint = NSLayoutConstraint(item: textContainer, attribute: .centerX, relatedBy: .equal, toItem: textAreaView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        textAreaView.addConstraints([textAreaViewHeightConstraint, textContainerTopSpaceConstraint, textContainerCenterXConstraint])
        
        // TextContainer
        let textContainerWidthConstraint = NSLayoutConstraint(item: textContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: innerContentWidth)
        textContainerHeightConstraint = NSLayoutConstraint(item: textContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        textContainer.addConstraints([textContainerWidthConstraint, textContainerHeightConstraint])
        
        // ButtonAreaScrollView
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewTopSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .top, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .right, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .left, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .bottom, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewWidthConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .width, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
        buttonAreaScrollView.addConstraints([buttonAreaScrollViewHeightConstraint, buttonAreaViewTopSpaceConstraint, buttonAreaViewRightSpaceConstraint, buttonAreaViewLeftSpaceConstraint, buttonAreaViewBottomSpaceConstraint, buttonAreaViewWidthConstraint])
        
        // ButtonArea
        let buttonAreaViewHeightConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .height, relatedBy: .equal, toItem: buttonContainer, attribute: .height, multiplier: 1.0, constant: 0.0)
        let buttonContainerTopSpaceConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .top, relatedBy: .equal, toItem: buttonAreaView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonContainerCenterXConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .centerX, relatedBy: .equal, toItem: buttonAreaView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        buttonAreaView.addConstraints([buttonAreaViewHeightConstraint, buttonContainerTopSpaceConstraint, buttonContainerCenterXConstraint])
        
        // ButtonContainer
        let buttonContainerWidthConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: isSimplify ? alertViewWidth : innerContentWidth)
        buttonContainerHeightConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        buttonContainer.addConstraints([buttonContainerWidthConstraint, buttonContainerHeightConstraint])
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutView()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!isAlert() && cancelButtonTag != 0) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ZWAlertController.handleContainerViewTapGesture(_:)))
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    func resizeProperties() {
        if isSimplify {
            alertViewBgColor = UIColor.white
            alertViewWidth = 280.0
            alertViewPadding = 0.0
            innerContentWidth = 220.0
            titleFont = UIFont(name: "PingFangSC-Regular", size: 18)
            titleTextColor = UIColor(red:51/255, green:51/255, blue:51/255, alpha:1.0)
            messageFont = UIFont(name: "PingFangSC-Regular", size: 15)
            messageTextColor = UIColor(red:51/255, green:51/255, blue:51/255, alpha:1.0)
            buttonHeight = 45.0
            buttonMargin = 0.5
            buttonCornerRadius = 0.0
        }
    }
    private func getLabHeigh(_ labelStr:String, _ font:UIFont, _ width:CGFloat) -> CGFloat {
        let statusLabelText : NSString = NSString.init(string: labelStr)
        let size = CGSize.init(width: width, height: 900)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font : font], context: nil).size
        return strSize.height
    }
    func layoutView() {
        if (layoutFlg) { return }
        layoutFlg = true
        
        //------------------------------
        // Layout & Color Settings
        //------------------------------
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        
        if !isCustomSheet() && !isCardSheet {
            alertView.layer.cornerRadius = isSimplify ? 10 : 12
            alertView.layer.masksToBounds = true
        }
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        let hasTitle: Bool = title != nil && title != ""
        let hasMessage: Bool = message != nil && message != ""
        let hasTextField: Bool = textFields != nil && textFields!.count > 0
        
        var textAreaPositionY: CGFloat = alertViewPadding
        if (!isAlert()) {textAreaPositionY += alertViewPadding}
        
        

        // TitleLabel
        if (hasTitle || isSimplify) {
            titleLabel.frame.size = CGSize(width: innerContentWidth, height: 30)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.font = titleFont
            titleLabel.textColor = titleTextColor
            titleLabel.text = title
            titleLabel.minimumScaleFactor = 0.7
            titleLabel.adjustsFontSizeToFitWidth = true
            if !isSimplify {
                titleLabel.sizeToFit()
            }
            titleLabel.frame = CGRect(x: 0, y: textAreaPositionY, width: innerContentWidth, height: titleLabel.frame.height)
            textContainer.addSubview(titleLabel)
            textAreaPositionY += titleLabel.frame.height + (isSimplify ? 0.0 : 5.0)
        }
        
        // MessageView
        if (hasMessage) {
            messageView.frame.size = CGSize(width: innerContentWidth, height: 55)
            messageView.numberOfLines = 0
            messageView.textAlignment = .center
            messageView.font = messageFont
            messageView.textColor = messageTextColor
            messageView.text = message
            messageView.sizeToFit()
            /*
            if !isSimplify {
                messageView.sizeToFit()
            } else if isSimplify {
                let lbH = getLabHeigh(message ?? "", titleFont!, innerContentWidth)
                messageView.frame.size.height = lbH
//                if lbH > 55 && lbH < 110 {
//                    messageView.frame.size.height = lbH
//                } else if lbH > 110 {
//                    messageView.frame.size.height = lbH
//                    messageView.minimumScaleFactor = 0.5
//                    messageView.adjustsFontSizeToFitWidth = true
//                }
            }
             */
            messageView.frame = CGRect(x: 0, y: textAreaPositionY, width: innerContentWidth, height: messageView.frame.height)
            textContainer.addSubview(messageView)
            textAreaPositionY += messageView.frame.height + (isSimplify ? 29.0 : 5.0)
        }
        
        // TextFieldContainerView
        if (hasTextField) {
            if isSimplify { textAreaPositionY -= 24 }
            if (hasTitle || hasMessage) { textAreaPositionY += 5.0 }
            
            textFieldContainerView.backgroundColor = textFieldBorderColor
            textFieldContainerView.layer.masksToBounds = true
            textFieldContainerView.layer.cornerRadius = textFieldCornerRadius
            textFieldContainerView.layer.borderWidth = 0.5
            textFieldContainerView.layer.borderColor = textFieldBorderColor.cgColor
            textContainer.addSubview(textFieldContainerView)
            
            var textFieldContainerHeight: CGFloat = 0.0
            
            // TextFields
            for (_, obj) in (textFields?.enumerated())! {
                let textField = obj as! UITextField
                textField.frame = CGRect(x: 0.0, y: textFieldContainerHeight, width: innerContentWidth, height: textField.frame.height)
                textFieldContainerHeight += textField.frame.height + 0.5
            }
            
            textFieldContainerHeight -= 0.5
            textFieldContainerView.frame = CGRect(x: 0.0, y: textAreaPositionY, width: innerContentWidth, height: textFieldContainerHeight)
            textAreaPositionY += textFieldContainerHeight + 5.0
        }
        
        if (!hasTitle && !hasMessage && !hasTextField) {
            textAreaPositionY = 0.0
        }
        
        // TextAreaScrollView
        textAreaHeight = textAreaPositionY
        textAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: textAreaHeight)
        textContainerHeightConstraint.constant = textAreaHeight
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaPositionY: CGFloat = isBothCardSheet ? squareButtonMargin : buttonMargin
        
        // Buttons
        if (isAlert() && buttons.count > 0 && buttons.count < 3) {
            var buttonWidth = isSimplify ? alertViewWidth*0.5 : (innerContentWidth - buttonMargin) / 2
            if buttons.count == 1 {
                buttonWidth = isSimplify ? alertViewWidth : innerContentWidth
            }
            var buttonPositionX : CGFloat = 0.0
            for button in buttons {
                let action = actions[button.tag - 1] as! ZWAlertAction
                button.titleLabel?.font = buttonFont[action.style]!
                button.setTitleColor(buttonTextColor[action.style], for: UIControlState())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControlState())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
                button.frame = CGRect(x: buttonPositionX, y: buttonAreaPositionY, width: buttonWidth, height: buttonHeight)
                buttonPositionX += buttonMargin + buttonWidth
            }
            buttonAreaPositionY += buttonHeight
        } else {
            for button in buttons {
                let action = actions[button.tag - 1] as! ZWAlertAction
                if (action.style != ZWAlertActionStyle.cancel) {
                    if !isCustomSheet() && !isCardSheet {
                        button.titleLabel?.font = buttonFont[action.style]!
                        button.setTitleColor(buttonTextColor[action.style], for: UIControlState())
                        button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControlState())
                        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
                        button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
                        button.frame = CGRect(x: 0, y: buttonAreaPositionY, width: innerContentWidth, height: buttonHeight)
                        buttonAreaPositionY += buttonHeight + buttonMargin
                    } else {
                        let isNormalBtn = action.image == nil
                        let btnFont = isNormalBtn ? squareButtonFont : squareIconButtonFont
                        let btnStrColor = isNormalBtn ? squareNormalTextColor : squareIconNormalTextColor
                        button.titleLabel?.font = btnFont
                        let btnTextColor = action.style == .destructive ? squareDestructiveTextColor : btnStrColor
                        let btnHighSelectedColor = UIColor(red:245/255, green:245/255, blue:245/255, alpha:1.0)
                        let btnGeneralColorImage = createImageFromUIColor(btnHighSelectedColor)
                        button.setTitleColor(btnTextColor, for: UIControlState())
                        button.setBackgroundImage(createImageFromUIColor(.white), for: UIControlState())
                        button.setBackgroundImage(btnGeneralColorImage, for: .highlighted)
                        button.setBackgroundImage(btnGeneralColorImage, for: .selected)
                        if let image = action.image {
                            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                            button.setImage(image, for: .normal)
                            button.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0)
                            button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0)
                        }
                        buttonAreaPositionY = buttonAreaPositionY == squareButtonMargin ? 0.0 : buttonAreaPositionY
                        button.frame = CGRect(x: 0, y: buttonAreaPositionY, width: innerContentWidth, height: squareButtonHeight)
//                        if isCardSheet && buttonAreaPositionY == 0 {
//                            let slideCornerPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: innerContentWidth, height: button.frame.height)), byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize.init(width: 15, height: 15))
//                            let slideMaskLayer = CAShapeLayer.init()
//                            slideMaskLayer.frame = button.bounds
//                            slideMaskLayer.path = slideCornerPath.cgPath
//                            button.layer.mask = slideMaskLayer
//                        }
                        buttonAreaPositionY += squareButtonHeight + squareButtonMargin
                    }
                } else {
                    cancelButtonTag = button.tag
                }
            }
            
            // Cancel Button
            if (cancelButtonTag != 0) {
                if (!isAlert() && buttons.count > 1) {
                    buttonAreaPositionY += buttonMargin
                } else if (!isAlert() && buttons.count == 1) {
                    buttonAreaPositionY = 0.0
                }
                let button = buttonAreaScrollView.viewWithTag(cancelButtonTag) as! UIButton
                let action = actions[cancelButtonTag - 1] as! ZWAlertAction
                let isNormalBtn = action.image == nil
                let btnFont = isNormalBtn ? squareButtonFont : squareIconButtonFont
                let btnStrColor = isNormalBtn ? squareNormalTextColor : squareIconNormalTextColor
                let btnTextColor = isBothCardSheet ? btnStrColor : buttonTextColor[action.style]
                let btnHighSelectedColor = UIColor(red:245/255, green:245/255, blue:245/255, alpha:1.0)
                let btnCancelNormalColorImage = isBothCardSheet ? createImageFromUIColor(.white) : createImageFromUIColor(buttonBgColor[action.style]!)
                let btnCancelColorImage = isBothCardSheet ? createImageFromUIColor(btnHighSelectedColor) : createImageFromUIColor(buttonBgColorHighlighted[action.style]!)
                let btnCancelHeight = isBothCardSheet ? (isIPhoneXSpec ? squareButtonHeight + 34 : squareButtonHeight) : buttonHeight
                button.titleLabel?.font = isBothCardSheet ? btnFont : buttonFont[action.style]!
                button.setTitleColor(btnTextColor, for: UIControlState())
                button.setBackgroundImage(btnCancelNormalColorImage, for: UIControlState())
                button.setBackgroundImage(btnCancelColorImage, for: .highlighted)
                button.setBackgroundImage(btnCancelColorImage, for: .selected)
                if let image = action.image {
                    button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
                    button.setImage(image, for: .normal)
                    button.imageEdgeInsets = UIEdgeInsetsMake(isIPhoneXSpec ? -34 : 0, 12, 0, 0)
                }
                button.frame = CGRect(x: 0, y: buttonAreaPositionY, width: innerContentWidth, height: btnCancelHeight)
                button.titleEdgeInsets = UIEdgeInsetsMake(isIPhoneXSpec ? -34 : 0, isNormalBtn ? 0 : 20, 0, 0)
                buttonAreaPositionY += btnCancelHeight + buttonMargin
            }
            buttonAreaPositionY -= buttonMargin
        }
        buttonAreaPositionY += alertViewPadding
        
        if (buttons.count == 0) {
            buttonAreaPositionY = 0.0
        }
        
        // ButtonAreaScrollView Height
        buttonAreaHeight = buttonAreaPositionY
        buttonAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: buttonAreaHeight)
        buttonContainerHeightConstraint.constant = buttonAreaHeight
        
        //------------------------------
        // AlertView Layout
        //------------------------------
        // AlertView Height
        reloadAlertViewHeight()
        alertView.frame.size = CGSize(width: alertViewWidth, height: alertViewHeightConstraint.constant)
        if isCardSheet {
            let slideCornerPath = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: alertView.frame.width, height: alertView.frame.height)), byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize.init(width: 15, height: 15))
            let slideMaskLayer = CAShapeLayer.init()
            slideMaskLayer.frame = alertView.bounds
            slideMaskLayer.path = slideCornerPath.cgPath
            alertView.layer.mask = slideMaskLayer
        }
    }
    
    // Reload AlertView Height
    func reloadAlertViewHeight() {
        
        var screenSize = UIScreen.main.bounds.size
        if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
            if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                screenSize = CGSize(width: screenSize.height, height: screenSize.width)
            }
        }
        let maxHeight = screenSize.height - keyboardHeight
        
        // for avoiding constraint error
        buttonAreaScrollViewHeightConstraint.constant = 0.0
        
        // AlertView Height Constraint
        var alertViewHeight = textAreaHeight + buttonAreaHeight
        if (alertViewHeight > maxHeight) {
            alertViewHeight = maxHeight
        }
        if (!isAlert()) {
            alertViewHeight += actionSheetBounceHeight
        }
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
        var buttonAreaScrollViewHeight = buttonAreaHeight
        if (buttonAreaScrollViewHeight > maxHeight) {
            buttonAreaScrollViewHeight = maxHeight
        }
        buttonAreaScrollViewHeightConstraint.constant = buttonAreaScrollViewHeight
    }
    
    // Button Tapped Action
    @objc func buttonTapped(_ sender: UIButton) {
        sender.isSelected = true
        let action = actions[sender.tag - 1] as! ZWAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handle ContainerView tap gesture
    @objc func handleContainerViewTapGesture(_ sender: AnyObject) {
        // cancel action
        /*
        let action = actions[cancelButtonTag] as! ZWAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        */
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIColor -> UIImage
    func createImageFromUIColor(_ color: UIColor) -> UIImage {
        let color = color
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef: CGContext = UIGraphicsGetCurrentContext()!
        contextRef.setFillColor(color.cgColor)
        contextRef.fill(rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    // MARK : Handle NSNotification Method
    
    @objc func handleAlertActionEnabledDidChangeNotification(_ notification: Notification) {
        for i in 0..<buttons.count {
            if actions.count >= buttons.count {
                buttons[i].isEnabled = actions[i].isEnabled
            }
        }
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: NSValue] {
            var keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue.size
            if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
                if (UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)) {
                    keyboardSize = CGSize(width: keyboardSize.height, height: keyboardSize.width)
                }
            }
            keyboardHeight = keyboardSize.height
            reloadAlertViewHeight()
            containerViewBottomSpaceConstraint.constant = -keyboardHeight
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        keyboardHeight = 0.0
        reloadAlertViewHeight()
        containerViewBottomSpaceConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Public Methods
    
    // Attaches an action object to the alert or action sheet.
    open func addAction(_ action: ZWAlertAction) {
        // Error
        if (action.style == ZWAlertActionStyle.cancel) {
            for ac in actions as! [ZWAlertAction] {
                if (ac.style == ZWAlertActionStyle.cancel) {
//                    let error: NSError?
//                    NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"), format:"ZWAlertController can only have one action with a style of ZWAlertActionStyleCancel", arguments:getVaList([error ?? "nil"]))
                    return
                }
            }
        }
        // Add Action
        actions.append(action)
        
        // Add Button
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle(action.title, for: UIControlState())
        button.isEnabled = action.enabled
        if !isCardSheet {
            button.layer.cornerRadius = buttonCornerRadius
        }
        button.addTarget(self, action: #selector(ZWAlertController.buttonTapped(_:)), for: .touchUpInside)
        if action.style == .default || action.style == .destructive {
            self.currentAction = action
        }
        button.tag = buttons.count + 1
        buttons.append(button)
        buttonContainer.backgroundColor = isSimplify ? UIColor.init(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0) : .clear
        buttonContainer.addSubview(button)
    }
    
    // Adds a text field to an alert.
    open func addTextFieldWithConfigurationHandler(_ configurationHandler: ((UITextField?) -> Void)!) {
        
        // You can add a text field only if the preferredStyle property is set to ZWAlertControllerStyle.Alert.
        if (!isAlert()) {
//            let error: NSError?
//            NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"), format: "Text fields can only be added to an alert controller of style ZWAlertControllerStyleAlert", arguments:getVaList([error ?? "nil"]))
            return
        }
        if (textFields == nil) {
            textFields = []
        }
        
        let textField = ZWTextField()
        textField.frame.size = CGSize(width: innerContentWidth, height: textFieldHeight)
        textField.borderStyle = UITextBorderStyle.none
        textField.backgroundColor = textFieldBgColor
        textField.delegate = self
        if textLimit != nil {
            textField.maxBytesLength = Int(textLimit!)
        }
        if ((configurationHandler) != nil) {
            configurationHandler(textField)
        }
        textField.returnKeyType = .done
        textFields!.append(textField)
        textFieldContainerView.addSubview(textField)
    }
    
    open func isAlert() -> Bool { return preferredStyle == .alert || preferredStyle == .simplify }
    fileprivate func isCustomSheet() -> Bool { return preferredStyle == .customActionSheet}
    fileprivate var isCardSheet : Bool {
        get {
            return preferredStyle == .customCardSheet
        }
    }
    fileprivate var isBothCardSheet : Bool {
        get {
            return isCardSheet || isCustomSheet()
        }
    }
    fileprivate var isSimplify : Bool {
        get {
            return preferredStyle == .simplify
        }
    }
    
    // MARK: UITextFieldDelegate Methods
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.canResignFirstResponder) {
            if (currentAction?.handler != nil) {
                currentAction?.handler(currentAction)
            }
            textField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    // MARK: UIViewControllerTransitioningDelegate Methods
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        layoutView()
        return ZWAlertAnimation(isPresenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZWAlertAnimation(isPresenting: false)
    }
}
