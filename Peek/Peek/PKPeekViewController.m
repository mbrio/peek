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

NSString *const PKPVC_MESSAGE_PUSH_DETAIL = @"PKPVC_MESSAGE_PUSH_DETAIL";
NSString *const PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED = @"PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED";
NSString *const PKPVC_MESSAGE_PUSH_MASTER = @"PKPVC_MESSAGE_PUSH_MASTER";

@interface PKPeekViewController () {
    @private

    PKPeekViewControllerState peekViewState;
    BOOL peekViewStateChanging;
}
@end

@implementation PKPeekViewController

#pragma mark - Properties

@synthesize masterViewControllerIdentifier;
@synthesize detailViewControllerIdentifier;

@synthesize masterViewController;
@synthesize detailViewController;

@synthesize delegate;

- (BOOL)useAnimations
{
    return YES;
}

- (BOOL)slideOffDetailViewBeforePush
{
    return YES;
}

- (PKPeekViewControllerState)peekViewState
{
    return peekViewState;
}


#pragma mark - Frames

- (CGRect)masterViewFrame
{
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)detailViewFrame
{
    CGRect f = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)detailViewPeekFrame
{
    CGRect f = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}

- (CGRect)detailViewHideFrame
{
    CGRect f = CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    return f;
}



#pragma mark - Initialization

- (id)initWithMasterViewController:(UIViewController *)masterController
          andDetailViewController:(UIViewController *)detailController
{
    self = [super init];
    
    if (self) {
        self.masterViewController = masterController;
        self.detailViewController = detailController;
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
    self.detailViewController = nil;
    self.masterViewController = nil;
    self.delegate = nil;
}

- (void)initializeControllers
{
    if (!self.masterViewController && self.masterViewControllerIdentifier)
    {
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:self.masterViewControllerIdentifier];
        if (v) self.masterViewController = v;
    }
    
    if (!self.detailViewController && self.detailViewControllerIdentifier)
    {
        UIViewController *v = [self.storyboard instantiateViewControllerWithIdentifier:self.detailViewControllerIdentifier];
        if (v) self.detailViewController = v;
    }
}



#pragma mark - Detail View & Detail Controller

#pragma mark Detail View

- (void)updateDetailViewController:(UIViewController *)controller
{
    UIViewController *prev = self.detailViewController;
    
    if (prev)
    {
        [self removeDetailView];
        [self removeDetailViewController];
    }
    
    self.detailViewController = controller;
    
    [self addDetailViewController];
    [self setupDetailView];
    
    if (prev) {
        self.detailViewController.view.frame = prev.view.frame;
    }
    
    [self addDetailView];
}

- (void)setupDetailView
{
    if (self.detailViewController)
    {        
        self.detailViewController.view.frame = self.detailViewFrame;
        self.detailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)addDetailView
{
    if (self.detailViewController)
    {
        [self.view addSubview:self.detailViewController.view];
    }
}

- (void)removeDetailView
{
    if (self.detailViewController)
    {
        [self.detailViewController.view removeFromSuperview];
    }
}

#pragma mark Detail View Controller

- (void)addDetailViewController
{
    if (self.detailViewController)
    {
        [self addChildViewController:self.detailViewController];
        [self.detailViewController didMoveToParentViewController:self];
    }
}

- (void)removeDetailViewController
{
    [self.detailViewController removeFromParentViewController];
}



#pragma mark - Master View & Master Controller

#pragma mark Master View

- (void)updateMasterViewController:(UIViewController *)controller
{
    UIViewController *prev = self.masterViewController;
    
    if (prev)
    {
        [self removeMasterView];
        [self removeMasterViewController];
    }
    
    self.masterViewController = controller;
    
    [self addMasterViewController];
    [self setupMasterView];
    
    if (prev) {
        self.masterViewController.view.frame = prev.view.frame;
    }
    
    [self addMasterView];
}

- (void)setupMasterView
{
    if (self.masterViewController)
    {
        self.masterViewController.view.frame = self.masterViewFrame;
        self.masterViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
}

- (void)addMasterView
{
    if (self.masterViewController)
    {
        [self.view insertSubview:self.masterViewController.view atIndex:0];
    }
}

- (void)removeMasterView
{
    if (self.masterViewController)
    {
        [self.masterViewController.view removeFromSuperview];
    }
}



#pragma mark Master View Controller

- (void)addMasterViewController
{
    if (self.masterViewController)
    {
        [self addChildViewController:self.masterViewController];
        [self.masterViewController didMoveToParentViewController:self];
    }
}

- (void)removeMasterViewController
{
    [self.masterViewController removeFromParentViewController];
}



#pragma mark - Push Navigation

- (void)pushDetailViewController:(UIViewController *)controller
{
    [self pushDetailViewController:controller useAnimation:NO];
}

- (void)pushDetailViewController:(UIViewController *)controller useAnimation:(BOOL)useAnimation
{
    if (controller)
    {
        BOOL shouldUseAnimation = useAnimation && peekViewState != PKPeekViewControllerStateHide;
        
        if (shouldUseAnimation)
        {
            [self hideWithAnimation:self.useAnimations shouldRevealFirst:self.slideOffDetailViewBeforePush pushController:controller];
        }
        
        else [self updateDetailViewController:controller];
    }
}

- (void)pushMasterViewController:(UIViewController *)controller
{
    if (controller)
    {
        [self updateMasterViewController:controller];
    }
}



#pragma mark - View Load/Unload

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    peekViewState = PKPeekViewControllerStateHide;
    peekViewStateChanging = NO;
    
    [self addDetailViewController];
    [self setupDetailView];
    [self addDetailView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushDetailMessage:) name:PKPVC_MESSAGE_PUSH_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushDetailAnimatedMessage:) name:PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushMasterMessage:) name:PKPVC_MESSAGE_PUSH_MASTER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePeekMessage) name:PKPVC_MESSAGE_PEEK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHideMessage) name:PKPVC_MESSAGE_HIDE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRevealMessage) name:PKPVC_MESSAGE_REVEAL object:nil];;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PUSH_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PUSH_MASTER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_PEEK object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_HIDE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PKPVC_MESSAGE_REVEAL object:nil];
    
    [self removeMasterViewController];
    [self removeDetailViewController];
}



