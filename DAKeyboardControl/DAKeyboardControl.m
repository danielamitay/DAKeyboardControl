//
//  DAKeyboardControl.m
//  DAKeyboardControlExample
//
//  Created by Daniel Amitay on 7/14/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DAKeyboardControl.h"
#import <objc/runtime.h>

static char UIViewKeyboardTriggerOffset;
static char UIViewKeyboardDidMoveBlock;
static char UIViewKeyboardActiveInput;
static char UIViewKeyboardActiveView;
static char UIViewKeyboardPanRecognizer;

@interface UIView (DAKeyboardControl_Internal) <UIGestureRecognizerDelegate>

@property (nonatomic) DAKeyboardDidMoveBlock keyboardDidMoveBlock;
@property (nonatomic, assign) UIResponder *keyboardActiveInput;
@property (nonatomic, assign) UIView *keyboardActiveView;
@property (nonatomic, strong) UIPanGestureRecognizer *keyboardPanRecognizer;

@end

@implementation UIView (DAKeyboardControl)
@dynamic keyboardTriggerOffset;

#pragma mark - Public Methods

- (void)addKeyboardPanningWithActionHandler:(DAKeyboardDidMoveBlock)actionHandler
{
    [self addKeyboardControl:YES actionHandler:actionHandler];
}

- (void)addKeyboardNonpanningWithActionHander:(DAKeyboardDidMoveBlock)actionHandler
{
    [self addKeyboardControl:NO actionHandler:actionHandler];
}

- (void)addKeyboardControl:(BOOL)panning actionHandler:(DAKeyboardDidMoveBlock)actionHandler
{
    self.keyboardDidMoveBlock = actionHandler;
    
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
                                             selector:@selector(inputKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    // For the sake of 4.X compatibility
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillChangeFrame:)
                                                 name:@"UIKeyboardWillChangeFrameNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardDidChangeFrame:)
                                                 name:@"UIKeyboardDidChangeFrameNotification"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputKeyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    if (panning)
    {
        // Register for gesture recognizer calls
        self.keyboardPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(panGestureDidChange:)];
        [self.keyboardPanRecognizer setMinimumNumberOfTouches:1];
        [self.keyboardPanRecognizer setDelegate:self];
        [self addGestureRecognizer:self.keyboardPanRecognizer];
    }
}

- (CGRect)keyboardFrameInView
{
    if (self.keyboardActiveView)
    {
        CGRect keyboardFrameInView = [self convertRect:self.keyboardActiveView.frame
                                              fromView:self.keyboardActiveView.window];
        return keyboardFrameInView;
    }
    else
    {
        CGRect keyboardFrameInView = CGRectMake(0.0f,
                                                [[UIScreen mainScreen] bounds].size.height,
                                                0.0f,
                                                0.0f);
        return keyboardFrameInView;
    }
}

- (void)removeKeyboardControl
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
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidShowNotification
                                                  object:nil];
    
    // For the sake of 4.X compatibility
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardWillChangeFrameNotification"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"UIKeyboardDidChangeFrameNotification"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    // Unregister any gesture recognizer
    [self removeGestureRecognizer:self.keyboardPanRecognizer];
    
    // Release a few properties
    self.keyboardDidMoveBlock = nil;
    self.keyboardActiveInput = nil;
    self.keyboardActiveView = nil;
    self.keyboardPanRecognizer = nil;
}

#pragma mark - Input Notifications

- (void)responderDidBecomeActive:(NSNotification *)notification
{
    // Grab the active input, it will be used to find the keyboard view later on
    self.keyboardActiveInput = notification.object;
    if (!self.keyboardActiveInput.inputAccessoryView)
    {
        UITextField *textField = (UITextField *)self.keyboardActiveInput;
        UIView *nullView = [[UIView alloc] initWithFrame:CGRectZero];
        nullView.backgroundColor = [UIColor clearColor];
        textField.inputAccessoryView = nullView;
        self.keyboardActiveInput = (UIResponder *)textField;
    }
}

#pragma mark - Keyboard Notifications

