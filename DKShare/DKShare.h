//
//  DKShake.h
//  Rice
//
//  Created by liudukun on 15/12/11.
//  Copyright © 2015年 ZengWh. All rights reserved.
//

#import <UIKit/UIKit.h>


#define WeChatAppkey @""
#define WeChatAppkey @""
#define QQAppID @""



@interface DKShare : UIView


+(DKShare*)showShareViewWithTurnUrl:(NSString*)url vc:(UIViewController *)vc urlImage:(NSString*)imageURL title:(NSString*)title description:(NSString*)description;

+(void)hideShareView;

-(void)setFixedImageData:(UIImage*)image;

@end
