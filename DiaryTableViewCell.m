#import "DiaryTableViewCell.h"
@implementation DiaryTableViewCell
+ (DiaryTableViewCell *)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"DiaryTableViewCell";
    DiaryTableViewCell *cell=(DiaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil) {
        UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[NSClassFromString(@"DiaryTableViewCell") class]]];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = (DiaryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, ScreenWidth)];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.roundLabel.layer.borderWidth = 1;
    self.roundLabel.layer.cornerRadius = 10;
    self.roundLabel.layer.masksToBounds = YES;
    self.phoneImageView.layer.cornerRadius = 3;
    self.phoneImageView.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 3;
    self.bgView.layer.masksToBounds = YES;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
