//
//  ShareManager.m
//  ZJHTCarOwner
//
//  Created by liudukun on 2017/5/15.
//
//

#import "ShareManager.h"


@implementation ShareModel

-(void)setValue:(id)value forUndefinedKey:(NSString *)key{
    
}


@end



@interface ShareManager()

@end
@implementation ShareManager

+ (instancetype)manager{
    static ShareManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}



- (void)registerSDK{
    [self getKeys:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *kWeChatAPPID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kWeChatAPPID"];
            NSString *kQQAPPID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kQQAPPID"];
            NSString *kWeiBoAPPID = [[NSUserDefaults standardUserDefaults] objectForKey:@"kWeiBoAPPID"];
            BOOL flagX = [WXApi registerApp:kWeChatAPPID];
            NSLog(@"%@",flagX?@"wechat register succeed":@"wechat register failed");
            
            TencentOAuth * auth = [[TencentOAuth alloc] initWithAppId:kQQAPPID andDelegate:nil];
            NSLog(@"%@",auth?@"QQSDK register succeed":@"QQSDK register failed");
            
            BOOL flagW = [WeiboSDK registerApp:kWeiBoAPPID];
            NSLog(@"%@",flagW?@"WeiboSDK register succeed":@"WeiboSDK register failed");
        });
    }];
    
}

- (void)registerHandleOpenURL:(NSURL *)url{
    [WeiboSDK handleOpenURL:url delegate:self];
    [QQApiInterface handleOpenURL:url delegate:self];
    [WXApi handleOpenURL:url delegate:self];
}

- (void)getKeys:(void(^)(void))completed{
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kServerCommon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3];
    [req setHTTPMethod:@"POST"];
    NSMutableArray *parameterPairs = [NSMutableArray array];
    [@{@"types":@"1,2,3",@"application":@"3"} enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [parameterPairs addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    
    // URL encoded query string
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *queryString = [[parameterPairs componentsJoinedByString:@"&"] stringByAddingPercentEncodingWithAllowedCharacters:set];
    [req setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        if (error||!data.length) {
            NSLog(@"%@",error);
            completed();
            return ;
        }
        NSArray *arr = dic[@"data"];
        [arr enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj[@"type"] intValue]== 1) {
                [[NSUserDefaults standardUserDefaults] setObject:obj[@"content"] forKey:@"kWeChatAPPID"];
            }
            if ([obj[@"type"] intValue]== 2) {
                [[NSUserDefaults standardUserDefaults] setObject:obj[@"content"] forKey:@"kQQAPPID"];
            }
            if ([obj[@"type"] intValue]== 3) {
                [[NSUserDefaults standardUserDefaults] setObject:obj[@"content"] forKey:@"kWeiBoAPPID"];
            }
        }];
        completed();
    }];
    [task resume];
}

