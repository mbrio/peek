//
//  PKPeekViewController.m
//  Peek
//
//  Created by Michael Diolosa on 8/1/12.
//  Copyright (c) 2012 Michael Diolosa (@mbrio)
//  Peek may be freely distributed under the MIT license.
//

#import "PKPeekViewController.h"

NSString *const PKPVC_MESSAGE_PEEK = @"PKPVC_MESSAGE_PEEK";
NSString *const PKPVC_MESSAGE_HIDE = @"PKPVC_MESSAGE_HIDE";
NSString *const PKPVC_MESSAGE_REVEAL = @"PKPVC_MESSAGE_REVEAL";

NSString *const PKPVC_MESSAGE_PUSH_FRONT = @"PKPVC_MESSAGE_PUSH_FRONT";
NSString *const PKPVC_MESSAGE_PUSH_BACK = @"PKPVC_MESSAGE_PUSH_BACK";

@interface PKPeekViewController () {
    @private

    PKPeekViewControllerState peekViewState;
    BOOL peekViewStateChanging;
}
@end

@implementation PKPeekViewController

#pragma mark - Properties

@synthesize backViewControllerIdentifier;
@synthesize frontViewControllerIdentifier;

@synthesize backViewController;
@synthesize frontViewController;

@synthesize delegate;

- (BOOL)useAnimations
{
    return YES;
}

- (BOOL)slideOffFrontViewBeforePush
{
    return YES;
}

- (PKPeekViewControllerState)peekViewState
{
    return peekViewState;
}


#pragma mark - Frames

- (CGRect)backViewFrame
{
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)frontViewFrame
{
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)frontViewPeekingFrame
{
    CGRect f = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)frontViewHiddenFrame
{
    CGRect f = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}



#pragma mark - Initialization

- (id)initWithBackController:(UIViewController *)backController
          andFrontController:(UIViewController *)frontController
{
    self = [super init];
    
    if (self) {
        self.backViewController = backController;
        self.frontViewController = frontController;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self initializeControllers];
}

- (void)dealloc
{
    self.frontViewController = nil;
    self.backViewController = nil;
    self.delegate = nil;
}

- (void)initializeControllers
{
    if (!self.backViewController && self.backViewControllerIdentifier)
    {
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:self.backViewControllerIdentifier];
        if (v) self.backViewController = v;
    }
    
    if (!self.frontViewController && self.frontViewControllerIdentifier)
    {
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:self.frontViewControllerIdentifier];
        if (v) self.frontViewController = v;
    }
}



#pragma mark - Front View & Front Controller

#pragma mark Front View

- (void)updateFrontViewController:(UIViewController *)controller
{
    UIViewController *prev = self.frontViewController;
    
    if (prev)
    {
        [self removeFrontView];
        [self removeFrontViewController];
    }
    
    self.frontViewController = controller;
    
    [self addFrontViewController];
    [self setupFrontView];
    
    if (prev) {
        self.frontViewController.view.frame = prev.view.frame;
    }
    
    [self addFrontView];
}

