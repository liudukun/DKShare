//
//  ZJShareView.h
//  ZJHTCarOwner
//
//  Created by liudukun on 2017/5/15.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ZJShareTypeQQ,
    ZJShareTypeQZone,
    ZJShareTypeWeiBo,
    ZJShareTypeWeChat,
    ZJShareTypeWeChatTimeLine,
    ZJShareTypeWeChatFavorite
} ZJShareType;


typedef void(^ActionTypeBlock)(ZJShareType type);



@interface ZJShareView : UIView

@property (nonatomic,strong) ActionTypeBlock actionType;

- (void)setShareTypes:(NSArray *)types;

- (void)show;



@end
