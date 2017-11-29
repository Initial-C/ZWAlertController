//
//  CFashionAlert.swift
//  ZWFashionAlert
//
//  Created by InitialC on 2017/4/11.
//  Copyright © 2017年 InitialC. All rights reserved.
//
import Foundation
import UIKit
import WebKit

public enum FashionStyle {
    case success,warning,exit,none
    case customImg(imageFile:String)
}
public enum FashionTitleType : NSInteger {
    case board, warning, tips
}
public enum FashionBtnType : NSInteger {
    case confirm, cancle, update, other
}
let cFashion = CFashionAlert()
@objc(CFashionAlert)
open class CFashionAlert: UIViewController {
    
    public var isFashionBoard : Bool = false
    let kBackgroundAlpha : CGFloat = 0.7
    let kFashionFont = "PingFang SC"
    let kExitTitleColor = UIColor.colorForRGB(0xFFA500)
    let kExitBtnTitleColor = UIColor.colorForRGB(0x999999)
    
    let kDeviceScreenBounds = UIScreen.main.bounds
    let kDeviceWidth = UIScreen.main.bounds.size.width
    let kDeviceHeight = UIScreen.main.bounds.size.height
    let kDeviceWidthRatio = UIScreen.main.bounds.size.height == 812 ? 1.0 : UIScreen.main.bounds.size.width/375
    let kDeviceHeightRatio = UIScreen.main.bounds.size.height == 812 ? 1.0 : UIScreen.main.bounds.size.height / 667
    var userAction:((_ isClickRightBtn : Bool) -> Void)? = nil
    var contentView = UIView()
    var contentWhiteV = UIView()
    var webView = WKWebView()
    lazy var lBtnView : UIButton = {
        let btnImv = UIButton.init(type: .custom)
        btnImv.setImage(UIImage.init(named: self.getImage("gx_left_a")), for: .normal)
        btnImv.setImage(UIImage.init(named: self.getImage("gx_left_b")), for: .highlighted)
        btnImv.isHidden = true
        btnImv.tag = 0
        return btnImv
    }()
    lazy var rBtnView : UIButton = {
        let btnImv = UIButton.init(type: .custom)
        btnImv.setImage(UIImage.init(named: self.getImage("gx_right_a")), for: .normal)
        btnImv.setImage(UIImage.init(named: self.getImage("gx_right_b")), for: .highlighted)
        btnImv.isHidden = true
        btnImv.tag = 1
        return btnImv
    }()
    var titleImageV = UIImageView()
    var lineView = UIView()
    var contentImV : UIImageView?
    var fashionTitle : UILabel = UILabel()
    var subTitleTextView = SubTextView()
    var buttons = [UIButton]()
    var buttonImgVs = [UIImageView]()
    var strongSelf:CFashionAlert?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
    class open func getFashion() -> CFashionAlert {
        return cFashion
    }
    init() {
        super.init(nibName: nil, bundle: nil)
        self.view.frame = kDeviceScreenBounds
        self.view.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:kBackgroundAlpha)
        self.view.addSubview(contentView)
        
