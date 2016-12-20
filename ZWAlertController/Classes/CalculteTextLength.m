//
//  CalculteTextLength.m
//  Pods
//
//  Created by InitialC on 16/12/13.
//
//

#import "CalculteTextLength.h"

@implementation CalculteTextLength

+(int)convertToInt:(NSString*)strtemp {
    
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
    
}

@end
