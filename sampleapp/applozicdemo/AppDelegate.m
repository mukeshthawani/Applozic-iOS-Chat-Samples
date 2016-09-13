//
//  AppDelegate.m
//  ChatApp
//
//  Copyright (c) 2015 AppLozic. All rights reserved.
//

#import "AppDelegate.h"
#import <Applozic/ALDBHandler.h>
#import <Applozic/ALUserDefaultsHandler.h>
#import <Applozic/ALRegisterUserClientService.h>
#import <Applozic/ALPushNotificationService.h>
#import <Applozic/ALUtilityClass.h>
#import "ApplozicLoginViewController.h"
#import <Applozic/ALAppLocalNotifications.h>

@interface AppDelegate ()

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // checks wheather app version is updated/changed then makes server call setting VERSION_CODE
    [ALRegisterUserClientService isAppUpdated];
    
    ALAppLocalNotifications *localNotification = [ALAppLocalNotifications appLocalNotificationHandler];
    [localNotification dataConnectionNotificationHandler];
    
    if ([ALUserDefaultsHandler isLoggedIn])
    {
        
        [ALPushNotificationService userSync];
        
        // Get login screen from storyboard and present it
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        ApplozicLoginViewController *viewController = (ApplozicLoginViewController *)[storyboard instantiateViewControllerWithIdentifier:@"LaunchChatFromSimpleViewController"];
        [self.window makeKeyAndVisible];
        [self.window.rootViewController presentViewController:viewController
                                                     animated:nil
                                                   completion:nil];
        
        
    }
    
    NSLog(@"launchOptions: %@", launchOptions);
    
    if (launchOptions != nil)
    {
        NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            
            NSLog(@"Launched from push notification: %@", dictionary);
            ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
            BOOL applozicProcessed = [pushNotificationService processPushNotification:dictionary updateUI:[NSNumber numberWithInt:APP_STATE_INACTIVE]];
            if (!applozicProcessed) {
                //Note: notification for app
            }
        }
    }
    
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)dictionary{
    NSLog(@"Received notification WithoutCompletion: %@", dictionary);
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    
    NSLog(@"Received notification Completion: %@", userInfo);
    ALPushNotificationService *pushNotificationService = [[ALPushNotificationService alloc] init];
    [pushNotificationService notificationArrivedToApplication:application withDictionary:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService disconnect];
    
    NSLog(@"APP_ENTER_IN_BACKGROUND");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTER_IN_BACKGROUND" object:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    [registerUserClientService connect];
    [ALPushNotificationService applicationEntersForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [[ALDBHandler sharedInstance] saveContext];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
    NSLog(@" token is: %@", deviceToken);
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSString *apnDeviceToken = hexToken; //[[NSString alloc] initWithData:deviceToken encoding:NSUTF8StringEncoding];
    NSLog(@"apnDeviceToken: %@", hexToken);
    
    
    if ([[ALUserDefaultsHandler getApnDeviceToken] isEqualToString:apnDeviceToken])
    {
        return;
    }
    
    ALRegisterUserClientService *registerUserClientService = [[ALRegisterUserClientService alloc] init];
    
    [registerUserClientService updateApnDeviceTokenWithCompletion:apnDeviceToken withCompletion:^(ALRegistrationResponse *rResponse, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
            
            return ;
        }
        
        NSLog(@"Registration response from server:%@", rResponse);
    }];
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

@end