- (void)inputKeyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    self.keyboardActiveView.hidden = NO;
    
    CGRect keyboardEndFrameView = [self convertRect:keyboardEndFrameWindow fromView:nil];
    
    [UIView animateWithDuration:keyboardTransitionDuration
                          delay:0.0f
                        options:keyboardTransitionAnimationCurve
                     animations:^{
                         if (self.keyboardDidMoveBlock)
                             self.keyboardDidMoveBlock(keyboardEndFrameView);
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)inputKeyboardDidShow:(NSNotification *)notification
{
    // Grab the keyboard view
    self.keyboardActiveView = self.keyboardActiveInput.inputAccessoryView.superview;
    self.keyboardActiveView.hidden = NO;
    
    // If the active keyboard view could not be found (UITextViews...), try again
    if (!self.keyboardActiveView)
    {
        [self.keyboardActiveInput resignFirstResponder];
        [self.keyboardActiveInput becomeFirstResponder];
    }
}

- (void)inputKeyboardWillChangeFrame:(NSNotification *)notification
{
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    CGRect keyboardEndFrameView = [self convertRect:keyboardEndFrameWindow fromView:nil];
    
    [UIView animateWithDuration:keyboardTransitionDuration
                          delay:0.0f
                        options:keyboardTransitionAnimationCurve
                     animations:^{
                         if (self.keyboardDidMoveBlock)
                             self.keyboardDidMoveBlock(keyboardEndFrameView);
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)inputKeyboardDidChangeFrame:(NSNotification *)notification
{
    // Nothing to see here
}

- (void)inputKeyboardWillHide:(NSNotification *)notification
{
    CGRect keyboardEndFrameWindow;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardEndFrameWindow];
    
    double keyboardTransitionDuration;
    [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardTransitionDuration];
    
    UIViewAnimationCurve keyboardTransitionAnimationCurve;
    [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardTransitionAnimationCurve];
    
    CGRect keyboardEndFrameView = [self convertRect:keyboardEndFrameWindow fromView:nil];
    
    [UIView animateWithDuration:keyboardTransitionDuration
                          delay:0.0f
                        options:keyboardTransitionAnimationCurve
                     animations:^{
                         if (self.keyboardDidMoveBlock)
                             self.keyboardDidMoveBlock(keyboardEndFrameView);
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)inputKeyboardDidHide:(NSNotification *)notification
{
    self.keyboardActiveView.hidden = NO;
    self.keyboardActiveView.userInteractionEnabled = YES;
    self.keyboardActiveView = nil;
}

#pragma mark - Touches Management

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // Don't allow panning if inside the active input (unless SELF is a UITextView and the receiving view)
    return (![touch.view isFirstResponder] || ([self isKindOfClass:[UITextView class]] && [self isEqual:touch.view]));
}

- (void)panGestureDidChange:(UIPanGestureRecognizer *)gesture
{
    if(!self.keyboardActiveView || !self.keyboardActiveInput || self.keyboardActiveView.hidden)
    {
        return;
    }
    else
    {
        self.keyboardActiveView.hidden = NO;
    }
    
    CGFloat keyboardViewHeight = self.keyboardActiveView.bounds.size.height;
    CGFloat keyboardWindowHeight = self.keyboardActiveView.window.bounds.size.height;
    CGPoint touchLocationInKeyboardWindow = [gesture locationInView:self.keyboardActiveView.window];
    
    // If touch is inside trigger offset, then disable keyboard input
    if (touchLocationInKeyboardWindow.y > keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset)
    {
        self.keyboardActiveView.userInteractionEnabled = NO;
    }
    else
    {
        self.keyboardActiveView.userInteractionEnabled = YES;
    }
    
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGRect newKeyboardViewFrame = self.keyboardActiveView.frame;
            newKeyboardViewFrame.origin.y = touchLocationInKeyboardWindow.y + self.keyboardTriggerOffset;
            // Bound the keyboard to the bottom of the screen
            newKeyboardViewFrame.origin.y = MIN(newKeyboardViewFrame.origin.y, keyboardWindowHeight);
            newKeyboardViewFrame.origin.y = MAX(newKeyboardViewFrame.origin.y, keyboardWindowHeight - keyboardViewHeight);
            
            // Only update if the frame has actually changed
            if (newKeyboardViewFrame.origin.y != self.keyboardActiveView.frame.origin.y)
            {
                CGRect newKeyboardViewFrameInView = [self convertRect:newKeyboardViewFrame fromView:self.keyboardActiveView.window];
                
                [UIView animateWithDuration:0.0f
                                      delay:0.0f
                                    options:UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     [self.keyboardActiveView setFrame:newKeyboardViewFrame];
                                     if (self.keyboardDidMoveBlock)
                                         self.keyboardDidMoveBlock(newKeyboardViewFrameInView);
                                 }
                                 completion:^(BOOL finished){
                                 }];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            CGRect newKeyboardViewFrame = self.keyboardActiveView.frame;
            BOOL within44Pixels = (touchLocationInKeyboardWindow.y < keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset + 44.0f);
            
            // If the keyboard has only been pushed down 44 pixels, let it pop back up; otherwise, let it drop down
            newKeyboardViewFrame.origin.y = (within44Pixels ? keyboardWindowHeight - keyboardViewHeight : keyboardWindowHeight);
            
            CGRect newKeyboardViewFrameInView = [self convertRect:newKeyboardViewFrame fromView:self.keyboardActiveView.window];
            
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.keyboardActiveView setFrame:newKeyboardViewFrame];
                                 if (self.keyboardDidMoveBlock)
                                     self.keyboardDidMoveBlock(newKeyboardViewFrameInView);
                             }
                             completion:^(BOOL finished){
                                 if (!within44Pixels)
                                 {
                                     self.keyboardActiveView.hidden = YES;
                                     self.keyboardActiveView.userInteractionEnabled = NO;
                                     [self.keyboardActiveInput resignFirstResponder];
                                 }
                             }];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            CGRect newKeyboardViewFrame = self.keyboardActiveView.frame;
            BOOL within44Pixels = (touchLocationInKeyboardWindow.y < keyboardWindowHeight - keyboardViewHeight - self.keyboardTriggerOffset + 44.0f);
            
            // If the keyboard has only been pushed down 44 pixels, let it pop back up; otherwise, let it drop down
            newKeyboardViewFrame.origin.y = (within44Pixels ? keyboardWindowHeight - keyboardViewHeight : keyboardWindowHeight);
            
            CGRect newKeyboardViewFrameInView = [self convertRect:newKeyboardViewFrame fromView:self.keyboardActiveView.window];
            
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.keyboardActiveView setFrame:newKeyboardViewFrame];
                                 if (self.keyboardDidMoveBlock)
                                     self.keyboardDidMoveBlock(newKeyboardViewFrameInView);
                             }
                             completion:^(BOOL finished){
                                 if (!within44Pixels)
                                 {
                                     self.keyboardActiveView.hidden = YES;
                                     self.keyboardActiveView.userInteractionEnabled = NO;
                                     [self.keyboardActiveInput resignFirstResponder];
                                 }
                             }];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Property Methods

