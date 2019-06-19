#import <UIKit/UIKit.h>
#import "JSImageModel.h"
@interface POPublishPictureCell : UITableViewCell
@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *bgPictureScrollview;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint *bgScrollviewHeight;
@property (nonatomic,weak) UIViewController * delegateViewController;
@property (nonatomic,assign) BOOL isShow;
@property (nonatomic,strong) NSMutableArray <JSImageModel *>*realImageModes;
@property (nonatomic,copy) void(^refreshTableView)(void);
-(void)layoutBgPictureScrollview;
+ (POPublishPictureCell *)cellWithTableView:(UITableView *)tableView;
@end
