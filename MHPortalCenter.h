//
//  MHPortalCenter.h
//  MakeHave
//
//  Created by GSW on 17/11/29.
//  Copyright © 2017年 nebula. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MHPortalSearch = 1, //到搜索页面
    MHPortalOrderlist = 2, //正常页面跳转
    MHPortalMine = 3,
    MHPortalProduct = 4,
    MHPortalTheme = 5,
    MHPortalWeb = 6,
    MHPortalBrand = 7,
    MHPortalHome = 0,
} MHPortal;

@class MHPortalUnit;
@interface MHPortalCenter : NSObject

+ (instancetype)portalCenter;

- (void)portalToUnit:(MHPortalUnit*)unit;
- (void)portalToAim:(MHPortal)portalPage;
- (void)portalToAim:(MHPortal)portalPage params:(NSDictionary*)params;
- (void)portalWithJumpString:(NSString*)string;

@end


@interface MHPortalUnit : NSObject

@property (nonatomic, assign) MHPortal aimType; //到哪个页面
@property (nonatomic, copy) NSDictionary* portalParams; //参数表

//push 时候特有的参数
@property (nonatomic,assign) BOOL isPush;//判断是否是push过来的信息
@property (nonatomic, copy) NSString* pushId;
@property (nonatomic, copy) NSString* message;

+ (instancetype)unitByPushInfo:(NSDictionary*)pushInfo;
+ (instancetype)unitByAim:(MHPortal)aimType withParams:(NSDictionary*)params;
+ (instancetype)unitByJumpString:(NSString*)string;

- (void)run;

@end
