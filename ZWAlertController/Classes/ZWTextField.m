//
//  ZWTextField.m
//  Pods
//
//  Created by William Chang on 17/3/10.
//
//

#import "ZWTextField.h"

#define isIPhone ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define isIPad   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@implementation NSString (ZWTextField)

-(BOOL) isTextFieldMatchWithRegularExpression:(NSString *)exporession{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",exporession];
    return [predicate evaluateWithObject:self];
}
-(BOOL) isTextFieldIntValue{
    return [self isTextFieldMatchWithRegularExpression:@"[-]{0,1}[0-9]*"];
}
-(BOOL) isTextFieldUnsignedIntValue{
    return [self isTextFieldMatchWithRegularExpression:@"[0-9]+"];
}
-(BOOL) isTextFieldEmoji{
    //因为emoji一直在更新，这个不行
    assert(0);
}
-(BOOL) isTextFieldChinese {
    return [self isTextFieldMatchWithRegularExpression:@"[^\u4e00-\u9fa5]"];
}
//根据正则，过滤特殊字符
- (NSString *)filterCharactor:(NSString *)string withRegex:(NSString *)regexStr{
    NSString *searchText = string;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *result = [regex stringByReplacingMatchesInString:searchText options:NSMatchingReportCompletion range:NSMakeRange(0, searchText.length) withTemplate:@""];
    return result;
}
@end

@interface ZWTextField()<UITextFieldDelegate>
@end

@implementation ZWTextField

-(instancetype)init{
    if (self = [super init]) {
        [self initDefault];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        [self initDefault];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initDefault];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) initDefault{
    [self initData];
    [self setDelegate:self];
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
}

-(void) initData{
    _maxLength = INT_MAX;
    _maxBytesLength = INT_MAX;
}

#pragma mark- UITextField
- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *text = textField.text;
    //    NSLog(@"text:%@",text);
    
    UITextRange *markedRange = [textField markedTextRange];
    UITextPosition *markedPosition = [textField positionFromPosition:markedRange.start offset:0];
    UITextRange *selectedRange = [textField selectedTextRange];
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制,防止中文被截断
    
    if (!markedPosition){
        //---字符处理
        // 中文字符处理
        if (self.inputType == ZWTextFieldTypeOnlyChinese) {
            text = [text filterCharactor:text withRegex:@"[^\u4e00-\u9fa5]"];
            textField.text = text;
        }
        if (text.length > _maxLength){
            //中文和emoj表情存在问题，需要对此进行处理
            NSRange range;
            NSUInteger inputLength = 0;
            for(int i=0; i < text.length && inputLength <= _maxLength; i += range.length) {
                range = [textField.text rangeOfComposedCharacterSequenceAtIndex:i];
                inputLength += [text substringWithRange:range].length;
                if (inputLength > _maxLength) {
                    NSString* newText = [text substringWithRange:NSMakeRange(0, range.location)];
                    textField.text = newText;
                }
            }
        }
        
        //---字节处理
        //Limit
        NSUInteger textBytesLength = [textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
        if (textBytesLength > _maxBytesLength) {
            NSRange range;
            NSUInteger byteLength = 0;
            for(int i=0; i < text.length && byteLength <= _maxBytesLength; i += range.length) {
                range = [textField.text rangeOfComposedCharacterSequenceAtIndex:i];
                byteLength += strlen([[text substringWithRange:range] UTF8String]);
                if (byteLength > _maxBytesLength) {
                    NSString* newText = [text substringWithRange:NSMakeRange(0, range.location)];
                    textField.text = newText;
                }
            }
        }
        
        
        if (selectedRange){
            [textField setSelectedTextRange:selectedRange];
        }
    }
    if (self.textFieldChange) {
        self.textFieldChange(self,textField.text);
    }
}
/**
 *  验证字符串是否符合
 *
 *  @param string 字符串
 *
 *  @return 是否符合
 */