#pragma mark - Message Handlers

- (void)handlePushDetailAnimatedMessage:(NSNotification *)message
{
    [self pushDetailViewController:message.object useAnimation:YES];
}

- (void)handlePushDetailMessage:(NSNotification *)message
{
    [self pushDetailViewController:message.object useAnimation:NO];
}

- (void)handlePushMasterMessage:(NSNotification *)message
{
    [self pushMasterViewController:message.object];
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
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"detailViewController", @"masterViewController", nil];
    
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
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"detailViewController", @"masterViewController", nil];
    
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
    
    NSArray *delegateNames = [NSArray arrayWithObjects:@"delegate", @"detailViewController", @"masterViewController", nil];
    
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
    
    if (CGRectContainsPoint(self.view.frame, frame.origin) && !self.detailViewController.view.superview)
    {
        [self addDetailView];
    }
    
    if (setup) setup();
    
    void (^cleanup)(void) = ^{
        if (completing) completing();
        peekViewStateChanging = NO;
        
        if (!CGRectContainsPoint(self.view.frame, frame.origin))
        {
            [self removeDetailView];
        }
        
        [self slidViewDidChangeStateTo:state];
    };
    
    void (^uiUpdates)(void) = ^{
        self.detailViewController.view.frame = frame;
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
                  withFrame:[self detailViewPeekFrame]
              withAnimation:useAnimation
                      setup: ^{
                          [self addMasterViewController];
                          [self setupMasterView];
                          [self addMasterView];
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
        [self removeMasterView];
        [self removeMasterViewController];
    };
    
    if (isRevealingFirst)
    {
        [self transitionToState:PKPeekViewControllerStateHide
                      withFrame:[self detailViewFrame]
                  withAnimation:useAnimation
                     animations:^(PKPeekViewControllerAnimationBlock animationBlock, PKPeekViewControllerCompletionBlock completionBlock) {                         
                         void (^newAnimationBlock)(void) = ^{
                             self.detailViewController.view.frame = [self detailViewHideFrame];
                         };
                         
                         void (^newCompletionBlock)(BOOL finished) = ^(BOOL finished){
                             if (controller) [self updateDetailViewController:controller];

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
        if (controller) [self updateDetailViewController:controller];
        
        [self transitionToState:PKPeekViewControllerStateHide
                      withFrame:[self detailViewFrame]
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
                  withFrame:[self detailViewHideFrame]
               withAnimation:useAnimation];
}

- (void)revealWithAnimation:(BOOL)useAnimation completing:(void (^)(void))completing
{
    [self transitionToState:PKPeekViewControllerStateReveal
                  withFrame:[self detailViewHideFrame]
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

+ (void)pushMasterViewController:(UIViewController *)controller
{
    [[NSNotificationCenter defaultCenter] postNotificationName:PKPVC_MESSAGE_PUSH_MASTER object:controller];
}

+ (void)pushDetailViewController:(UIViewController *)controller
{
    [PKPeekViewController pushDetailViewController:controller useAnimation:NO];
}

+ (void)pushDetailViewController:(UIViewController *)controller useAnimation:(BOOL)useAnimation
{
    NSString *message = PKPVC_MESSAGE_PUSH_DETAIL;
    if (useAnimation) message = PKPVC_MESSAGE_PUSH_DETAIL_ANIMATED;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:message object:controller];
}

@end