- (void)setupFrontView
{
    if (self.frontViewController)
    {        
        self.frontViewController.view.frame = self.frontViewFrame;
        self.frontViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)addFrontView
{
    if (self.frontViewController)
    {
        [self.view addSubview:self.frontViewController.view];
    }
}

- (void)removeFrontView
{
    if (self.frontViewController)
    {
        [self.frontViewController.view removeFromSuperview];
    }
}

#pragma mark Front View Controller

- (void)addFrontViewController
{
    if (self.frontViewController)
    {
        [self addChildViewController:self.frontViewController];
        [self.frontViewController didMoveToParentViewController:self];
    }
}

- (void)removeFrontViewController
{
    [self.frontViewController removeFromParentViewController];
}



#pragma mark - Back View & Back Controller

#pragma mark Back View

- (void)setupBackView
{
    if (self.backViewController)
    {
        self.backViewController.view.frame = self.backViewFrame;
        self.backViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)addBackView
{
    if (self.backViewController)
    {
        [self.view insertSubview:self.backViewController.view atIndex:0];
    }
}

- (void)removeBackView
{
    if (self.backViewController)
    {
        [self.backViewController.view removeFromSuperview];
    }
}



#pragma mark Back View Controller

- (void)addBackViewController
{
    if (self.backViewController)
    {
        [self addChildViewController:self.backViewController];
        [self.backViewController didMoveToParentViewController:self];
    }
}

- (void)removeBackViewController
{
    [self.backViewController removeFromParentViewController];
}



#pragma mark - Push Navigation

- (void)pushFrontViewController:(UIViewController *)controller
{
    [self hideWithAnimation:self.useAnimations shouldRevealFirst:self.slideOffFrontViewBeforePush pushController:controller];
}

- (void)pushBackViewController:(UIViewController *)controller
{
}



#pragma mark - View Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    peekViewState = PKPeekViewControllerStateHide;
    peekViewStateChanging = NO;
    
    [self addFrontViewController];
    [self setupFrontView];
    [self addFrontView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushFrontMessage:) name:PKPVC_MESSAGE_PUSH_FRONT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushBackMessage:) name:PKPVC_MESSAGE_PUSH_BACK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePeekMessage) name:PKPVC_MESSAGE_PEEK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHideMessage) name:PKPVC_MESSAGE_HIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRevealMessage) name:PKPVC_MESSAGE_REVEAL object:nil];;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PUSH_FRONT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PUSH_BACK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PEEK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_HIDE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_REVEAL object:nil];
    
    [self removeBackViewController];
    [self removeFrontViewController];
}



#pragma mark - Message Handlers

- (void)handlePushFrontMessage:(NSNotification *)message
{
    [self pushFrontViewController:message.object];
}

- (void)handlePushBackMessage:(NSNotification *)message
{
    [self pushBackViewController:message.object];
}

- (void)handlePeekMessage
{
    [self peek];
}

- (void)handleHideMessage
{
    [self hide];
}

- (void)handleRevealMessage
{
    [self reveal];
}



#pragma mark - Should/Will/Did

- (BOOL)slidViewShouldChangeStateTo:(PKPeekViewControllerState)state
{
    if (peekViewStateChanging == YES || peekViewState == state) return NO;
    
    PKPeekViewControllerState prevState = peekViewState;
    
    BOOL should = YES;
    
    SEL selector = nil;
    BOOL (^selectorBlock)(NSObject<PKPeekViewControllerDelegate> *) = nil;
    
    BOOL hiding = state == PKPeekViewControllerStateHide || state == PKPeekViewControllerStateReveal;
    BOOL fullReveal = state == PKPeekViewControllerStateReveal || (prevState == PKPeekViewControllerStateReveal && state == PKPeekViewControllerStatePeek);
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"frontViewController", @"backViewController", nil];
    
    if (fullReveal == YES)
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerShouldReveal:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { return [del peekViewControllerShouldReveal:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerShouldPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { return [del peekViewControllerShouldPeek:self fromState:prevState]; };
        }
    }
    
    else
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerShouldHide:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { return [del peekViewControllerShouldHide:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerShouldPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { return [del peekViewControllerShouldPeek:self fromState:prevState]; };
        }
    }
    
    for (NSString *delName in delegateNames)
    {
        NSObject *del = [self valueForKey:delName];
        
        if (del && [[del class] conformsToProtocol:@protocol(PKPeekViewControllerDelegate)] && [del respondsToSelector:selector])
        {
            NSObject<PKPeekViewControllerDelegate> *qsvDel = (NSObject<PKPeekViewControllerDelegate> *)del;
            
            if ((should = selectorBlock(qsvDel)) == NO) break;
        }
    }
    
    return should;
}