        strongSelf = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isFashionBoard {
            resizeBoardAndReLayout()
        } else {
            resizeAndReLayout()
        }
    }

}
extension CFashionAlert {
    func getImage(_ name: String) -> String {
        let podBundle = Bundle.init(for: CFashionAlert.self)
        guard let bundlePath = podBundle.path(forResource: "ZWAlertController", ofType: "bundle") else {
            return name
        }
        let imgFolder = bundlePath + "/CFashionSources.bundle"
        guard FileManager.default.fileExists(atPath: imgFolder) else {
            return name
        }
        let imgFilePath = imgFolder + "/\(name).png"
        return imgFilePath
    }
    func setupContentView() {
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        contentView.backgroundColor = .clear
        contentView.layer.borderColor = UIColor.colorForRGB(0xCCCCCC).cgColor
        view.addSubview(contentView)
    }
    func setupWebView(_ urlStr : String?) {
        let config = WKWebViewConfiguration.init()
        config.preferences = WKPreferences()
        config.processPool = WKProcessPool()
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.suppressesIncrementalRendering = true
        webView = WKWebView.init(frame: CGRect.zero, configuration: config)
        webView.isOpaque = false
        webView.uiDelegate = nil
        webView.navigationDelegate = nil
        webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal
        if let urlStr = urlStr {
            if urlStr.isEmpty == false {
                webView.load(URLRequest.init(url: URL(string: urlStr)!))
            }
        }
    }
    func setupTitleLabel() {
        fashionTitle.text = ""
        fashionTitle.numberOfLines = 1
        fashionTitle.textAlignment = .center
        fashionTitle.font = UIFont(name: kFashionFont, size:12)
        fashionTitle.textColor = .black
    }
    func setupTitleImage(type : FashionTitleType?) {
        var titleStr : String = ""
        if let type = type {
            switch type {
            case .board:
                titleStr = getImage("gx_gonggao")
                break
            case .tips:
                titleStr = getImage("gx_tishi")
                break
            case .warning:
                titleStr = getImage("gx_jingao")
                break
            }
        }
        titleImageV = UIImageView.init(image: UIImage.init(named: titleStr))
    }
    func setupButtonImage(leftType : FashionBtnType?, rightType : FashionBtnType?) {
        buttonImgVs.removeAll()
        if let lType = leftType {
            lBtnView.isHidden = false
            switch lType {
            case .cancle:
                let button: UIImageView = UIImageView.init(image: UIImage.init(named: getImage("gx_quxiao")))
                button.tag = 226
                buttonImgVs.append(button)
                break
            case .other:
                lBtnView.isHidden = true
                break
            default:
                break
            }
        }
        if let rType = rightType {
            rBtnView.isHidden = false
            var btnImageStr = ""
            switch rType {
            case .confirm:
                btnImageStr = getImage("gx_queren")
                break
            case .update:
                btnImageStr = getImage("gx_gx")
                break
            case .other:
                rBtnView.isHidden = true
                break
            default:
                break
            }
            let button: UIImageView = UIImageView.init(image: UIImage.init(named: btnImageStr))
            button.tag = 227
            buttonImgVs.append(button)
        }
    }
    func setupSubtitleTextView() {
        subTitleTextView.text = ""
        subTitleTextView.textAlignment = .center
        subTitleTextView.font = UIFont(name: kFashionFont, size:12)
        subTitleTextView.textColor = UIColor.colorForRGB(0xffffff)
        subTitleTextView.backgroundColor = .clear
        subTitleTextView.isScrollEnabled = false
        subTitleTextView.isEditable = false
    }
    func resizeAndReLayout() {
        let mainScreenSize = kDeviceScreenBounds.size
        self.view.frame.size = mainScreenSize
        var kContentWidth : CGFloat = kDeviceWidthRatio * 280
        var kContentHeight : CGFloat = kDeviceHeightRatio * 145
        if let imageSize = contentImV?.image?.size {
            kContentWidth = imageSize.width * kDeviceWidthRatio
            kContentHeight = imageSize.height * kDeviceHeightRatio
        }
        let kContentX : CGFloat = (mainScreenSize.width - kContentWidth) * 0.5
        let kContentY : CGFloat = (mainScreenSize.height - kContentHeight) * 0.5
        let kMargin : CGFloat = 14 * kDeviceWidthRatio
        
        contentView.frame = CGRect.init(x: kContentX, y: kContentY, width: kContentWidth, height: kContentHeight)
        contentView.clipsToBounds = false
        
        contentWhiteV.backgroundColor = .white
        contentWhiteV.frame.size = CGSize.init(width: kContentWidth - kMargin * 2, height: kContentHeight - kMargin * 2)
        contentWhiteV.center = CGPoint.init(x: kContentWidth * 0.5, y: kContentHeight * 0.5)
        contentView.addSubview(contentWhiteV)
        
        var kTitleY : CGFloat = subTitleTextView.text.isEmpty ? 48 * kDeviceHeightRatio : 20 * kDeviceHeightRatio
        let kTitleX : CGFloat = 10
        let kTitleW : CGFloat = kContentWidth - kTitleX * 2
        let kTitleH : CGFloat = 20
        if fashionTitle.text?.isEmpty == false {
            fashionTitle.frame = CGRect.init(x: kTitleX, y: kTitleY, width: kTitleW, height: kTitleH)
            contentView.addSubview(fashionTitle)
        }
        
        let kTextViewH : CGFloat = 60
        if subTitleTextView.text.isEmpty == false {
            subTitleTextView.frame = CGRect.init(x: kTitleX + 10, y: fashionTitle.frame.maxY, width: kTitleW - 20, height: kTextViewH)
            var oriSubRect = subTitleTextView.frame
            let subSize = subTitleTextView.sizeThatFits(CGSize.init(width: oriSubRect.width, height: CGFloat(MAXFLOAT)))
            oriSubRect.size.height = subSize.height
            subTitleTextView.frame = oriSubRect
            kTitleY = subTitleTextView.frame.maxY
            contentView.addSubview(subTitleTextView)
        } else {
            kTitleY += 42 * kDeviceHeightRatio
        }
        
        lineView.backgroundColor = .black
        lineView.frame = CGRect.init(x: contentWhiteV.frame.origin.x, y: kTitleY, width: contentWhiteV.frame.width, height: 1.2)
        contentView.addSubview(lineView)
        
        let middleH = kDeviceHeightRatio <= 1.0 ? 20 * kDeviceHeightRatio : 40
        let middleLineV = UIView.init(frame: CGRect.init(x: kContentWidth * 0.5, y: lineView.frame.maxY + 5 * kDeviceHeightRatio, width: 1.2, height: middleH))
        middleLineV.backgroundColor = .black
        middleLineV.isHidden = buttons.count < 2
        contentView.addSubview(middleLineV)
        
        let btnW : CGFloat = contentWhiteV.frame.width / CGFloat(buttons.count)
        let btnH : CGFloat = 35 * kDeviceHeightRatio
        for i in 0 ..< buttons.count {
            buttons[i].frame = CGRect.init(x: btnW * CGFloat(i), y: lineView.frame.maxY - kMargin, width: btnW, height: btnH)
            buttons[i].setTitleColor(kExitBtnTitleColor, for: .normal)
            buttons[i].titleLabel?.font = UIFont.systemFont(ofSize: 12)
            buttons[i].addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
            contentWhiteV.addSubview(buttons[i])
            kContentHeight = buttons[i].frame.maxY + 2 * kMargin + 3 * kDeviceHeightRatio
        }
        if let contentImageV = contentImV {
            contentImageV.frame = CGRect.init(x: 0, y: 0, width: kContentWidth, height: kContentHeight)
            contentImageV.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentImageV.backgroundColor = .clear
            var edgeWH = 20
            if kDeviceHeightRatio > 1 {
                edgeWH = 30
            }
            contentImageV.image = contentImageV.image?.stretchableImage(withLeftCapWidth: edgeWH, topCapHeight: edgeWH)
            contentView.addSubview(contentImageV)
        }
        
        contentWhiteV.frame.size = CGSize.init(width: kContentWidth - kMargin * 2, height: kContentHeight - kMargin * 2)
        contentWhiteV.center = CGPoint.init(x: kContentWidth * 0.5, y: kContentHeight * 0.5)
        contentView.frame = CGRect.init(x: kContentX, y: kContentY, width: kContentWidth, height: kContentHeight)
        
    }
    func resizeBoardAndReLayout() {
        let mainScreenSize = kDeviceScreenBounds.size
        self.view.frame.size = mainScreenSize
        var kContentWidth : CGFloat = kDeviceWidthRatio * 326
        var kContentHeight : CGFloat = kDeviceHeightRatio * 135
        if let imageSize = contentImV?.image?.size {
            kContentWidth = imageSize.width * kDeviceWidthRatio
            kContentHeight = imageSize.height * kDeviceHeightRatio
        }
        let kContentX : CGFloat = (mainScreenSize.width - kContentWidth) * 0.5
        var kContentY : CGFloat = (mainScreenSize.height - kContentHeight) * 0.5
        
        let titleImgW = 33 * kDeviceWidthRatio
        let titleImgH = 16 * kDeviceHeightRatio
        let kTitleX = 22 * kDeviceWidthRatio
        var kTitleY = 59 * kDeviceHeightRatio
        let webH = 240 * kDeviceHeightRatio
        
        titleImageV.frame = CGRect.init(x: (kContentWidth - titleImgW)*0.5, y: 17 * kDeviceHeightRatio, width: titleImgW, height: titleImgH)
        
        let kTextViewH : CGFloat = 60
        if subTitleTextView.text.isEmpty == false {
            subTitleTextView.frame = CGRect.init(x: kTitleX, y: kTitleY, width: kContentWidth - 2*kTitleX, height: kTextViewH)
            var oriSubRect = subTitleTextView.frame
            var subSize = subTitleTextView.sizeThatFits(CGSize.init(width: oriSubRect.width, height: CGFloat(MAXFLOAT)))
            if subSize.height > 200 {
                subTitleTextView.isScrollEnabled = true
                subSize.height = 200
            }
            oriSubRect.size.height = subSize.height
            subTitleTextView.frame = oriSubRect
            kTitleY = subTitleTextView.frame.maxY + 30 * kDeviceHeightRatio
        } else if webView.url?.description.isEmpty == false {
            webView.frame = CGRect.init(x: kTitleX, y: kTitleY, width: kContentWidth - 2*kTitleX, height: webH)
                kTitleY = webView.frame.maxY + 15 * kDeviceHeightRatio
        } else {
            kTitleY += 30 * kDeviceHeightRatio
        }
        
        let bViewW = 157 * kDeviceWidthRatio
        let bViewH = 35 * kDeviceHeightRatio
        lBtnView.frame = CGRect.init(x: 0, y: kTitleY, width: bViewW, height: bViewH)
        rBtnView.frame = CGRect.init(x: kContentWidth - bViewW, y: kTitleY, width: bViewW, height: bViewH)
        if lBtnView.frame.maxY > kContentHeight {
            kContentHeight = lBtnView.frame.maxY
        }
        
        var btnX : CGFloat = 18 * kDeviceWidthRatio
        let btnY : CGFloat = 8 * kDeviceHeightRatio
        let btnW : CGFloat = 29 * kDeviceWidthRatio
        let btnH : CGFloat = 13 * kDeviceHeightRatio
        for i in 0 ..< buttonImgVs.count {
            if buttonImgVs[i].tag == 227 {
                btnX = bViewW - btnX - btnW
            }
            buttonImgVs[i].frame = CGRect.init(x: btnX, y: btnY, width: btnW, height: btnH)
            if buttonImgVs[i].tag == 226 {
                lBtnView.addSubview(buttonImgVs[i])
                lBtnView.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
            } else {
                rBtnView.addSubview(buttonImgVs[i])
                rBtnView.addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
            }
        }
        
        
        if let contentImageV = contentImV {
            contentImageV.frame = CGRect.init(x: 0, y: 0, width: kContentWidth, height: kContentHeight)
            contentImageV.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentImageV.backgroundColor = .clear
            let edgeWH = 0
            contentImageV.image = contentImageV.image?.stretchableImage(withLeftCapWidth: edgeWH, topCapHeight: 50)
            contentView.addSubview(contentImageV)
        }
        
        contentView.addSubview(titleImageV)
        if subTitleTextView.text.isEmpty == false {
            contentView.addSubview(subTitleTextView)
        } else if webView.url?.description.isEmpty == false {
            contentView.addSubview(webView)
        }
        contentView.addSubview(lBtnView)
        contentView.addSubview(rBtnView)
        
        kContentY = (mainScreenSize.height - kContentHeight) * 0.5
        contentView.frame = CGRect.init(x: kContentX, y: kContentY, width: kContentWidth, height: kContentHeight)
        
    }

}
extension CFashionAlert {
    func showFashionToObjc(title: NSString, subTitle: NSString?, leftBtnTitle: NSString?, rightBtnTitle: NSString?, backImageName: NSString, action: ((_ isClickRightBtn: Bool) -> Void)?) {
        showFashion(title: title as String, subTitle: subTitle as String?, leftBtnTitle: leftBtnTitle as String?, rightBtnTitle: rightBtnTitle as String?, type: .customImg(imageFile: backImageName as String), action: action)
    }
    open func showFashion(title: String, subTitle: String?, leftBtnTitle: String?, rightBtnTitle: String?, type: FashionStyle, action: ((_ isClickRightBtn: Bool) -> Void)?) {
        userAction = action
        
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.addSubview(view)
        window.bringSubview(toFront: view)
        view.frame = window.bounds
        self.setupContentView()
        self.setupTitleLabel()
        self.setupSubtitleTextView()
        
        switch type {
        case let .customImg(imageFile):
            if let image = UIImage.init(named: imageFile) {
                contentImV = UIImageView.init(image: image)
            }
            fashionTitle.textColor = kExitTitleColor
        default: break
        }
        fashionTitle.text = title
        if subTitle != nil {
            subTitleTextView.text = subTitle
        }
        buttons.removeAll()
        if leftBtnTitle?.isEmpty == false {
            let button: UIButton = UIButton(type: UIButtonType.custom)
            button.setTitle(leftBtnTitle, for: UIControlState())
            button.isUserInteractionEnabled = true
            button.tag = 0
            buttons.append(button)
        }
        if leftBtnTitle?.isEmpty == false && rightBtnTitle?.isEmpty == false {
            let button: UIButton = UIButton(type: UIButtonType.custom)
            button.setTitle(rightBtnTitle, for: UIControlState())
            button.isUserInteractionEnabled = true
            button.tag = 1
            buttons.append(button)
        }
        resizeAndReLayout()
        animateAlert()
    }
    func showFashionAmazingToObjc(titleType : NSInteger, subtitle: NSString?, leftBtnType: NSInteger, rightBtnType: NSInteger, backImage: UIImage?, action: ((_ isClickRightBtn: Bool) -> Void)?) {
        showFashionAmazing(titleType: FashionTitleType(rawValue: titleType)!, subtitle: subtitle, leftBtnType: FashionBtnType(rawValue: leftBtnType), rightBtnType: FashionBtnType(rawValue: rightBtnType), backImage: backImage, action: action)
    }
    open func showFashionAmazing(titleType : FashionTitleType, subtitle: NSString?, leftBtnType: FashionBtnType?, rightBtnType: FashionBtnType?, backImage: UIImage?, action: ((_ isClickRightBtn: Bool) -> Void)?) {
        userAction = action
        
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.addSubview(view)
        window.bringSubview(toFront: view)
        view.frame = window.bounds
        self.setupContentView()
        self.setupSubtitleTextView()
        self.setupTitleImage(type: titleType)
        if let subTitle = subtitle as String? {
            if subTitle.contains("http") || subTitle.contains("html") {
                self.setupWebView(subTitle)
            } else {
                self.setupSubtitleTextView()
                subTitleTextView.text = subTitle
            }
        }
        if let image = backImage {
            contentImV = UIImageView.init(image: image)
        } else {
            contentImV = UIImageView.init(image: UIImage.init(named: getImage("gx_kuang")))
        }
        self.setupButtonImage(leftType: leftBtnType, rightType: rightBtnType)
        resizeBoardAndReLayout()
        animateAlert()
    }
    
