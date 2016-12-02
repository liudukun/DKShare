//
//  DKShake.h
//  Rice
//
//  Created by liudukun on 15/12/11.
//  Copyright © 2015年 ZengWh. All rights reserved.
//

#import <UIKit/UIKit.h>


// reset self
#define WeChatAppkey @"wx2d21c378ae0894cb"
#define WeiboAppKey @"1272423894"
#define QQAppID @"1105320577"

////APPKEY Secret
//#define WeiBoAppkey @"536737237"
//#define WeiBoAppRedirectURL @"https://api.weibo.com/oauth2/default.html"
//#define WeiBoSecret @"7a936c5a990a50ab80dd6fc264eab0ed"
//
//#define WeChatAppkey @"wxa7fd133f0b047116"
//#define WeChatSecret @"299c0377c4ad0c24cc15bbd933aa2c6a"
//
//#define UMAppKey @"54447462fd98c5a684016d26"
//
#define QQAppkey @"SpfaUMlkHLuFoXWi"
//#define QQAppID @"1104940581"


@interface DKShare : UIView


+(DKShare*)showShareViewWithTurnUrl:(NSString*)url urlImage:(NSString*)imageURL title:(NSString*)title description:(NSString*)description;

+(void)hideShareView;

-(void)setFixedImageData:(UIImage*)image;

@end
