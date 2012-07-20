//
//  DAKeyboardControl.h
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 7/14/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DAKeyboardDidMoveBlock)(CGRect keyboardFrameInView);

@interface UIView (DAKeyboardControl)

@property (nonatomic) CGFloat keyboardTriggerOffset;

- (void)addKeyboardPanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock;
- (void)addKeyboardNonpanningWithActionHander:(DAKeyboardDidMoveBlock)didMoveBlock;

- (void)removeKeyboardControl;

- (CGRect)keyboardFrameInView;

@end