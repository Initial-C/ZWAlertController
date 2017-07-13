//
//  CFashionAlert.swift
//  ZWFashionAlert
//
//  Created by InitialC on 2017/4/11.
//  Copyright © 2017年 InitialC. All rights reserved.
//
import Foundation
import UIKit

public enum FashionStyle {
    case success,warning,exit,none
    case customImg(imageFile:String)
}
let cFashion = CFashionAlert()
open class CFashionAlert: UIViewController {
    
    
    let kBackgroundAlpha : CGFloat = 0.7
    let kFashionFont = "PingFang SC"
    let kExitTitleColor = UIColor.colorForRGB(0xFFA500)
    let kExitBtnTitleColor = UIColor.colorForRGB(0x999999)
    
    let kDeviceScreenBounds = UIScreen.main.bounds
    let kDeviceWidth = UIScreen.main.bounds.size.width
    let kDeviceHeight = UIScreen.main.bounds.size.height
    let kDeviceWidthRatio = UIScreen.main.bounds.size.width / 375
    let kDeviceHeightRatio = UIScreen.main.bounds.size.height / 667
    var userAction:((_ isClickRightBtn : Bool) -> Void)? = nil
    var contentView = UIView()
    var contentWhiteV = UIView()
    var lineView = UIView()
    var contentImV : UIImageView?
    var fashionTitle : UILabel = UILabel()
    var subTitleTextView = UITextView()
    var buttons = [UIButton]()
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
        resizeAndReLayout()
    }

}
extension CFashionAlert {
    func setupContentView() {
        contentView.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        contentView.backgroundColor = .clear
        contentView.layer.borderColor = UIColor.colorForRGB(0xCCCCCC).cgColor
        view.addSubview(contentView)
    }
    func setupTitleLabel() {
        fashionTitle.text = ""
        fashionTitle.numberOfLines = 1
        fashionTitle.textAlignment = .center
        fashionTitle.font = UIFont(name: kFashionFont, size:12)
        fashionTitle.textColor = .black
    }
    func setupSubtitleTextView() {
        subTitleTextView.text = ""
        subTitleTextView.textAlignment = .center
        subTitleTextView.font = UIFont(name: kFashionFont, size:16)
        subTitleTextView.textColor = UIColor.colorForRGB(0x797979)
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

        var kTitleY : CGFloat = kDeviceHeightRatio * 48
        let kTitleX : CGFloat = 10
        let kTitleW : CGFloat = kContentWidth - kTitleX * 2
        let kTitleH : CGFloat = 20
        if fashionTitle.text?.isEmpty == false {
            fashionTitle.frame = CGRect.init(x: kTitleX, y: kTitleY, width: kTitleW, height: kTitleH)
            contentView.addSubview(fashionTitle)
        }
        
        var kTextViewH : CGFloat = 60
        if subTitleTextView.text.isEmpty == false {
            let subtitleString = subTitleTextView.text! as NSString
            let rect = subtitleString.boundingRect(with: CGSize(width: kTitleW, height: 0.0), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:subTitleTextView.font!], context: nil)
            kTitleY += kTitleH + kTitleX
            kTextViewH = ceil(rect.size.height) + 10.0
            subTitleTextView.frame = CGRect(x: kTitleX, y: kContentY, width: kTitleW, height: kTextViewH)
            contentView.addSubview(subTitleTextView)
        }
        
        kTitleY += 42 * kDeviceHeightRatio
        lineView.backgroundColor = .black
        lineView.frame = CGRect.init(x: contentWhiteV.frame.origin.x, y: kTitleY, width: contentWhiteV.frame.width, height: 1.2)
        contentView.addSubview(lineView)
        
        let middleH = kDeviceHeightRatio <= 1.0 ? 20 * kDeviceHeightRatio : 40
        let middleLineV = UIView.init(frame: CGRect.init(x: kContentWidth * 0.5, y: lineView.frame.maxY + 7 * kDeviceHeightRatio, width: 1.2, height: middleH))
        middleLineV.backgroundColor = .black
        contentView.addSubview(middleLineV)
        
        let btnW : CGFloat = contentWhiteV.frame.width / CGFloat(buttons.count)
        let btnH : CGFloat = kContentHeight - lineView.frame.maxY - kMargin
        for i in 0 ..< buttons.count {
            buttons[i].frame = CGRect.init(x: btnW * CGFloat(i), y: contentWhiteV.frame.height - btnH, width: btnW, height: btnH)
            buttons[i].setTitleColor(kExitBtnTitleColor, for: .normal)
            buttons[i].titleLabel?.font = UIFont.systemFont(ofSize: 12)
            buttons[i].addTarget(self, action: #selector(pressed(_:)), for: .touchUpInside)
            contentWhiteV.addSubview(buttons[i])
        }
        
        if let contentImageV = contentImV {
            contentImageV.frame = CGRect.init(x: 0, y: 0, width: kContentWidth, height: kContentHeight)
            contentImageV.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            contentImageV.backgroundColor = .clear
            var edgeWH = 10
            if kDeviceHeightRatio > 1 {
                edgeWH = 30
            }
            contentImageV.image = contentImageV.image?.stretchableImage(withLeftCapWidth: edgeWH, topCapHeight: edgeWH)
            contentView.addSubview(contentImageV)
        }
        
    }

}
extension CFashionAlert {
    open func showFashionToObjc(title: NSString, subTitle: NSString?, leftBtnTitle: NSString?, rightBtnTitle: NSString?, backImageName: NSString, action: ((_ isClickRightBtn: Bool) -> Void)?) {
        showFashion(title: title as String, subTitle: subTitle as? String, leftBtnTitle: leftBtnTitle as? String, rightBtnTitle: rightBtnTitle as? String, type: .customImg(imageFile: backImageName as String), action: action)
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
    
    func pressed(_ sender: UIButton!) {
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
