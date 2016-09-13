//
//  ALChatManager.m
//  applozicdemo
//
//  Created by Adarsh on 28/12/15.
//  Copyright © 2015 applozic Inc. All rights reserved.
//

#import "ALChatManager.h"
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALMessageClientService.h>
#import "LaunchChatFromSimpleViewController.h"
#import <Applozic/ALApplozicSettings.h>
#import <Applozic/ALChatViewController.h>
#import <Applozic/ALMessage.h>

@implementation ALChatManager

-(instancetype)initWithApplicationKey:(NSString *)applicationKey;
{
    self = [super init];
    if (self)
    {
        [ALUserDefaultsHandler setApplicationKey:applicationKey];
    }
    
    return self;
}

//==============================================================================================================================================
// Call This at time of your app's user authentication OR User registration.
// This will register your User at applozic server.
//==============================================================================================================================================

-(void)registerUser:(ALUser *)alUser
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
    
    //////////////////////////   SET AUTHENTICATION-TYPE-ID FOR INTERNAL USAGE ONLY ////////////////////////
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    ////////////////////////// ////////////////////////// ////////////////////////// ///////////////////////
    
    [self ALDefaultChatViewSettings];
    [alUser setApplicationId:[self getApplicationKey]];
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR_USER_REGISTRATION :: %@",error);
            [ALUtilityClass showAlertMessage:rResponse.message andTitle:@"Response"];
            return;
        }
        
        if([rResponse.message isEqualToString:@"PASSWORD_INVALID"])
        {
            [ALUtilityClass showAlertMessage:@"INAVALID PASSWORD" andTitle:@"ALERT!!!"];
            return;
        }
        
        if(rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
        }
        
        //        if(![ALUserDefaultsHandler getApnDeviceToken]){
        //            [self.chatLauncher registerForNotification];
        //        }
        
        if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
        {
            [self.chatLauncher registerForNotification];
        }
        NSLog(@"USER_REGISTRATION_RESPONSE :: %@", rResponse);
    }];
}

-(NSString *)getApplicationKey
{
    NSString * appKey = [ALUserDefaultsHandler getApplicationKey];
    NSLog(@"APPLICATION_KEY :: %@",appKey);
    return appKey ? appKey : APPLICATION_ID;
}

//==============================================================================================================================================
// Call This method if you want to do some operation on registration success.
// Example: If Chat is your first screen after launch,launch chat list on sucess of login.
//==============================================================================================================================================

-(void)registerUserWithCompletion:(ALUser *)alUser withHandler:(void(^)(ALRegistrationResponse *rResponse, NSError *error))completion
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
    
    //////////////////////////   SET AUTHENTICATION-TYPE-ID FOR INTERNAL USAGE ONLY ////////////////////////
    [ALUserDefaultsHandler setUserAuthenticationTypeId:(short)APPLOZIC];
    ////////////////////////// ////////////////////////// ////////////////////////// ///////////////////////
    
    [self ALDefaultChatViewSettings];
    [alUser setApplicationId:[self getApplicationKey]];
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR_USER_REGISTRATION :: %@",error.description);
            [ALUtilityClass showAlertMessage:rResponse.message andTitle:@"Response"];
            completion(nil, error);
            return;
        }
        
        if([rResponse.message isEqualToString:@"PASSWORD_INVALID"])
        {
            [ALUtilityClass showAlertMessage:@"INAVALID PASSWORD" andTitle:@"ALERT!!!"];
            return;
        }
        
        if(![ALUserDefaultsHandler getApnDeviceToken])
        {
            [self.chatLauncher registerForNotification];
        }
        
        completion(rResponse, error);
        NSLog(@"USER_REGISTRATION_RESPONSE :: %@", rResponse);
    }];
}

//==============================================================================================================================================
// convenient method to launch chat-list, after user registration is done on applozic server.
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
//==============================================================================================================================================

-(void)launchChat: (UIViewController *)fromViewController
{
    [self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:nil withGroupId:nil];
}