- (DAKeyboardDidMoveBlock)keyboardDidMoveBlock
{
    return objc_getAssociatedObject(self,
                                    &UIViewKeyboardDidMoveBlock);
}

- (void)setKeyboardDidMoveBlock:(DAKeyboardDidMoveBlock)keyboardDidMoveBlock
{
    [self willChangeValueForKey:@"keyboardDidMoveBlock"];
    objc_setAssociatedObject(self,
                             &UIViewKeyboardDidMoveBlock,
                             keyboardDidMoveBlock,
                             OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"keyboardDidMoveBlock"];
}

- (CGFloat)keyboardTriggerOffset
{
    NSNumber *keyboardTriggerOffsetNumber = objc_getAssociatedObject(self,
                                                                     &UIViewKeyboardTriggerOffset);
    return [keyboardTriggerOffsetNumber floatValue];
}

- (void)setKeyboardTriggerOffset:(CGFloat)keyboardTriggerOffset
{
    [self willChangeValueForKey:@"keyboardTriggerOffset"];
    objc_setAssociatedObject(self,
                             &UIViewKeyboardTriggerOffset,
                             [NSNumber numberWithFloat:keyboardTriggerOffset],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"keyboardTriggerOffset"];
}

- (UIResponder *)keyboardActiveInput
{
    return objc_getAssociatedObject(self,
                                    &UIViewKeyboardActiveInput);
}

- (void)setKeyboardActiveInput:(UIResponder *)keyboardActiveInput
{
    [self willChangeValueForKey:@"keyboardActiveInput"];
    objc_setAssociatedObject(self,
                             &UIViewKeyboardActiveInput,
                             keyboardActiveInput,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"keyboardActiveInput"];
}

- (UIView *)keyboardActiveView
{
    return objc_getAssociatedObject(self,
                                    &UIViewKeyboardActiveView);
}

- (void)setKeyboardActiveView:(UIView *)keyboardActiveView
{
    [self willChangeValueForKey:@"keyboardActiveView"];
    objc_setAssociatedObject(self,
                             &UIViewKeyboardActiveView,
                             keyboardActiveView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"keyboardActiveView"];
}

- (UIPanGestureRecognizer *)keyboardPanRecognizer
{
    return objc_getAssociatedObject(self,
                                    &UIViewKeyboardPanRecognizer);
}

- (void)setKeyboardPanRecognizer:(UIPanGestureRecognizer *)keyboardPanRecognizer
{
    [self willChangeValueForKey:@"keyboardPanRecognizer"];
    objc_setAssociatedObject(self,
                             &UIViewKeyboardPanRecognizer,
                             keyboardPanRecognizer,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"keyboardPanRecognizer"];
}

@end