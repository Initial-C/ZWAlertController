//
//  ZWTextField.h
//  Pods
//
//  Created by William Chang on 17/3/10.
//
//

#import <UIKit/UIKit.h>
@class ZWTextField;
typedef NS_ENUM(NSUInteger, ZWTextFieldType){
    ZWTextFieldTypeAny = 0,        //没有限制
    ZWTextFieldTypeOnlyUnsignInt,  //只允许非负整型
    ZWTextFieldTypeOnlyInt,        //只允许整型输入
    ZWTextFieldTypeOnlyChinese,    // 只允许中文
    ZWTextFieldTypeForbidEmoj     //禁止Emoj表情输入
};

typedef NS_ENUM(NSUInteger, ZWTextFieldEvent){
    ZWTextFieldEventBegin,         //准备输入文字
    ZWTextFieldEventInputChar,     //准备输入字符
    ZWTextFieldEventFinish         //输入完成
};
@protocol ZWTextFieldDelegate <NSObject>

@optional

- (BOOL)zwTextFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
- (void)zwTextFieldDidBeginEditing:(UITextField *)textField;           // became first responder
- (BOOL)zwTextFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (void)zwTextFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)zwTextFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0); // if implemented, called in place of textFieldDidEndEditing:

- (BOOL)zwTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text

- (BOOL)zwTextFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)zwTextFieldShouldReturn:(UITextField *)textField;              // called when 'return' key pressed. return NO to ignore.

@end

@interface ZWTextField : UITextField<ZWTextFieldDelegate>

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
 *  代理
 */
@property (nonatomic, weak) id<ZWTextFieldDelegate> zwTFDelegate;
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
