//
//  DKShake.m
//  Rice
//
//  Created by liudukun on 15/12/11.
//  Copyright © 2015年 ZengWh. All rights reserved.
//

#import "DKShare.h"
//#import "AppDelegate.h"
#import "WeiboSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "WeiboSDK.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>

#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

@interface DKShare ()
{
}

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *shareWeixinButton;
@property (weak, nonatomic) IBOutlet UIButton *pengyouquanButton;
@property (weak, nonatomic) IBOutlet UIButton *weiboButton;
@property (weak, nonatomic) IBOutlet UIButton *qqButton;
@property (weak, nonatomic) IBOutlet UIButton *qzoneButton;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * descriptionTitle;
@property (strong, nonatomic) NSString * turnUrl;
@property (strong, nonatomic) NSData * imageData;


@end


@implementation DKShare




- (IBAction)actionShareButton:(UIButton*)sender {
    if (sender == self.shareWeixinButton) {
        [self shareWeixin];
    }
    if (sender == self.pengyouquanButton) {
        [self sharePengyou];
    }
    if (sender == self.weiboButton) {
        [self shareWeibo];
    }
    if (sender == self.qqButton) {
        [self shareQQ];
    }
    if (sender == self.qzoneButton) {
        [self shareQZone];
    }
}



static DKShare * instance;

+(DKShare*)showShareViewWithTurnUrl:(NSString*)url vc:(UIViewController *)vc urlImage:(NSString*)imageURL title:(NSString*)title description:(NSString*)description{
    
    if (instance == nil) {
        instance = [[NSBundle mainBundle]loadNibNamed:@"DKShare" owner:self options:nil][0];
    }
    [WXApi registerApp:WeChatAppkey];
    [WeiboSDK registerApp:WeChatAppkey];
    TencentOAuth * auth = [[TencentOAuth alloc] initWithAppId:QQAppID andDelegate:nil];
    NSLog(@"auth%@",auth);
    
    instance.turnUrl = url;
    dispatch_async(dispatch_queue_create("share", DISPATCH_QUEUE_PRIORITY_DEFAULT), ^{
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
        UIImage * image = [UIImage imageWithData:data];
        if (data.length<32*1024) {
            instance.imageData = data;
            }else{
                image =  [DKShare reSizeImage:image toSize:CGSizeMake(image.size.height*100/image.size.width, 100)];
                instance.imageData = UIImagePNGRepresentation(image);
        }
    });

    
    instance.title = title;
    instance.descriptionTitle = description;
    
    
    [vc.view addSubview:instance];
    [UIView animateWithDuration:0.5 animations:^{
        instance.bgView.frame = CGRectMake(0, SCREEN_WIDTH-60, SCREEN_WIDTH, 60);
    }];
    
    return instance;
}

-(void)setFixedImageData:(UIImage*)image{
    image =  [DKShare reSizeImage:image toSize:CGSizeMake(image.size.height*100/image.size.width, 100)];
    instance.imageData = UIImagePNGRepresentation(image);
}


+(void)hideShareView{
    [UIView animateWithDuration:0.5 animations:^{
        instance.bgView.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_WIDTH, 60);
    } completion:^(BOOL finished) {
        [instance removeFromSuperview];

    }];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [DKShare hideShareView];
}

-(void)shareQQ{


    //分享跳转URL
    NSString *url = self.turnUrl;
    //分享图预览图URL地址
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                title: self.title
                                description:self.descriptionTitle
                                previewImageData:self.imageData targetContentType:QQApiURLTargetTypeNews];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    //将内容分享到qq
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    NSLog(@"%i",sent);
}

-(void)shareQZone{
    //分享跳转URL
    NSString *url = self.turnUrl;
    //分享图预览图URL地址
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                title: self.title
                                description:self.descriptionTitle
                                previewImageData:self.imageData];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    
    //将内容分享到qzone
    QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
    NSLog(@"%i",sent);
}

-(void)sharePengyou{
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.turnUrl;
    
    
    WXMediaMessage *message = [WXMediaMessage message ];
    message.title = self.title;
    message.description = self.descriptionTitle;
    message.thumbData = self.imageData;
    message.mediaObject = ext;
    message.mediaTagName = @"share";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.message = message;
    req.scene = WXSceneTimeline;
    BOOL flag = [WXApi sendReq:req];
    NSLog(@"%i",flag);

}

-(void)shareWeixin{
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.turnUrl;

    
    WXMediaMessage *message = [WXMediaMessage message ];
    message.title = self.title;
    message.description = self.descriptionTitle;
    message.thumbData = self.imageData;
    message.mediaObject = ext;
    message.mediaTagName = @"share";
 
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.message = message;
    req.scene = WXSceneSession;
    BOOL flag = [WXApi sendReq:req];
    NSLog(@"%i",flag);
}


-(void)shareWeibo{
    WBMessageObject *message = [WBMessageObject message];
    
    WBWebpageObject * media = [WBWebpageObject object];
    media.webpageUrl = self.turnUrl;
    media.objectID = @"share";
    media.title = self.title;
    media.description = self.descriptionTitle;
    media.thumbnailData = self.imageData;
    media.scheme = @"dami://";
    message.mediaObject = media;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message ];
    BOOL flag = [WeiboSDK sendRequest:request];
    NSLog(@"%i",flag);

}

+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize

{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}

@end