+ (void)showShareBoardWithShareModel:(ShareModel *)share completed:(void(^)(NSString *msg,BOOL succeed))completed{
    ShareManager *manger = [self manager];
    manger.completed = completed;
    
    if (share.imageURL.length&&!share.imageData) {
        NSError *error;
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[share.imageURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] options:NSDataReadingMappedIfSafe error:&error];
        if (!error) {
            share.imageData = data;
        }
    }
    if (!share.imageData) {
        UIImage *defaultImage = [UIImage imageNamed:kDefaultIcon];
        share.imageData =  UIImagePNGRepresentation(defaultImage);
    }
    
    manger.share = share;
    ZJShareView *shareView = [[ZJShareView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
    [shareView setShareTypes:@[@(ZJShareTypeQQ),@(ZJShareTypeQZone),@(ZJShareTypeWeChat),@(ZJShareTypeWeChatTimeLine),@(ZJShareTypeWeChatFavorite),@(ZJShareTypeWeiBo)]];
    [shareView show];
    [shareView setActionType:^(ZJShareType type){
        switch (type) {
            case ZJShareTypeQQ:
                [manger shareQQ:NO];
                break;
            case ZJShareTypeQZone:
                [manger shareQQ:YES];
                break;
            case ZJShareTypeWeChat:
                [manger shareWechat:WXSceneSession];
                break;
            case ZJShareTypeWeChatTimeLine:
                [manger shareWechat:WXSceneTimeline];
                break;
            case ZJShareTypeWeChatFavorite:
                [manger shareWechat:WXSceneFavorite];
                break;
            case ZJShareTypeWeiBo:
                [manger shareWeibo];
                break;
            default:
                break;
        }
    }];
    
}

-(void)shareQQ:(BOOL)isZone{
    if(![QQApiInterface isQQInstalled]&&!isZone){
        self.completed(@"请先安装QQ客户端!",NO);
        return;
    }
    NSData *imageData = [self resizePic:self.share.imageData withMaxSize:1024 * 1024];
    
    //分享跳转URL
    NSString *url = self.share.url;
    //分享图预览图URL地址
    
    QQApiNewsObject *newsObj = [QQApiNewsObject
                                objectWithURL:[NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                title: self.share.title
                                description:self.share.content
                                previewImageData:imageData targetContentType:QQApiURLTargetTypeNews];
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent;
    if (isZone) {
        //将内容分享到qzone
        sent = [QQApiInterface SendReqToQZone:req];
    }else{
        //将内容分享到qq
        sent = [QQApiInterface sendReq:req];
    }
    NSLog(@"%i",sent);
}


-(void)shareWechat:(int)scene{
    if(![WXApi isWXAppInstalled]){
        self.completed(@"请先安装微信客户端!",NO);
        return;
    }
    NSData *imageData = [self resizePic:self.share.imageData withMaxSize:30 * 1024];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = self.share.url;
    
    WXMediaMessage *message = [WXMediaMessage message ];
    message.title = self.share.title;
    message.description = self.share.content;
    message.thumbData = imageData;
    message.mediaObject = ext;
    message.mediaTagName = @"share";
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc]init];
    req.message = message;
    req.scene = scene;
    BOOL flag = [WXApi sendReq:req];
    NSLog(@"%i",flag);
}


-(void)shareWeibo{
    if (![WeiboSDK isWeiboAppInstalled]) {
        self.completed(@"请先安装微博客户端!",NO);
        return;
    }
    WBMessageObject *message = [WBMessageObject message];
    
    WBWebpageObject * media = [WBWebpageObject object];
    media.webpageUrl = self.share.url;
    media.objectID = [NSUUID UUID].UUIDString;
    media.title = self.share.title;
    media.description = self.share.content;
    NSData *imageData = [self resizePic:self.share.imageData withMaxSize:32 * 1024];
    media.thumbnailData = imageData;
    media.scheme = kAppScheme;
    message.mediaObject = media;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message ];
    BOOL flag = [WeiboSDK sendRequest:request];
    NSLog(@"%i",flag);
    
}

- (NSData *)resizePic:(NSData *)data withMaxSize:(CGFloat)max{
    CGFloat quatity = 1;
    UIImage *image = [UIImage imageWithData:data];
    
    while (1) {
        if (data.length >= max) {
            data =  UIImageJPEGRepresentation(image, quatity);
        }else{
            break;
        }
        quatity -= 0.05f;
    }
    return data;
}

#pragma mark - sdk delegate

- (void)onResp:(id)resp{
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *req = (SendMessageToWXResp *)resp;
        if (!req.errCode) {
            self.completed(@"分享微信成功!",YES);
            
        }else{
            self.completed(@"分享微信失败!",NO);
        }
        
    }
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        QQBaseResp *req = (QQBaseResp *)resp;
        if ([req.result isEqualToString:@"0"]) {
            self.completed(@"分享QQ成功!",YES);
        }else{
            self.completed(@"分享QQ失败!",NO);
        }
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    if (!response.statusCode) {
        self.completed(@"分享微博成功!",YES);
        
    }else{
        self.completed(@"分享微博失败!",NO);
        
    }
}

- (void)isOnlineResponse:(NSDictionary *)response{}

- (void)onReq:(id)resp{}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{}

@end

