//
//  PKPeekViewController.h
//  Peek
//
//  Created by Michael Diolosa on 8/1/12.
//  Copyright (c) 2012 Michael Diolosa (@mbrio)
//  Peek may be freely distributed under the MIT license.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

extern NSString *const PKPVC_MESSAGE_PEEK;
extern NSString *const PKPVC_MESSAGE_HIDE;
extern NSString *const PKPVC_MESSAGE_REVEAL;

extern NSString *const PKPVC_MESSAGE_PUSH_FRONT;
extern NSString *const PKPVC_MESSAGE_PUSH_BACK;

typedef enum {
    PKPeekViewControllerStateHide,
    PKPeekViewControllerStatePeek,
    PKPeekViewControllerStateReveal
} PKPeekViewControllerState;

typedef void (^PKPeekViewControllerAnimationBlock)(void);
typedef void (^PKPeekViewControllerCompletionBlock)(BOOL finished);

@class PKPeekViewController;



#pragma mark PKPeekViewControllerDelegate

@protocol PKPeekViewControllerDelegate <NSObject>

@optional

- (BOOL)peekViewControllerShouldPeek:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerWillPeek:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerDidPeek:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;

- (BOOL)peekViewControllerShouldHide:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerWillHide:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerDidHide:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;

- (BOOL)peekViewControllerShouldReveal:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerWillReveal:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;
- (void)peekViewControllerDidReveal:(PKPeekViewController *)peekViewController fromState:(PKPeekViewControllerState)state;

@end



#pragma mark PKPeekViewController

@interface PKPeekViewController : UIViewController

@property (readonly) BOOL useAnimations;
@property (readonly) BOOL slideOffFrontViewBeforePush;

@property (strong, nonatomic) NSString *backViewControllerIdentifier;
@property (strong, nonatomic) NSString *frontViewControllerIdentifier;

@property (strong, nonatomic) UIViewController *backViewController;
@property (strong, nonatomic) UIViewController *frontViewController;

@property (weak, nonatomic) id<PKPeekViewControllerDelegate> delegate;

@property (getter = peekViewState, readonly)PKPeekViewControllerState peekViewState;

- (id)initWithBackController:(UIViewController *)backController
          andFrontController:(UIViewController *)frontController;

- (CGRect)backViewFrame;
- (CGRect)frontViewFrame;
- (CGRect)frontViewPeekingFrame;
- (CGRect)frontViewHiddenFrame;

- (void)peek;
- (void)peekWithAnimation:(BOOL)useAnimation;
- (void)hide;
- (void)hideWithAnimation:(BOOL)useAnimation;
- (void)reveal;
- (void)revealWithAnimation:(BOOL)useAnimation;

+ (void)peek;
+ (void)hide;
+ (void)reveal;
+ (void)pushBackViewController:(UIViewController *)controller;
+ (void)pushFrontViewController:(UIViewController *)controller;

@end