//==============================================================================================================================================
// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
//==============================================================================================================================================

-(void)launchChatForUserWithDefaultText:(NSString *)userId andFromViewController:(UIViewController *)fromViewController
{
    [self registerUserAndLaunchChat:nil andFromController:fromViewController forUser:userId withGroupId:nil];
}

//==============================================================================================================================================
// Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
// If user information is not passed, it will try to get user information from getLoggedinUserInformation.
//==============================================================================================================================================

-(void)registerUserAndLaunchChat:(ALUser *)alUser andFromController:(UIViewController *)viewController forUser:(NSString *)userId
                     withGroupId:(NSNumber *)groupID
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
    
    //User is already registered ..directly launch the chat...
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        LaunchChatFromSimpleViewController *lObj = [[LaunchChatFromSimpleViewController alloc] init];
        [lObj.activityView removeFromSuperview];
        
        if(userId)
        {
            [self.chatLauncher launchIndividualChat:userId withGroupId:groupID
                            andViewControllerObject:viewController andWithText:nil];
        }
        else
        {
            NSString * title = viewController.title? viewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:viewController];
        }
        return;
    }
    
    //Registration Required....
    alUser = alUser ? alUser : [ALChatManager getLoggedinUserInformation];
    
    if(!alUser)
    {
        NSLog(@"Not able to find user detail for registration...please register with applozic server first");
        return;
    }
    
    [self ALDefaultChatViewSettings];
    [alUser setApplicationId:[self getApplicationKey]];
    [alUser setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];     // 2. APP_MODULE_NAME setter
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if(error)
        {
            NSLog(@"REGISTRATION_ERROR : %@",error);
            [ALUtilityClass showAlertMessage:rResponse.message andTitle:@"Response: Cant Register User Client"];
            return;
        }
        
        if([rResponse.message isEqualToString:@"PASSWORD_INVALID"])
        {
            [ALUtilityClass showAlertMessage:@"INAVALID PASSWORD" andTitle:@"ALERT!!!"];
            return;
        }
        
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
        }
        
        //        if(![ALUserDefaultsHandler getApnDeviceToken]){
        //            [self.chatLauncher registerForNotification];
        //        }
        
        if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
        {
            [self.chatLauncher registerForNotification];
        }
        
        if(userId)
        {
            [self.chatLauncher launchIndividualChat:userId withGroupId:groupID
                            andViewControllerObject:viewController andWithText:nil];
        }
        else
        {
            NSString * title = viewController.title? viewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:viewController];
        }
        NSLog(@"USER_REGISTRATION_RESPONSE ::%@", rResponse);
    }];
}

-(BOOL)isUserHaveMessages:(NSString *)userId
{
    ALMessageService * msgService = [ALMessageService new];
    NSUInteger count = [msgService getMessagsCountForUser:userId];
    NSLog(@"COUNT MESSAGES :: %lu",(unsigned long)count);
    return (count == 0);
}

//==============================================================================================================================================
// convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
//==============================================================================================================================================

-(void)launchChatForUserWithDisplayName:(NSString *)userId withGroupId:(NSNumber *)groupID andwithDisplayName:(NSString *)displayName
                  andFromViewController:(UIViewController *)fromViewController
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
    
    BOOL flagForText = [self isUserHaveMessages:userId];
    NSString * preText = nil;
    if(flagForText)
    {
        preText = @""; // SET TEXT HERE
    }
    
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName
                        andViewControllerObject:fromViewController andWithText:preText];
        return;
    }
    
    [self ALDefaultChatViewSettings];
    ALUser *alUser = [ALChatManager getLoggedinUserInformation];
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if(error)
        {
            NSLog(@"REGISTRATION_ERROR :: %@",error.description);
            [ALUtilityClass showAlertMessage:rResponse.message andTitle:@"Response: Cant Register User Client"];
            return;
        }
        
        if([rResponse.message isEqualToString:@"PASSWORD_INVALID"])
        {
            [ALUtilityClass showAlertMessage:@"INAVALID PASSWORD" andTitle:@"ALERT!!!"];
            return;
        }
        
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
        }
        
        [self.chatLauncher launchIndividualChat:userId withGroupId:groupID withDisplayName:displayName
                        andViewControllerObject:fromViewController andWithText:preText];
        
        //        if(![ALUserDefaultsHandler getApnDeviceToken]){
        //            [self.chatLauncher registerForNotification];
        //        }
        
        if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
        {
            [self.chatLauncher registerForNotification];
        }
        NSLog(@"USER_REGISTRATION_RESPONSE ::%@", rResponse);
    }];
}

