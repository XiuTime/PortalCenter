//
//  MHPortalCenter.m
//  MakeHave
//
//  Created by GSW on 17/11/29.
//  Copyright © 2017年 nebula. All rights reserved.
//

#import "MHPortalCenter.h"

#import "MHAppDelegate.h"
#import "DVNavController.h"
#import "MHTabbarController.h"


#import "MHSearchVC.h"
#import "MHSearchResultVC.h"
#import "MHProductDetailVC.h"
#import "MHThemeDetailVC.h"
#import "MHBrandDetailVC.h"
#import "MHShowcaseEngine.h"
#import "MHBrandEngine.h"
#import "MHCommonwebVC.h"

@implementation MHPortalCenter

+ (instancetype)portalCenter
{
    static MHPortalCenter* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (void)portalWithJumpString:(NSString*)string
{
    MHPortalUnit *unit = [MHPortalUnit unitByJumpString:string];
    [self portalToUnit:unit];
}
- (void)portalToAim:(MHPortal)portalPage {
    [self portalToAim:portalPage params:nil];
}

- (void)portalToAim:(MHPortal)portalPage params:(NSDictionary*)params {
    MHPortalUnit *unit = [MHPortalUnit unitByAim:portalPage withParams:params];
    [self portalToUnit:unit];
}

- (void)portalToUnit:(MHPortalUnit*)unit
{
    //push的话，需要在这里加一层逻辑判断
    if (unit) {
        [unit run];
    }
}

@end

@implementation MHPortalUnit

+ (instancetype)unitByPushInfo:(NSDictionary*)pushInfo{
    if (pushInfo[@"aps"] && pushInfo[@"pushId"]) {
        return [[self alloc] initWithRemoteInfo:pushInfo];
    }
    return nil;
}

- (id)initWithRemoteInfo:(NSDictionary*)info
{
    self = [super init];
    if (self) {
        _message = info[@"aps"][@"alert"];
        _pushId = info[@"pushId"];
        _aimType = [info[@"type"] intValue];
        _portalParams = [info[@"url"] parseURLParams];
    }
    return self;
}

+ (instancetype)unitByAim:(MHPortal)aimType withParams:(NSDictionary*)params {
    MHPortalUnit *unit = [[MHPortalUnit alloc] init];
    unit.aimType = aimType;
    unit.portalParams = params;
    return unit;
}

+ (instancetype)unitByJumpString:(NSString*)string {
    MHPortalUnit *unit = [[MHPortalUnit alloc] init];
    if ([string hasPrefix:@"product"]) {
        unit.aimType = MHPortalProduct;
    }
    if ([string hasPrefix:@"brand"]) {
        unit.aimType = MHPortalBrand;
    }
    if ([string hasPrefix:@"article"]) {
        unit.aimType = MHPortalTheme;
    }
    if ([string hasPrefix:@"search"]) {
        unit.aimType = MHPortalSearch;
    }
    if ([string hasPrefix:@"jump"]) {
        unit.aimType = MHPortalWeb;
    }
    unit.portalParams = [string parseURLParams];
    return unit;
}

- (void) run
{
    UIViewController *currentVC = [self currentTopVC];
    
    switch (_aimType) {
            
        case MHPortalSearch:{
            
//            if (([currentVC isKindOfClass:[MHSearchResultVC class]])
//                || ([currentVC isKindOfClass:[MHSearchVC class]])) {
//                //当前已然是search页，就不用跳了
//                return;
//            }
            
            [self resetCurrentViewHierarchy];
            currentVC = [self currentTopVC];
            GotoSearchVCsearch(currentVC,_portalParams[@"keyword"]);
            
        }break;
            
        case MHPortalHome:{
            [self resetCurrentViewHierarchy];
            
            MHTabbarController *tabVC = (MHTabbarController*)((MHAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
            tabVC.selectedIndex = 0;
            
        }break;
        case MHPortalProduct:{
            [self resetCurrentViewHierarchy];
            
            currentVC = [self currentTopVC];
            GotoProdDetail(currentVC, [_portalParams[@"id"] intValue]);

            
        }break;
        case MHPortalTheme:{
            [self resetCurrentViewHierarchy];
            currentVC = [self currentTopVC];
            [MHShowcaseEngine fetchPushByType:_portalParams[@"card_type"] CardID:_portalParams[@"card_id"] finished:^(MHShowcase*showcase,DVError*error){
                GotoThemeDetail(currentVC, showcase);
            }];
        }break;
        case MHPortalBrand:{
            [self resetCurrentViewHierarchy];
            currentVC = [self currentTopVC];
            GotoBrandDetail(currentVC, [_portalParams[@"id"] intValue]);
        }break;
        case MHPortalWeb:{
            [self resetCurrentViewHierarchy];
            currentVC = [self currentTopVC];
            GotoWebVC(currentVC,_portalParams[@"url"]);
        }break;
            
        default:
            break;
    }
}

- (UIViewController*)currentTopVC{
    MHTabbarController *tabVC = (MHTabbarController*)((MHAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
    DVNavController *nav = tabVC.selectedViewController;
    UIViewController *topVC = nav.visibleViewController;
    return topVC;
    
//    UIViewController *topVC = nav.topViewController;
////    topVC = nav.visibleViewController;
//    if (topVC.presentedViewController) {
//        return topVC.presentingViewController;
////        return topVC.presentedViewController;
//    }else{
//        return topVC;
//    }
}

- (void)resetCurrentViewHierarchy {
    MHTabbarController *tabVC = (MHTabbarController*)((MHAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
    
    [(DVNavController *)tabVC.selectedViewController popToRootViewControllerAnimated:NO];
    
    if ([(DVNavController *)tabVC.selectedViewController presentedViewController]) {
        [(DVNavController *)tabVC.selectedViewController dismissViewControllerAnimated:NO completion:nil];
    }
}


@end
