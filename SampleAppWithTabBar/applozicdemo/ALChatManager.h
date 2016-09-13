//
//  ALChatManager.h
//  applozicdemo
//
//  Created by Devashish on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Applozic/ALChatLauncher.h>
#import <Applozic/ALUser.h>
#import <Applozic/ALConversationService.h>
#import <Applozic/ALRegisterUserClientService.h>

#define APPLICATION_ID @"applozic-sample-app"


@interface ALChatManager : NSObject

@property(nonatomic,strong) ALChatLauncher * chatLauncher;

-(instancetype)initWithApplicationKey:(NSString *)applicationKey;

-(void)registerUser:(ALUser * )alUser;

-(void)registerUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion;

@property (nonatomic,retain) NSString * userID;

-(void)launchChat: (UIViewController *)fromViewController;

-(void)launchChatForUserWithDefaultText:(NSString * )userId andFromViewController:(UIViewController*)viewController;

-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController*)viewController forUser:(NSString*)userId withGroupId:(NSNumber*)groupID;

-(void)launchChatForUserWithDisplayName:(NSString * )userId withGroupId:(NSNumber*)groupID andwithDisplayName:(NSString*)displayName andFromViewController:(UIViewController*)fromViewController;

-(void)createAndLaunchChatWithSellerWithConversationProxy:(ALConversationProxy*)alConversationProxy fromViewController:(UIViewController*)fromViewController;

-(void)launchListWithUserORGroup: (NSString *)userId ORWithGroupID: (NSNumber *)groupId andFromViewController:(UIViewController*)fromViewController;

-(BOOL)isUserHaveMessages:(NSString *)userId;

-(NSString *)getApplicationKey;

@end
