//
//  ZWTextField.h
//  Pods
//
//  Created by William Chang on 17/3/10.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ZWTextFieldType){
    ZWTextFieldTypeAny = 0,        //没有限制
    ZWTextFieldTypeOnlyUnsignInt,  //只允许非负整型
    ZWTextFieldTypeOnlyInt,        //只允许整型输入
    ZWTextFieldTypeForbidEmoj,     //禁止Emoj表情输入
};

typedef NS_ENUM(NSUInteger, ZWTextFieldEvent){
    ZWTextFieldEventBegin,         //准备输入文字
    ZWTextFieldEventInputChar,     //准备输入字符
    ZWTextFieldEventFinish         //输入完成
};

@interface ZWTextField : UITextField

/**
 *  如果按了return需要让键盘收起
 */
@property(nonatomic,assign) BOOL isResignKeyboardWhenTapReturn;
/**
 *  输入类型
 */
@property(nonatomic,assign) ZWTextFieldType inputType;

/**
 *  最大字符数
 */
@property(nonatomic,assign) NSInteger maxLength;

/**
 *  最大字节数
 */
@property(nonatomic,assign) NSInteger maxBytesLength;


/**
 *  中文联想，字符改变的整个字符串回调
 */
@property (nonatomic,copy) void (^textFieldChange)(ZWTextField *textField, NSString *string);
/**
 *  成功输入一个字符的回调
 */
@property (nonatomic,copy) void (^inputCharacter)(ZWTextField *textField, NSString *string);

/**
 *  控件状态变化的事件回调
 */
@property (nonatomic,copy) void (^notifyEvent)(ZWTextField *textField, ZWTextFieldEvent event);

@end
