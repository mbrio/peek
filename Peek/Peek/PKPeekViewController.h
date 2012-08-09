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

extern NSString *const PKPVC_MESSAGE_PUSH_DETAIL;
extern NSString *const PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED;
extern NSString *const PKPVC_MESSAGE_PUSH_MASTER;

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

@property (getter=useAnimations, readonly) BOOL useAnimations;
@property (getter=slideOffDetailViewBeforePush, readonly) BOOL slideOffDetailViewBeforePush;

@property (strong, nonatomic) NSString *masterViewControllerIdentifier;
@property (strong, nonatomic) NSString *detailViewControllerIdentifier;

@property (strong, nonatomic) UIViewController *masterViewController;
@property (strong, nonatomic) UIViewController *detailViewController;

@property (weak, nonatomic) id<PKPeekViewControllerDelegate> delegate;

@property (getter=peekViewState, readonly)PKPeekViewControllerState peekViewState;

- (id)initWithMasterViewController:(UIViewController *)masterController
          andDetailViewController:(UIViewController *)detailController;

- (CGRect)masterViewFrame;
- (CGRect)detailViewFrame;
- (CGRect)detailViewPeekFrame;
- (CGRect)detailViewHideFrame;

- (void)peek;
- (void)peekWithAnimation:(BOOL)useAnimation;
- (void)hide;
- (void)hideWithAnimation:(BOOL)useAnimation;
- (void)reveal;
- (void)revealWithAnimation:(BOOL)useAnimation;

+ (void)peek;
+ (void)hide;
+ (void)reveal;
+ (void)pushMasterViewController:(UIViewController *)controller;
+ (void)pushDetailViewController:(UIViewController *)controller;
+ (void)pushDetailViewController:(UIViewController *)controller useAnimation:(BOOL)useAnimation;

@end