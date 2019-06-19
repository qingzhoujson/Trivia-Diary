#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface WriteDiaryViewController : UIViewController
@property (nonatomic,strong) JSFastLoginModel * model;
@property (nonatomic,strong) NSString * titleStr;
@property (nonatomic,assign) BOOL isEditor;
@property (nonatomic,assign) NSInteger index_count;
@end
NS_ASSUME_NONNULL_END
