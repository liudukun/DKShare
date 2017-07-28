//
//  ZJShareView.m
//  ZJHTCarOwner
//
//  Created by liudukun on 2017/5/15.
//
//

#import "ZJShareView.h"

const CGFloat BoardHeight = 180;



@interface ZJShareView ()
{
    int lastCount;
}

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *boardView;


@end

@implementation ZJShareView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI{
    self.boardView = [[UIView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - BoardHeight, self.frame.size.width, BoardHeight)];
    self.boardView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:self.boardView];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
    label.text = @"分享到";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:11.f];
    [self.boardView addSubview:label];
    
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width, 80)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.boardView addSubview:self.scrollView];
    
    UIButton *close = [[UIButton alloc]initWithFrame:CGRectMake(0, BoardHeight - 50 , self.frame.size.width, 50)];
    [close setBackgroundColor:[UIColor whiteColor]];
    [close setTitle:@"取 消" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.boardView addSubview:close];

}


- (void)setShareTypes:(NSArray *)types{
    [types enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int type = [obj intValue];
        [self addButtonWithType:type];
    }];
    self.scrollView.contentSize = CGSizeMake(80 * types.count, 80);
    [self show];
}

- (void)addButtonWithType:(ZJShareType)type{
    UIButton *typeButton = [[UIButton alloc]initWithFrame:CGRectMake(lastCount * 80, 0, 80 ,80)];
    NSString *typeImg,*typeName;
    switch (type) {
        case ZJShareTypeQQ:
            typeImg = @"dkshare.bundle/qq";
            typeName = @"QQ";
            break;
        case ZJShareTypeQZone:
            typeImg = @"dkshare.bundle/qzone";
            typeName = @"QQ空间";
            break;
        case ZJShareTypeWeChat:
            typeImg = @"dkshare.bundle/wechat";
            typeName = @"微信";
            break;
        case ZJShareTypeWeChatFavorite:
            typeImg = @"dkshare.bundle/wechat_t";
            typeName = @"微信朋友圈";
            break;
        case ZJShareTypeWeChatTimeLine:
            typeImg = @"dkshare.bundle/wechat_f";
            typeName = @"微信收藏";
            break;
        case ZJShareTypeWeiBo:
            typeImg = @"dkshare.bundle/weibo";
            typeName = @"微博";
            break;
            
        default:
            break;
    }

    [typeButton setTitle:typeName forState:UIControlStateNormal];
    typeButton.titleLabel.font = [UIFont systemFontOfSize:10.f];
    [typeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [typeButton setImage:[UIImage imageNamed:typeImg] forState:UIControlStateNormal];
    typeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [typeButton setTitleEdgeInsets:UIEdgeInsetsMake(64, - 60 , 0, 0)];
    [typeButton setImageEdgeInsets:UIEdgeInsetsMake(-11, 11, 11, 11)];
    [typeButton addTarget:self action:@selector(actionType:) forControlEvents:UIControlEventTouchUpInside];
    typeButton.tag = type;
    [self.scrollView addSubview:typeButton];
    lastCount += 1;
}

- (void)actionType:(UIButton *)button{
    if (self.actionType) {
        self.actionType(button.tag);
    }
    [self hide];
}

- (void)show{
    self.boardView.mj_y = [[UIScreen mainScreen] bounds].size.height;
    self.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.boardView.mj_y = [[UIScreen mainScreen] bounds].size.height - BoardHeight - 10;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.boardView.mj_y = [[UIScreen mainScreen] bounds].size.height - BoardHeight;
        }];
    }];
    
}

- (void)hide{
    [UIView animateWithDuration:0.3 animations:^{
        self.boardView.mj_y = [[UIScreen mainScreen] bounds].size.height;
        self.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch =  [touches anyObject];
    if (touch.view == self) {
        [self hide];
    }
}

@end