- (void)slidViewWillChangeStateTo:(PKPeekViewControllerState)state
{    
    PKPeekViewControllerState prevState = peekViewState;
    
    SEL selector = nil;
    void (^selectorBlock)(NSObject<PKPeekViewControllerDelegate> *) = nil;
    
    BOOL hiding = state == PKPeekViewControllerStateHide || state == PKPeekViewControllerStateReveal;
    BOOL fullReveal = state == PKPeekViewControllerStateReveal || (prevState == PKPeekViewControllerStateReveal && state == PKPeekViewControllerStatePeek);
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"frontViewController", @"backViewController", nil];
    
    if (fullReveal == YES)
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerWillReveal:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerWillReveal:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerWillPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerWillPeek:self fromState:prevState]; };
        }
    }
    
    else
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerWillHide:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerWillHide:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerWillPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerWillPeek:self fromState:prevState]; };
        }
    }
    
    for (NSString *delName in delegateNames)
    {
        NSObject *del = [self valueForKey:delName];
        
        if (del && [[del class] conformsToProtocol:@protocol(PKPeekViewControllerDelegate)] && [del respondsToSelector:selector])
        {
            NSObject<PKPeekViewControllerDelegate> *qsvDel = (NSObject<PKPeekViewControllerDelegate> *)del;
            selectorBlock(qsvDel);
        }
    }
}

- (void)slidViewDidChangeStateTo:(PKPeekViewControllerState)state
{
    PKPeekViewControllerState prevState = peekViewState;
    peekViewState = state;
    
    SEL selector = nil;
    void (^selectorBlock)(NSObject<PKPeekViewControllerDelegate> *) = nil;
    
    BOOL hiding = state == PKPeekViewControllerStateHide || state == PKPeekViewControllerStateReveal;
    BOOL fullReveal = state == PKPeekViewControllerStateReveal || (prevState == PKPeekViewControllerStateReveal && state == PKPeekViewControllerStatePeek);
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"frontViewController", @"backViewController", nil];
    
    if (fullReveal == YES)
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerDidReveal:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerDidReveal:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerDidPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerDidPeek:self fromState:prevState]; };
        }
    }
    
    else
    {
        if (hiding == YES)
        {
            selector = @selector(peekViewControllerDidHide:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerDidHide:self fromState:prevState]; };
        }
        else
        {
            selector = @selector(peekViewControllerDidPeek:fromState:);
            selectorBlock = ^(NSObject<PKPeekViewControllerDelegate> *del) { [del peekViewControllerDidPeek:self fromState:prevState]; };
        }
    }
    
    for (NSString *delName in delegateNames)
    {
        NSObject *del = [self valueForKey:delName];
        
        if (del && [[del class] conformsToProtocol:@protocol(PKPeekViewControllerDelegate)] && [del respondsToSelector:selector])
        {
            NSObject<PKPeekViewControllerDelegate> *qsvDel = (NSObject<PKPeekViewControllerDelegate> *)del;
            selectorBlock(qsvDel);
        }
    }
}



#pragma mark - Peek/Hide/Reveal

- (void)transitionToState:(PKPeekViewControllerState)state
                withFrame:(CGRect)frame
{
    [self transitionToState:state withFrame:frame withAnimation:self.useAnimations animations:nil setup:nil completing:nil];
}

- (void)transitionToState:(PKPeekViewControllerState)state
                withFrame:(CGRect)frame
             withAnimation:(BOOL)animated
{
    [self transitionToState:state withFrame:frame withAnimation:animated animations:nil setup:nil completing:nil];
}

- (void)transitionToState:(PKPeekViewControllerState)state
                withFrame:(CGRect)frame
            withAnimation:(BOOL)animated
                    setup:(void (^)(void))setup
               completing:(void (^)(void))completing
{
    [self transitionToState:state withFrame:frame withAnimation:animated animations:nil setup:setup completing:completing];
}

- (void)transitionToState:(PKPeekViewControllerState)state
                withFrame:(CGRect)frame
            withAnimation:(BOOL)animated
                animations:(void (^)(PKPeekViewControllerAnimationBlock, PKPeekViewControllerCompletionBlock))animations
                    setup:(void (^)(void))setup
               completing:(void (^)(void))completing
{
    if ([self slidViewShouldChangeStateTo:state] == NO) return;
    peekViewStateChanging = YES;
    
    [self slidViewWillChangeStateTo:state];
    
    if (CGRectContainsPoint(self.view.frame, frame.origin) && !self.frontViewController.view.superview)
    {
        [self addFrontView];
    }
    
    if (setup) setup();
    
    void (^cleanup)(void) = ^{
        if (completing) completing();
        peekViewStateChanging = NO;
        
        if (!CGRectContainsPoint(self.view.frame, frame.origin))
        {
            [self removeFrontView];
        }
        
        [self slidViewDidChangeStateTo:state];
    };
    
    void (^uiUpdates)(void) = ^{
        self.frontViewController.view.frame = frame;
    };
    
    if (animated == YES)
    {
        PKPeekViewControllerAnimationBlock animationBlock = ^{
            uiUpdates();
        };
        
        PKPeekViewControllerCompletionBlock completionBlock = ^(BOOL finished){
            cleanup();
        };
        
        if (animations)
        {
            animations(animationBlock, completionBlock);
        }
        
        else
        {
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:animationBlock
                             completion:completionBlock];
        }
    }
    
    else
    {
        uiUpdates();
        cleanup();
    }
}