    @objc func pressed(_ sender: UIButton!) {
        if sender.tag == 0 {
            self.closeAlert(sender.tag)
        } else {
            if userAction != nil {
                userAction!(true)
                self.closeAlert(sender.tag)
            }
        }
    }
    func closeAlert(_ buttonIndex:Int) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.view.alpha = 0.0
        }) { (Bool) -> Void in
            self.view.removeFromSuperview()
            self.cleanUpAlert()
            
            //Releasing strong refrence of itself.
            self.strongSelf = nil
        }
    }
    
    func cleanUpAlert() {
        self.contentView.removeFromSuperview()
        self.contentWhiteV.removeFromSuperview()
        self.contentView = UIView()
        self.contentWhiteV = UIView()
        for btn in lBtnView.subviews {
            if btn.tag == 226 {
                btn.removeFromSuperview()
            }
        }
        for btn in rBtnView.subviews {
            if btn.tag == 227 {
                btn.removeFromSuperview()
            }
        }
    }
    
    func animateAlert() {
        
        view.alpha = 0;
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.alpha = 1.0;
        })
        
        let previousTransform = self.contentView.transform
        self.contentView.layer.transform = CATransform3DMakeScale(0.95, 0.95, 0.0);
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.contentView.layer.transform = CATransform3DMakeScale(1.03, 1.03, 0.0);
        }, completion: { (Bool) -> Void in
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
                self.contentView.layer.transform = CATransform3DMakeScale(0.98, 0.98, 0.0);
            }, completion: { (Bool) -> Void in
                UIView.animate(withDuration: 0.1, animations: { () -> Void in
                    self.contentView.layer.transform = CATransform3DMakeScale(1.0, 1.0, 0.0);
                    
                }, completion: { (Bool) -> Void in
                    
                    self.contentView.transform = previousTransform
                })
            })
        })
    }

}
extension UIColor {
    class func colorForRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    class func colorForValue(_ r:CGFloat, _ g:CGFloat, _ b:CGFloat, _ a:CGFloat) -> UIColor{
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }

}
class SubTextView: UITextView {
override var canBecomeFirstResponder: Bool {
    return false
}
override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    let longRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(addGestureRecognizer(_:)))
    longRecognizer.allowableMovement = 100.0
    longRecognizer.minimumPressDuration = 1.0
    self.addGestureRecognizer(longRecognizer)
}

required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) {
        gestureRecognizer.isEnabled = false
    }
    super.addGestureRecognizer(gestureRecognizer)
    }
}
