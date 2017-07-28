//
//  ShareManager.h
//  ZJHTCarOwner
//
//  Created by liudukun on 2017/5/15.
//
//

#import <Foundation/Foundation.h>
#import "ZJShareView.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"

#define kDefaultIcon @"icon"
#define kAppScheme @"DKGameTactic"

#define kServerCommon @"http://123.207.114.25/DKCommon/key_get.php"


typedef void(^CompletedBlock)(NSString *msg,BOOL succeed);

@interface ShareModel : NSObject

@property(nonatomic,copy)NSString * url;
@property(nonatomic,copy)NSString * content;
//default use imageURL
@property(nonatomic,copy)NSString * imageURL;
@property(nonatomic,copy)NSString * title;

//if no imageURL , default use this image data.
@property(nonatomic,strong)NSData * imageData;

@end



@interface ShareManager : NSObject<WXApiDelegate,QQApiInterfaceDelegate,WeiboSDKDelegate>

@property (nonatomic,strong) ShareModel *share;

//share completed
@property (nonatomic,strong) CompletedBlock completed;

//single instance method
+ (instancetype)manager;

//share main method
+ (void)showShareBoardWithShareModel:(ShareModel *)share completed:(void(^)(NSString *msg,BOOL succeed))completed;

//application launch
- (void)registerSDK;

//application handle open url
- (void)registerHandleOpenURL:(NSURL *)url;

@end