- (void)peek
{
    [self peekWithAnimation:self.useAnimations];
}

- (void)peekWithAnimation:(BOOL)useAnimation
{
    [self transitionToState:PKPeekViewControllerStatePeek
                  withFrame:[self frontViewPeekingFrame]
              withAnimation:useAnimation
                      setup: ^{
                          [self addBackViewController];
                          [self setupBackView];
                          [self addBackView];
                      }
                 completing:nil];
}

- (void)hide
{
    [self hideWithAnimation:self.useAnimations shouldRevealFirst:NO pushController:nil];
}

- (void)hideWithAnimation:(BOOL)useAnimation
{
    [self hideWithAnimation:useAnimation shouldRevealFirst:NO pushController:nil];
}

- (void)hideWithAnimation:(BOOL)useAnimation shouldRevealFirst:(BOOL)shouldRevealFirst pushController:(UIViewController *)controller
{
    BOOL isRevealingFirst = peekViewState != PKPeekViewControllerStateReveal && shouldRevealFirst && useAnimation;
    
    void (^completion)(void) = ^{
        [self removeBackView];
        [self removeBackViewController];
    };
    
    if (isRevealingFirst)
    {
        [self transitionToState:PKPeekViewControllerStateHide
                      withFrame:[self frontViewFrame]
                  withAnimation:useAnimation
                     animations:^(PKPeekViewControllerAnimationBlock animationBlock, PKPeekViewControllerCompletionBlock completionBlock) {                         
                         void (^newAnimationBlock)(void) = ^{
                             self.frontViewController.view.frame = [self frontViewHiddenFrame];
                         };
                         
                         void (^newCompletionBlock)(BOOL finished) = ^(BOOL finished){
                             if (controller) [self updateFrontViewController:controller];

                             [UIView animateWithDuration:0.2
                                                   delay:0
                                                 options:UIViewAnimationOptionCurveEaseOut
                                              animations:animationBlock
                                              completion:completionBlock];
                         };
                         
                         [UIView animateWithDuration:0.2
                                               delay:0
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:newAnimationBlock
                                          completion:newCompletionBlock];
                     }
                          setup:nil
                     completing:completion];
    }
    
    else
    {
        if (controller) [self updateFrontViewController:controller];
        
        [self transitionToState:PKPeekViewControllerStateHide
                      withFrame:[self frontViewFrame]
                  withAnimation:useAnimation
                          setup:nil
                     completing:^{
                         completion();
                     }];
    }
}

- (void)reveal
{
    [self revealWithAnimation:self.useAnimations];
}

- (void)revealWithAnimation:(BOOL)useAnimation
{
    [self transitionToState:PKPeekViewControllerStateReveal
                  withFrame:[self frontViewHiddenFrame]
               withAnimation:useAnimation];
}

- (void)revealWithAnimation:(BOOL)useAnimation completing:(void (^)(void))completing
{
    [self transitionToState:PKPeekViewControllerStateReveal
                  withFrame:[self frontViewHiddenFrame]
              withAnimation:useAnimation
                      setup:nil
                completing:completing];
}

#pragma mark - Class Methods

+ (void)peek
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_PEEK object:nil];
}

+ (void)hide
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_HIDE object:nil];
}

+ (void)reveal
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_REVEAL object:nil];
}

+ (void)pushBackViewController:(UIViewController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_PUSH_BACK object:controller];
}

+ (void)pushFrontViewController:(UIViewController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_PUSH_FRONT object:controller];
}

@end