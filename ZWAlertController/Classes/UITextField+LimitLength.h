//
//  UITextField+LimitLength.h
//  Pods
//
//  Created by InitialC on 16/12/13.
//
//

#import <UIKit/UIKit.h>

@interface UITextField (LimitLength)
/**
 *  支持汉字。汉字占2个长度
 *
 *  @param length
 */
- (void)limitTextLength:(int)length;
// 抖动效果
- (void)shake;

@end
