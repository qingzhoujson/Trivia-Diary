#import "GarbageViewController.h"
#import "DiaryTableViewCell.h"
@interface GarbageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray * dataArr;
@end
@implementation GarbageViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Trash", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataArr = [JSUserInfo shareManager].garbageArray;
}
- (IBAction)allRestoreBtn:(UIButton *)sender {
    NSMutableArray * array = [JSUserInfo shareManager].allArray;
    [array addObjectsFromArray:self.dataArr];
    [JSUserInfo shareManager].allArray = array;
    NSMutableArray * classArr = [JSUserInfo shareManager].classArray;
    for (NSInteger i=0; i<self.dataArr.count; i++) {
        JSFastLoginModel * garbageModel = self.dataArr[i];
        for (NSInteger j=0; j<classArr.count; j++) {
            JSClassModel * classModel = classArr[j];
            if ([garbageModel.class_name isEqualToString:classModel.class_name]) {
                [classModel.userInfoArray addObject:garbageModel];
            }
        }
    }
    [JSUserInfo shareManager].classArray = classArr;
    [JSUserInfo shareManager].garbageArray = [NSMutableArray array];
    self.dataArr = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDiaryClassNotication" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
    [self.tableView reloadData];
}
- (IBAction)allDeleteBtn:(UIButton *)sender {
    [JSUserInfo shareManager].garbageArray = [NSMutableArray array];
    self.dataArr = [NSMutableArray array];
    [self.tableView reloadData];
}
# pragma mark - UITableViewDelegate UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self.tableView hideEmptyView];
    if (self.dataArr.count == 0) {
        [self.tableView showEmptyView];
    }
    return self.dataArr.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiaryTableViewCell * cell = [DiaryTableViewCell cellWithTableView:tableView];
    JSFastLoginModel * model = self.dataArr[indexPath.row];
    if (model.class_imageArr.count == 0) {
        cell.imageViewWidthCons.constant = 0;
    } else{
        cell.imageViewWidthCons.constant = 75;
        cell.phoneImageView.image = [UIImage imageWithData:model.class_imageArr[0]]; 
    }
    cell.roundLabel.layer.borderColor = SMColorFromRGB(0xC5C2C2).CGColor;
    cell.roundLabel.backgroundColor = [UIColor whiteColor];
    if (![model.class_name isEqualToString:@"Normal"]) {
        cell.roundLabel.backgroundColor = model.class_color;
        cell.roundLabel.layer.borderColor = model.class_color.CGColor;
    }
    cell.dayLabel.text = model.class_day;
    cell.weekLabel.text = model.class_week;
    cell.timeLabel.text = model.class_year;
    cell.titleLabel.text = model.class_note;
    cell.secondsLabel.text = model.class_hour;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JSFastLoginModel * model = self.dataArr[indexPath.row];
    WS(wSelf);
    [[JSSelectViewTool sharedManager] inpour:[NSMutableArray arrayWithObjects:NSLocalizedString(@"Restore", nil),NSLocalizedString(@"Remove completely", nil), nil] currentIndexd:0 confirmBlock:^(id obj, NSInteger currentIndex) {
        [wSelf.dataArr removeObject:model];
        if (currentIndex == 0) {
            NSMutableArray * array = [JSUserInfo shareManager].allArray;
            [array insertObject:model atIndex:0];
            [JSUserInfo shareManager].allArray = array;
            NSMutableArray * classArr = [JSUserInfo shareManager].classArray;
            for (NSInteger i=0; i<classArr.count; i++) {
                JSClassModel * classmodel = classArr[i];
                if ([model.class_name isEqualToString:classmodel.class_name]) {
                    NSMutableArray * itemArr = classmodel.userInfoArray;
                    [itemArr addObject:model];
                    classmodel.userInfoArray = itemArr;
                }
                [classArr replaceObjectAtIndex:i withObject:classmodel];
            }
            [JSUserInfo shareManager].classArray = classArr;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDiaryClassNotication" object:nil userInfo:nil];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
        }
        [JSUserInfo shareManager].garbageArray = wSelf.dataArr;
        [wSelf.tableView reloadData];
    } cancelBlock:nil];
}
@end
