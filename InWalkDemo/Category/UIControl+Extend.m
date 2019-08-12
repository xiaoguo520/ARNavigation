//
//  UIControl+Extend.m
//  patient
//
//  Created by 新开元 iOS on 16/10/19.
//  Copyright © 2016年 com.xky.app. All rights reserved.
//

#import "UIControl+Extend.h"


#pragma mark - UIControl+Extend
@implementation UIControl (GlobalExtend)
- (void)addControlEvent:(UIControlEvents)event withBlock:(void(^)(id sender))block{
    NSString *methodName = [self eventName:event];
    if (block) self.elementDic[@"block"] = block;
    [self addTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
    
}
- (void)removeControlEvent:(UIControlEvents)event{
    NSString *methodName = [self eventName:event];
    [self removeElement:@"block"];
    [self removeTarget:self action:NSSelectorFromString(methodName) forControlEvents:event];
}
- (NSString*)eventName:(UIControlEvents)event{
    switch (event) {
        case UIControlEventTouchDown:			return @"UIControlEventTouchDown";
        case UIControlEventTouchDownRepeat:		return @"UIControlEventTouchDownRepeat";
        case UIControlEventTouchDragInside:		return @"UIControlEventTouchDragInside";
        case UIControlEventTouchDragOutside:	return @"UIControlEventTouchDragOutside";
        case UIControlEventTouchDragEnter:		return @"UIControlEventTouchDragEnter";
        case UIControlEventTouchDragExit:		return @"UIControlEventTouchDragExit";
        case UIControlEventTouchUpInside:		return @"UIControlEventTouchUpInside";
        case UIControlEventTouchUpOutside:		return @"UIControlEventTouchUpOutside";
        case UIControlEventTouchCancel:			return @"UIControlEventTouchCancel";
        case UIControlEventValueChanged:		return @"UIControlEventValueChanged";
        case UIControlEventEditingDidBegin:		return @"UIControlEventEditingDidBegin";
        case UIControlEventEditingChanged:		return @"UIControlEventEditingChanged";
        case UIControlEventEditingDidEnd:		return @"UIControlEventEditingDidEnd";
        case UIControlEventEditingDidEndOnExit:	return @"UIControlEventEditingDidEndOnExit";
        case UIControlEventAllTouchEvents:		return @"UIControlEventAllTouchEvents";
        case UIControlEventAllEditingEvents:	return @"UIControlEventAllEditingEvents";
        case UIControlEventApplicationReserved:	return @"UIControlEventApplicationReserved";
        case UIControlEventSystemReserved:		return @"UIControlEventSystemReserved";
        case UIControlEventAllEvents:			return @"UIControlEventAllEvents";
        default:								return @"description";
    }
    return @"description";
}
- (void)UIControlEventTouchDown{[self callActionBlocks:UIControlEventTouchDown];}
- (void)UIControlEventTouchDownRepeat{[self callActionBlocks:UIControlEventTouchDownRepeat];}
- (void)UIControlEventTouchDragInside{[self callActionBlocks:UIControlEventTouchDragInside];}
- (void)UIControlEventTouchDragOutside{[self callActionBlocks:UIControlEventTouchDragOutside];}
- (void)UIControlEventTouchDragEnter{[self callActionBlocks:UIControlEventTouchDragEnter];}
- (void)UIControlEventTouchDragExit{[self callActionBlocks:UIControlEventTouchDragExit];}
- (void)UIControlEventTouchUpInside{
    
    [self callActionBlocks:UIControlEventTouchUpInside];
}
- (void)UIControlEventTouchUpOutside{[self callActionBlocks:UIControlEventTouchUpOutside];}
- (void)UIControlEventTouchCancel{[self callActionBlocks:UIControlEventTouchCancel];}
- (void)UIControlEventValueChanged{[self callActionBlocks:UIControlEventValueChanged];}
- (void)UIControlEventEditingDidBegin{[self callActionBlocks:UIControlEventEditingDidBegin];}
- (void)UIControlEventEditingChanged{[self callActionBlocks:UIControlEventEditingChanged];}
- (void)UIControlEventEditingDidEnd{[self callActionBlocks:UIControlEventEditingDidEnd];}
- (void)UIControlEventEditingDidEndOnExit{[self callActionBlocks:UIControlEventEditingDidEndOnExit];}
- (void)UIControlEventAllTouchEvents{[self callActionBlocks:UIControlEventAllTouchEvents];}
- (void)UIControlEventAllEditingEvents{[self callActionBlocks:UIControlEventAllEditingEvents];}
- (void)UIControlEventApplicationReserved{[self callActionBlocks:UIControlEventApplicationReserved];}
- (void)UIControlEventSystemReserved{[self callActionBlocks:UIControlEventSystemReserved];}
- (void)UIControlEventAllEvents{[self callActionBlocks:UIControlEventAllEvents];}
- (void)callActionBlocks:(UIControlEvents)event{
    void(^block)(id sender) = self.elementDic[@"block"];
    if (block) block(self);
    //置空！避免循环引用
//    if(block){
//        self.element[@"block"] = nil;
//    }
}
@end