- (BOOL)validateInputString:(NSString *)string textField:(UITextField *)textField{
    switch (self.inputType) {
        case ZWTextFieldTypeOnlyUnsignInt:{
            return [string isTextFieldIntValue];
        }
            break;
        case ZWTextFieldTypeOnlyInt:{
            return [string isTextFieldUnsignedIntValue];
        }
            break;
        case ZWTextFieldTypeForbidEmoj:{
            if ([[[textField textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textField textInputMode] primaryLanguage]){
                return NO;
            }
        }
        default:
            break;
    }
    return YES;
}
-(void)setInputType:(ZWTextFieldType)inputType{
    _inputType = inputType;
    switch (self.inputType) {
        case ZWTextFieldTypeOnlyUnsignInt:
        case ZWTextFieldTypeOnlyInt:
        {
            [self setKeyboardType:UIKeyboardTypeNumberPad];
        }
            break;
        default:{
            [self setKeyboardType:UIKeyboardTypeDefault];
        }
            break;
    }
}

#pragma mark- UITextField Delegate
/*
 1- (BOOL)zwTextFieldShouldBeginEditing:(ZWTextField *)textField;        // return NO to disallow editing.
 2- (void)zwTextFieldDidBeginEditing:(ZWTextField *)textField;           // became first responder
 3- (BOOL)zwTextFieldShouldEndEditing:(ZWTextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
 4- (void)zwTextFieldDidEndEditing:(ZWTextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
 5- (void)zwTextFieldDidEndEditing:(ZWTextField *)textField reason:(UITextFieldDidEndEditingReason)reason NS_AVAILABLE_IOS(10_0); // if implemented, called in place of textFieldDidEndEditing:
 
 6- (BOOL)zwTextField:(ZWTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
 
 7- (BOOL)zwTextFieldShouldClear:(ZWTextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
 8- (BOOL)zwTextFieldShouldReturn:(ZWTextField *)textField;              // called when 'return' key pressed. return NO to ignore.
 */
// 1. return NO to disallow editing.
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldShouldBeginEditing:)]) {
        return [self.zwTFDelegate zwTextFieldShouldBeginEditing:textField];
    } else {
        return YES;
    }
}

// 2. became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(_notifyEvent){
        _notifyEvent(self,ZWTextFieldEventBegin);
    }
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldDidBeginEditing:)]) {
        [self.zwTFDelegate zwTextFieldDidBeginEditing:textField];
    }
}

// 3. return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldShouldEndEditing:)]) {
        return [self.zwTFDelegate zwTextFieldShouldEndEditing:textField];
    } else {
        return YES;
    }
}

// 4. may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(_notifyEvent){
        _notifyEvent(self,ZWTextFieldEventFinish);
    }
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldDidEndEditing:)]) {
        [self.zwTFDelegate zwTextFieldDidEndEditing:textField];
    }
}
// 5.
- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason {
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldDidEndEditing:reason:)]) {
        [self.zwTFDelegate zwTextFieldDidEndEditing:textField reason:reason];
    }
}
// 6. return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString * inputString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(inputString.length > 0){
        BOOL ret = [self validateInputString:inputString textField:textField];
        if (ret && _inputCharacter) {
            _inputCharacter(self, string);
        }
        return ret;
    }
    if (_inputCharacter) {
        _inputCharacter(self, string);
    }
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextField:shouldChangeCharactersInRange:replacementString:)]) {
        return [self.zwTFDelegate zwTextField:textField shouldChangeCharactersInRange:range replacementString:string];
    } else {
        return YES;
    }
}

// 7. called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldShouldClear:)]) {
        return [self.zwTFDelegate zwTextFieldShouldClear:textField];
    } else {
        return YES;
    }
}

// 8. called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(_isResignKeyboardWhenTapReturn){
        [textField resignFirstResponder];
    }
    if ([self.zwTFDelegate respondsToSelector:@selector(zwTextFieldShouldReturn:)]) {
        return  [self.zwTFDelegate zwTextFieldShouldReturn:textField];
    } else {
        return YES;
    }
}

@end