//==============================================================================================================================================
// Convenient method to directly launch individual context-based user chat screen.
// UserId parameter define users for which it intented to launch chat screen.
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
//==============================================================================================================================================

-(void)createAndLaunchChatWithSellerWithConversationProxy:(ALConversationProxy*)alConversationProxy
                                       fromViewController:(UIViewController*)fromViewController
{
    ALConversationService * alconversationService = [[ALConversationService alloc] init];
    [alconversationService  createConversation:alConversationProxy withCompletion:^(NSError *error,ALConversationProxy * proxyObject) {
        
        if(!error)
        {
            self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
            if([ALUserDefaultsHandler getDeviceKeyString])
            {
                ALConversationProxy * finalProxy = [self makeFinalProxyWithGeneratedProxy:alConversationProxy andFinalProxy:proxyObject];
                [self.chatLauncher launchIndividualContextChat:finalProxy andViewControllerObject:fromViewController userDisplayName:@"Adarsh" andWithText:nil];
            }
        }
    }];
}

//==============================================================================================================================================
// The below method combines the conversationID got from server's response with the details already set.
//==============================================================================================================================================

-(ALConversationProxy *)makeFinalProxyWithGeneratedProxy:(ALConversationProxy *)generatedProxy andFinalProxy:(ALConversationProxy *)responseProxy
{
    ALConversationProxy * finalProxy = [[ALConversationProxy alloc] init];
    finalProxy.userId = generatedProxy.userId;
    finalProxy.topicDetailJson = generatedProxy.topicDetailJson;
    finalProxy.Id = responseProxy.Id;
    finalProxy.groupId = responseProxy.groupId;
    return finalProxy;
}

//==============================================================================================================================================
// This method can be used to get app logged-in user's information.
// If user information is stored in DB or preference, Code to get user's information should go here.
// This might be used to get existing user information in case of app update.
//==============================================================================================================================================

+(ALUser *)getLoggedinUserInformation
{
    ALUser *user = [[ALUser alloc] init];
    
    [user setApplicationId:[[[self alloc] init] getApplicationKey]];
    [user setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];      // 3. APP_MODULE_NAME setter
    
    //random userId. Write your logic to get user information here.
    [user setUserId:@"demo-test"];
    //[user setEmailId:[self.emailField text]];
    //[user setPassword:[self.passwordField text]];
    return user;
}

//==============================================================================================================================================
// This method helps you customise various settings
//==============================================================================================================================================

