//
//  DAKeyboardControlScrollView.m
//  DAKeyboardControl
//
//  Created by Daniel Amitay on 2/5/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DAKeyboardControlScrollView.h"

@implementation DAKeyboardControlScrollView

@synthesize keyboardTriggerOffset;

@dynamic delegate;

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if(newWindow)
    {
        // Register for text input notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responderDidBecomeActive:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(responderDidBecomeActive:)
                                                     name:UITextViewTextDidBeginEditingNotification
                                                   object:nil];
        
        // Register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidHide:)
                                                     name:UIKeyboardDidHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        
        // Register for gesture recognizer calls
        if ([self respondsToSelector:@selector(panGestureRecognizer)]) {
            [self.panGestureRecognizer addTarget:self action:@selector(panGestureDidChange)];
        }
    }
    else
    {
        // Unregister for text input notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextFieldTextDidBeginEditingNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UITextViewTextDidBeginEditingNotification
                                                      object:nil];
        
        // Unregister for keyboard notifications
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidShowNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardDidHideNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
        
        // Unregister for gesture recognizer calls
        if ([self respondsToSelector:@selector(panGestureRecognizer)]) {
            [self.panGestureRecognizer removeTarget:self action:@selector(panGestureDidChange)];
        }
    }
}

#pragma mark - Input Notifications

- (void)responderDidBecomeActive:(NSNotification *)notification
{
    activeInput = notification.object;
    if (!activeInput.inputAccessoryView)
    {
        UITextField *textField = (UITextField *)activeInput;
        UIView *nullView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        nullView.backgroundColor = [UIColor clearColor];
        textField.inputAccessoryView = nullView;
        activeInput = (UIResponder *)textField;
    }
}

#pragma mark - Keyboard Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    activeKeyboard  = activeInput.inputAccessoryView.superview;
    originalKeyboardFrame = activeKeyboard.frame;
    activeKeyboard.hidden = NO;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndBoundsWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndBoundsWindow];
    
    CGRect keyboardStartBoundsWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardStartBoundsWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue: &keyboardTransitionDuration];
    
    activeKeyboard.hidden = NO;
    if(self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameWillChange:from:over:)] && !activeKeyboard.hidden)
    {
        [self.delegate keyboardFrameWillChange:keyboardEndBoundsWindow from:activeKeyboard.frame over:keyboardTransitionDuration];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    activeKeyboard.hidden = NO;
    activeKeyboard.userInteractionEnabled = YES;
    activeKeyboard = nil;
}

- (void)keyboardWillHide:(NSNotification *)notification
{    
    CGRect keyboardEndBoundsWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndBoundsWindow];
    
    CGRect keyboardStartBoundsWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardStartBoundsWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue: &keyboardTransitionDuration];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameWillChange:from:over:)] && !activeKeyboard.hidden)
    {
        [self.delegate keyboardFrameWillChange:keyboardEndBoundsWindow from:activeKeyboard.frame over:keyboardTransitionDuration];
    }
}

#pragma mark - Touches Management

- (void)panGestureDidChange
{
    if(!activeKeyboard)
    {
        return;
    }
    
    UIPanGestureRecognizer *gesture = self.panGestureRecognizer;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint touchLocation = [self.panGestureRecognizer locationInView:activeKeyboard];
            
            CGRect newFrame = activeKeyboard.frame;
            CGFloat newY = MAX(activeKeyboard.frame.origin.y + touchLocation.y + keyboardTriggerOffset, originalKeyboardFrame.origin.y);
            newFrame.origin.y = newY;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameWillChange:from:over:)] && !activeKeyboard.hidden)
            {
                [self.delegate keyboardFrameWillChange:newFrame from:activeKeyboard.frame over:0.0f];
            }
            [activeKeyboard setFrame: newFrame];
            
            activeKeyboard.userInteractionEnabled = (originalKeyboardFrame.origin.y == newY);
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (!CGRectEqualToRect(originalKeyboardFrame, activeKeyboard.frame))
            {
                CGRect newFrame = activeKeyboard.frame;
                newFrame.origin.y = activeKeyboard.window.frame.size.height;
                if(self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameWillChange:from:over:)] && !activeKeyboard.hidden)
                {
                    [self.delegate keyboardFrameWillChange:newFrame from:activeKeyboard.frame over:0.25f];
                }
                
                [UIView animateWithDuration:0.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [activeKeyboard setFrame:newFrame];
                                 }
                 
                                 completion:^(BOOL finished){
                                     activeKeyboard.hidden = YES;
                                     [activeInput resignFirstResponder];
                                 }];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            if (!CGRectEqualToRect(originalKeyboardFrame, activeKeyboard.frame))
            {
                CGRect newFrame = activeKeyboard.frame;
                newFrame.origin.y = activeKeyboard.window.frame.size.height;
                if(self.delegate && [self.delegate respondsToSelector:@selector(keyboardFrameWillChange:from:over:)] && !activeKeyboard.hidden)
                {
                    [self.delegate keyboardFrameWillChange:newFrame from:activeKeyboard.frame over:0.25f];
                }
                
                [UIView animateWithDuration:0.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     [activeKeyboard setFrame:newFrame];
                                 }
                 
                                 completion:^(BOOL finished){
                                     activeKeyboard.hidden = YES;
                                     [activeInput resignFirstResponder];
                                 }];
            }
        }
            break;
        default:
            break;
    }
}

@end