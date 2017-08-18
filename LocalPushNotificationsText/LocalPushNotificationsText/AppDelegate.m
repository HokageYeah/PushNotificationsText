//
//  AppDelegate.m
//  LocalPushNotificationsText
//
//  Created by 余晔 on 2017/5/8.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import "AppDelegate.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate



//---------------------------------简书地址：http://www.jianshu.com/p/3d602a60ca4f-------------------------------------------------------


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    //注册通知
    if([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
    { //ios10持有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //必须携带里，不然无法监听同志的接受与点击
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error)
        {
             if(granted)
             {
                 //点击允许
                 NSLog(@"注册成功");
                 [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings)
                  {
                      NSLog(@"%@",settings);
                  }];
             }
             else
             {
                 //点击不允许
                 NSLog(@"注册失败");
             }
         }];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] > 8.0)
    {
        //ios 8 - ios 10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0)
    {
        //ios8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    
    //注册获得注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];

    
    
    
    
    
    
    
    
    
    
   //1.创建通知内容
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc]init];
    content.title = @"你大爷来测试了";
    content.subtitle = @"测试通知";
    content.body = @"都是我的,你也是我的";
    content.badge = @1;
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle]pathForResource:@"image_goldenusericon@2x" ofType:@"png"];
    //2.设置通知附件内容
    UNNotificationAttachment *att = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
    if(error)
    {
        NSLog(@"attachment error %@", error);
    }
    content.attachments = @[att];
    content.launchImageName = @"image_goldenusericon@2x";
    // 2.设置声音
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    
    //3.出发模式
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    
    //4.设置UNNotificationRequest
    NSString *requestIdentifer = @"TestRequest";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:trigger];
    
    //5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error)
    {
        NSLog(@"%@",error);
    }];
    
    
//    // 使用 UNUserNotificationCenter 来管理通知
//    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//    
//    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
//    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
//    content.title = [NSString localizedUserNotificationStringForKey:@"Hello!" arguments:nil];
//    content.body = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
//                                                         arguments:nil];
//    content.sound = [UNNotificationSound defaultSound];
//    
//    // 在 alertTime 后推送本地推送
//    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
//                                                  triggerWithTimeInterval:10 repeats:NO];
//    
//    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
//                                                                          content:content trigger:trigger];
//    
//    //添加推送成功后的处理！
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//        [alert addAction:cancelAction];
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
//    }];
    
    return YES;
}



//获得Device Token
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%@",[NSString stringWithFormat:@"Device Token: %@",deviceToken]);
}

//获得Device Token失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}



//iOS 10 Support收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    NSDictionary *userinfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request; //收到推送的请求
    UNNotificationContent *content = request.content; //收到推送的消息内容
    NSNumber *badge = content.badge; //推送消息的角标
    NSString *body = content.body; //推送消息体
    UNNotificationSound *sound = content.sound; //推送消息的声音
    NSString *subtitle = content.subtitle; //推送消息的副标题
    NSString *title = content.title; //推送消息的标题
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        NSLog(@"IOS10 前台收到远程通知：%@",userinfo);
    }
    else
    {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userinfo);
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

//iOS 10 Support  通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler
{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]])
    {
        NSLog(@"iOS10 收到远程通知:%@", userInfo);
        
    }
    else
    {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"iOS6及以下系统，收到通知:%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"iOS7及以上系统，收到通知:%@",userInfo);
    completionHandler(UIBackgroundFetchResultNewData);
}







- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