-(void)ALDefaultChatViewSettings
{
    
    /*********************************************  NAVIGATION SETTINGS  ********************************************/
    
    [ALApplozicSettings setStatusBarBGColor:[UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    [ALApplozicSettings setStatusBarStyle:UIStatusBarStyleLightContent];
    /* BY DEFAULT Black:UIStatusBarStyleDefault IF REQ. White: UIStatusBarStyleLightContent  */
    /* ADD property in info.plist "View controller-based status bar appearance" type: BOOLEAN value: NO */
    
    [ALApplozicSettings setColorForNavigation: [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    [ALApplozicSettings setColorForNavigationItem: [UIColor whiteColor]];
    [ALApplozicSettings hideRefreshButton:NO];
    [ALUserDefaultsHandler setNavigationRightButtonHidden:NO];
    [ALUserDefaultsHandler setBottomTabBarHidden:NO];
    [ALApplozicSettings setTitleForConversationScreen:@"Chats"];
    [ALApplozicSettings setCustomNavRightButtonMsgVC:NO];                   /*  SET VISIBILITY FOR REFRESH BUTTON (COMES FROM TOP IN MSG VC)   */
    [ALApplozicSettings setTitleForBackButtonMsgVC:@"Back"];                /*  SET BACK BUTTON FOR MSG VC  */
    [ALApplozicSettings setTitleForBackButtonChatVC:@"Back"];               /*  SET BACK BUTTON FOR CHAT VC */
    /****************************************************************************************************************/
    
    
    /***************************************  SEND RECEIVE MESSAGES SETTINGS  ***************************************/
    
    [ALApplozicSettings setSendMsgTextColor:[UIColor whiteColor]];
    [ALApplozicSettings setReceiveMsgTextColor:[UIColor grayColor]];
    [ALApplozicSettings setColorForReceiveMessages:[UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1]];
    [ALApplozicSettings setColorForSendMessages:[UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]];
    /****************************************************************************************************************/
    
    
    /**********************************************  IMAGE SETTINGS  ************************************************/
    
    [ALApplozicSettings setMaxCompressionFactor:0.1f];
    [ALApplozicSettings setMaxImageSizeForUploadInMB:3];
    [ALApplozicSettings setMultipleAttachmentMaxLimit:5];
    /****************************************************************************************************************/
    
    
    /**********************************************  GROUP SETTINGS  ************************************************/
    
    [ALApplozicSettings setGroupOption:YES];
    [ALApplozicSettings setGroupExitOption:YES];
    [ALApplozicSettings setGroupMemberAddOption:YES];
    [ALApplozicSettings setGroupMemberRemoveOption:YES];
    /****************************************************************************************************************/
    
    
    /******************************************** NOTIIFCATION SETTINGS  ********************************************/
    
    [ALUserDefaultsHandler setDeviceApnsType:(short)DEVELOPMENT];
    //For Distribution CERT::
    //[ALUserDefaultsHandler setDeviceApnsType:(short)DISTRIBUTION];
    
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    [ALApplozicSettings setNotificationTitle:appName];
    
    //    [ALApplozicSettings enableNotification]; //0
    //    [ALApplozicSettings disableNotification]; //2
    //    [ALApplozicSettings disableNotificationSound]; //1                /*  IF NOTIFICATION SOUND NOT NEEDED  */
    //    [ALApplozicSettings enableNotificationSound];//0                   /*  IF NOTIFICATION SOUND NEEDED    */
    /****************************************************************************************************************/
    
    
    /********************************************* CHAT VIEW SETTINGS  **********************************************/
    
    [ALApplozicSettings setVisibilityForNoMoreConversationMsgVC:NO];        /*  SET VISIBILITY NO MORE CONVERSATION (COMES FROM TOP IN MSG VC)  */
    [ALApplozicSettings setEmptyConversationText:@"You have no conversations yet"]; /*  SET TEXT FOR EMPTY CONVERSATION    */
    [ALApplozicSettings setVisibilityForOnlineIndicator:YES];               /*  SET VISIBILITY FOR ONLINE INDICATOR */
    UIColor * sendButtonColor = [UIColor colorWithRed:66.0/255 green:173.0/255 blue:247.0/255 alpha:1]; /*  SET COLOR FOR SEND BUTTON   */
    [ALApplozicSettings setColorForSendButton:sendButtonColor];
    [ALApplozicSettings setColorForTypeMsgBackground:[UIColor clearColor]];     /*  SET COLOR FOR TYPE MESSAGE OUTER VIEW */
    [ALApplozicSettings setMsgTextViewBGColor:[UIColor lightGrayColor]];        /*  SET BG COLOR FOR MESSAGE TEXT VIEW */
    [ALApplozicSettings setPlaceHolderColor:[UIColor grayColor]];               /*  SET COLOR FOR PLACEHOLDER TEXT */
    [ALApplozicSettings setVisibilityNoConversationLabelChatVC:YES];            /*  SET NO CONVERSATION LABEL IN CHAT VC    */
    [ALApplozicSettings setBGColorForTypingLabel:[UIColor colorWithRed:242/255.0 green:242/255.0  blue:242/255.0 alpha:1]]; /*  SET COLOR FOR TYPING LABEL  */
    [ALApplozicSettings setTextColorForTypingLabel:[UIColor colorWithRed:51.0/255 green:51.0/255 blue:51.0/255 alpha:0.5]]; /*  SET COLOR FOR TEXT TYPING LABEL  */
    /****************************************************************************************************************/
    
    
    /********************************************** CHAT TYPE SETTINGS  *********************************************/
    
    [ALApplozicSettings setContextualChat:YES];                                 /*  IF CONTEXTUAL NEEDED    */
    /*  Note: Please uncomment below setter to use app_module_name */
    //   [ALUserDefaultsHandler setAppModuleName:@"<APP_MODULE_NAME>"];
    //   [ALUserDefaultsHandler setAppModuleName:@"SELLER"];
    /****************************************************************************************************************/
    
    
    /*********************************************** CONTACT SETTINGS  **********************************************/
    
    [ALApplozicSettings setFilterContactsStatus:YES];                           /*  IF NEEDED ALL REGISTERED CONTACTS   */
    [ALApplozicSettings setOnlineContactLimit:0];                               /*  IF NEEDED ONLINE USERS WITH LIMIT   */
    /****************************************************************************************************************/
    
    
    /***************************************** TOAST + CALL OPTION SETTINGS  ****************************************/
    
    [ALApplozicSettings setColorForToastText:[UIColor blackColor]];         /*  SET COLOR FOR TOAST TEXT    */
    [ALApplozicSettings setColorForToastBackground:[UIColor grayColor]];    /*  SET COLOR FOR TOAST BG      */
    [ALApplozicSettings setCallOption:YES];                                 /*  IF CALL OPTION NEEDED   */
    /****************************************************************************************************************/
    
    
    /********************************************* DEMAND/MISC SETTINGS  ********************************************/
    
    [ALApplozicSettings setUnreadCountLabelBGColor:[UIColor purpleColor]];
    [ALApplozicSettings setCustomClassName:@"ALChatManager"];                   /*  SET 3rd Party Class Name OR ALChatManager */
    [ALUserDefaultsHandler setFetchConversationPageSize:20];                    /*  SET MESSAGE LIST PAGE SIZE  */ // DEFAULT VALUE 20
    [ALUserDefaultsHandler setUnreadCountType:1];                               /*  SET UNRAED COUNT TYPE   */ // DEFAULT VALUE 0
    [ALApplozicSettings setMaxTextViewLines:4];
    [ALUserDefaultsHandler setDebugLogsRequire:YES];                            /*   ENABLE / DISABLE LOGS   */
    [ALUserDefaultsHandler setLoginUserConatactVisibility:NO];
    [ALApplozicSettings setUserProfileHidden:NO];
    [ALApplozicSettings setFontFace:@"Helvetica"];
    [ALApplozicSettings setChatWallpaperImageName:@"<WALLPAPER NAME>"];
    /****************************************************************************************************************/
    
    
    /***************************************** APPLICATION URL CONFIGURATION  ***************************************/
    
    //    [self getApplicationBaseURL];                                         /* Note: PLEASE DO NOT COMMENT THIS IF ARCHIVING/RELEASING  */
    /****************************************************************************************************************/
    
}

-(void)getApplicationBaseURL
{
    NSDictionary * URLDictionary = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"APPLOZIC_PRODUCTION"];
    
    NSString * alKBASE_URL = [URLDictionary valueForKey:@"AL_KBASE_URL"];
    NSString * alMQTT_URL = [URLDictionary valueForKey:@"AL_MQTT_URL"];
    NSString * alFILE_URL = [URLDictionary valueForKey:@"AL_FILE_URL"];
    NSString * alMQTT_PORT = [URLDictionary valueForKey:@"AL_MQTT_PORT"];
    
    [ALUserDefaultsHandler setBASEURL:alKBASE_URL];
    [ALUserDefaultsHandler setMQTTURL:alMQTT_URL];
    [ALUserDefaultsHandler setFILEURL:alFILE_URL];
    [ALUserDefaultsHandler setMQTTPort:alMQTT_PORT];
}

//==============================================================================================================================================
// Launch chat list with specified User's chat screen open
//==============================================================================================================================================

-(void)launchListWithUserORGroup:(NSString *)userId ORWithGroupID:(NSNumber *)groupId andFromViewController:(UIViewController*)fromViewController
{
    self.chatLauncher = [[ALChatLauncher alloc] initWithApplicationId:[self getApplicationKey]];
    
    //User is already registered ..directly launch the chat...
    if([ALUserDefaultsHandler getDeviceKeyString])
    {
        LaunchChatFromSimpleViewController *lObj = [[LaunchChatFromSimpleViewController alloc] init];
        [lObj.activityView removeFromSuperview];
        
        //Launch
        if(userId || groupId)
        {
            [self.chatLauncher launchChatListWithUserOrGroup:userId withChannel:groupId
                                     andViewControllerObject:fromViewController];
        }
        else
        {
            NSString * title = fromViewController.title? fromViewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:fromViewController];
        }
        return;
    }
    
    //Registration Reuired....
    ALUser *alUser = [ALChatManager getLoggedinUserInformation];
    
    if(!alUser)
    {
        NSLog(@"Not able to find user detail for registration...please register with applozic server first");
        return;
    }
    
    [self ALDefaultChatViewSettings];
    
    [alUser setApplicationId:[self getApplicationKey]];
    [alUser setAppModuleName:[ALUserDefaultsHandler getAppModuleName]];  // 4. APP_MODULE_NAME  setter
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService initWithCompletion:alUser withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        
        if(error)
        {
            NSLog(@"ERROR_USER_REGISTRATION :: %@",error);
            [ALUtilityClass showAlertMessage:rResponse.message andTitle:@"Response"];
            return;
        }
        
        if([rResponse.message isEqualToString:@"PASSWORD_INVALID"])
        {
            [ALUtilityClass showAlertMessage:@"INAVALID PASSWORD" andTitle:@"ALERT!!!"];
            return;
        }
        
        if (rResponse && [rResponse.message containsString: @"REGISTERED"])
        {
            ALMessageClientService *messageClientService = [[ALMessageClientService alloc] init];
            [messageClientService addWelcomeMessage:nil];
        }
        
        //        if(![ALUserDefaultsHandler getApnDeviceToken]){
        //            [self.chatLauncher registerForNotification];
        //        }
        
        if(![[UIApplication sharedApplication] isRegisteredForRemoteNotifications])
        {
            [self.chatLauncher registerForNotification];
        }
        NSLog(@"USER_REGISTRATION_RESPONSE :: %@", rResponse);
        
        //Launch
        if(userId || groupId)
        {
            [self.chatLauncher launchChatListWithUserOrGroup:userId withChannel:groupId
                                     andViewControllerObject:fromViewController];
        }
        else
        {
            NSString * title = fromViewController.title? fromViewController.title: @"< Back";
            [self.chatLauncher launchChatList:title andViewControllerObject:fromViewController];
        }
    }];
}

//==============================================================================================================================================
// DELEGATE FOR THIRD PARTY ACTION ON TAP GESTURE
//==============================================================================================================================================

+(void)handleCustomAction:(UIViewController *)chatView andWithMessage:(ALMessage *)alMessage
{
    NSLog(@"DELEGATE FOR THIRD PARTY ACTION ON TAP GESTURE");
    NSLog(@"ALMESSAGE_META_DATA :: %@", alMessage.metadata);
    //    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    //    UIViewController * customView = [storyboard instantiateViewControllerWithIdentifier:@"CustomVC"];
    //    ALChatViewController * chatVC = (ALChatViewController *)chatView;
    //    [chatVC presentViewController:customView animated:YES completion:nil];
}

@end
