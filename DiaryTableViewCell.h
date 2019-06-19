#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface DiaryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *weekLabel;
@property (weak, nonatomic) IBOutlet UIView *roundLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *phoneImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthCons;
+ (DiaryTableViewCell *)cellWithTableView:(UITableView *)tableView;
@end
NS_ASSUME_NONNULL_END
