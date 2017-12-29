# ZWAlertController

[![Build](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://travis-ci.org/Initial-C/ZWAlertController)
[![Version](https://img.shields.io/cocoapods/v/ZWAlertController.svg?style=flat)](http://cocoapods.org/pods/ZWAlertController)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![License](https://img.shields.io/cocoapods/l/ZWAlertController.svg?style=flat)](http://cocoapods.org/pods/ZWAlertController)
[![Jianshu](https://img.shields.io/badge/%E7%AE%80%E4%B9%A6-%E9%81%9B%E7%8B%97%E7%9A%84%E7%8C%AB-orange.svg)](http://www.jianshu.com/u/96e1fcfe5d75)

**Made by InitialC**

 Module | Address | Version | Date | Author
:------:|:-------:|:-------:|:----:|:-----:|
ZWAlert&ZWAlertController |  https://github.com/Initial-C/ZWAlertController.git | 0.1.2 | 2017.12.29 | Initial-C

#### ⚠️ **To use with Swift 3.x please ensure you are using == 0.0.8.6** ⚠️ 
#### ⚠️ **To use with Swift 4.x please use 0.1.2 version ** ⚠️ 

__Swift 4.0请使用0.1.2__

__Swift 3.x请使用0.0.8.6__
## Example
&emsp; __0.0.3 version were updated something about limit characters, it can limit the input of Chinese and English Emoji more precisely__

&emsp; __0.0.3 版本已支持ZWAlertController弹出文本输入框下的中英文emoji混输 以及完美支持emoji字符数限制__

&emsp; __0.1.2 版本新增方块样式, 可以在初始化时使用.customActionSheet__
&emsp; __0.1.2 version of the new custom style, you can use.CustomActionSheet at initialization__

&emsp; To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
# ZWAlertController

Simple Alert View written in Swift, which can be used as a UIAlertController replacement.  
It supports from iOS7! It is simple and easily customizable!

![NewCustomForSheetStyle](https://github.com/Initial-C/ZWAlertController/blob/master/Show/CustomActionSheet.gif)
![AlertStyle](https://github.com/Initial-C/ZWAlertController/blob/master/Show/Alert.gif) 
![SheetStyle](https://github.com/Initial-C/ZWAlertController/blob/master/Show/AlertSheet.gif)
![ZWAlert](https://github.com/Initial-C/ZWAlertController/blob/master/Show/ZWAlert.gif)

## Easy to use
ZWAlertController can be used as a `UIAlertController`.
```swift
// Set title, message and alert style
let alertController = ZWAlertController(title: "title", message: "message", preferredStyle: .Alert)
// Create the action.
let cancelAction = ZWAlertAction(title: "Cancel", style: .Cancel, handler: nil)
// You can add plural action.
let okAction = ZWAlertAction(title: "OK" style: .Default) { action in
NSLog("OK action occured.")
}
// Add the action.
alertController.addAction(cancelAction)
alertController.addAction(okAction)
// Show alert
presentViewController(alertController, animated: true, completion: nil)
```

## Customize

* add TextField (Alert style only)
* change Fonts
* change color (Overlay, View, Text, Buttons)

![Custom](https://github.com/Initial-C/ZWAlertController/blob/master/Show/Custom.gif)
![Limit-Entry-Range](https://github.com/Initial-C/ZWAlertController/blob/master/Show/Limit-Entry-Range.gif)

#### Add TextField
```swift
alertController.addTextFieldWithConfigurationHandler { textField in
    // text field(UITextField) setting
    // ex) textField.placeholder = "Password"
    //     textField.secureTextEntry = true
}
alertController.textLimit = 20  // you can limit str length for Chinese or English character, base for English character range
```

#### Change Design
##### Overlay color
```swift
alertController.overlayColor = UIColor(red:235/255, green:245/255, blue:255/255, alpha:0.7)
```
##### Background color
```swift
alertController.alertViewBgColor = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
```
##### Title (font, text color)
```swift
alertController.titleFont = UIFont(name: "GillSans-Bold", size: 18.0)
alertController.titleTextColor = UIColor(red:241/255, green:196/255, blue:15/255, alpha:1)
```
##### Message (font, text color)
```swift
alertController.messageFont = UIFont(name: "GillSans-Italic", size: 15.0)
alertController.messageTextColor = UIColor.whiteColor()
```
##### Button (font, text color, background color(default/highlighted))

```swift
alertController.buttonFont[.Default] = UIFont(name: "GillSans-Bold", size: 16.0)
alertController.buttonTextColor[.Default] = UIColor(red:44/255, green:62/255, blue:80/255, alpha:1)
alertController.buttonBgColor[.Default] = UIColor(red: 46/255, green:204/255, blue:113/255, alpha:1)
alertController.buttonBgColorHighlighted[.Default] = UIColor(red:64/255, green:212/255, blue:126/255, alpha:1)
// Default style : [.Default]
// Cancel style : [.Default] → [.Cancel]
// Destructive style : [.Default] → [.Destructive]
``` 

## Installation
ZWAlertController is available through [CocoaPods](http://cocoapods.org).

To install add the following line to your Podfile:
```
pod 'ZWAlertController'
```

## License
This software is released under the MIT License, see LICENSE.txt.

## Author

Initial-C-William Chang, iwilliamchang@outlook.com

## License

ZWAlertController is available under the MIT license. See the LICENSE file for more info.


