#import "EditorClassViewController.h"
#import "EditorClassTableViewCell.h"
#import "NicknameAlertView.h"
@interface EditorClassViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray<JSClassModel*> * dataArr;
@end
@implementation EditorClassViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Edit category", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.dataArr = [NSMutableArray array];
    for (JSClassModel * model in [JSUserInfo shareManager].classArray) {
        if (![model.class_name isEqualToString:@"All"]&&![model.class_name isEqualToString:@"Normal"]) {
            [self.dataArr addObject:model];
        }
    }
}
- (IBAction)addClassBtn:(UIButton *)sender {
    WS(wSelf);
    NicknameAlertView * nickNameView = [NicknameAlertView loadViewFromXib];
    nickNameView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    nickNameView.isEditor = NO;
    [KEY_WINDOW addSubview:nickNameView];
    [nickNameView getCodeBasedInput:^(NSString * _Nonnull password, UIColor * _Nonnull color) {
        JSClassModel * model = [JSClassModel new];
        model.class_color = color;
        model.class_name = password;
        model.userInfoArray = [NSMutableArray array];
        [wSelf.dataArr addObject:model];
        NSMutableArray * array = [NSMutableArray array];
        for (NSInteger i=0; i<2; i++) {
            JSClassModel * model = [JSUserInfo shareManager].classArray[i];
            [array addObject:model];
        }
        [array addObjectsFromArray:wSelf.dataArr];
        [JSUserInfo shareManager].classArray = array;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDiaryClassNotication" object:nil userInfo:nil];
        [wSelf.tableView reloadData];
    } cancelBlock:nil];
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
    return 40;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditorClassTableViewCell * cell = [EditorClassTableViewCell cellWithTableView:tableView];
    JSClassModel * model = self.dataArr[indexPath.row];
    cell.colorView.layer.borderColor = model.class_color.CGColor;
    if ([model.class_name isEqualToString:@"Normal"]) {
        cell.colorView.backgroundColor = [UIColor whiteColor];
    } else {
        cell.colorView.backgroundColor = model.class_color;
    }
    cell.titleLabel.text = model.class_name;
    cell.numberLabel.text = [NSString stringWithFormat:@"(%ld)",model.userInfoArray.count];
    [cell.deleteBtn addTarget:self action:@selector(deleteClass:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteBtn.tag = 332+indexPath.row;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WS(wSelf);
    JSClassModel * classModel = self.dataArr[indexPath.row];
    NicknameAlertView * nickNameView = [NicknameAlertView loadViewFromXib];
    nickNameView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    nickNameView.color = classModel.class_color;
    nickNameView.isEditor = YES;
    nickNameView.textField.text = classModel.class_name;
    [KEY_WINDOW addSubview:nickNameView];
    [nickNameView getCodeBasedInput:^(NSString * _Nonnull password, UIColor * _Nonnull color) {
        JSClassModel * model = [JSClassModel new];
        model.class_color = color;
        model.class_name = password;
        NSMutableArray * array = [JSUserInfo shareManager].classArray;
        NSMutableArray * twoArr = classModel.userInfoArray;
        for (NSInteger i=0; i<twoArr.count; i++) {
            JSFastLoginModel * itemModel = twoArr[i];
            itemModel.class_color = color;
            itemModel.class_name = password;
            [twoArr replaceObjectAtIndex:i withObject:itemModel];
        }
        model.userInfoArray = twoArr;
        [wSelf.dataArr replaceObjectAtIndex:indexPath.row withObject:model];
        [array replaceObjectAtIndex:indexPath.row+2 withObject:model];
        [JSUserInfo shareManager].classArray = array;
        NSMutableArray * allArr = [JSUserInfo shareManager].allArray;
        for (NSInteger i=0; i<allArr.count; i++) {
            JSFastLoginModel * itemModel = allArr[i];
            if ([itemModel.class_name isEqualToString:classModel.class_name]) {
                itemModel.class_color = color;
                itemModel.class_name = password;
                [allArr replaceObjectAtIndex:i withObject:itemModel];
            }
        }
        [JSUserInfo shareManager].allArray = allArr;
        NSMutableArray * deleteArr = [JSUserInfo shareManager].garbageArray;
        for (NSInteger i=0; i<deleteArr.count; i++) {
            JSFastLoginModel * itemModel = deleteArr[i];
            if ([itemModel.class_name isEqualToString:classModel.class_name]) {
                itemModel.class_color = color;
                itemModel.class_name = password;
                [deleteArr replaceObjectAtIndex:i withObject:itemModel];
            }
        }
        [JSUserInfo shareManager].garbageArray = deleteArr;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDiaryClassNotication" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
        [wSelf.tableView reloadData];
    } cancelBlock:nil];
}
-(void)deleteClass:(UIButton*)sender{
    JSClassModel * classModel = self.dataArr[sender.tag-332];
    WS(wSelf);
    [[JSSelectViewTool sharedManager] inpour:[NSMutableArray arrayWithObjects:NSLocalizedString(@"Delete category", nil),NSLocalizedString(@"Delete categories and diaries", nil), nil] currentIndexd:0 confirmBlock:^(id obj, NSInteger currentIndex) {
        [wSelf.dataArr removeObject:classModel];
        NSMutableArray * array = [NSMutableArray array];
        for (NSInteger i=0; i<2; i++) {
            JSClassModel * model = [JSUserInfo shareManager].classArray[i];
            [array addObject:model];
        }
        if (currentIndex == 0) {
            JSClassModel * noModel = array[1];
            NSMutableArray * itemArr = noModel.userInfoArray;
            NSMutableArray * userArr = classModel.userInfoArray;
            if (userArr.count>0) {
                for (NSInteger i=0; i<userArr.count; i++) {
                    JSFastLoginModel * model = userArr[i];
                    model.class_color = SMColorFromRGB(0xC5C2C2);
                    model.class_name = @"Normal";
                    [userArr replaceObjectAtIndex:i withObject:model];
                }
                [itemArr addObjectsFromArray:userArr];
                noModel.userInfoArray = itemArr;
                [array replaceObjectAtIndex:1 withObject:noModel];
            }
            NSMutableArray * allArr = [JSUserInfo shareManager].allArray;
            for (NSInteger i=0; i<allArr.count; i++) {
                JSFastLoginModel * model = allArr[i];
                if ([model.class_name isEqualToString:classModel.class_name]) {
                    model.class_color = SMColorFromRGB(0xC5C2C2);
                    model.class_name = @"Normal";
                    [allArr replaceObjectAtIndex:i withObject:model];
                }
            }
            [JSUserInfo shareManager].allArray = allArr;
        } else {
            NSMutableArray * allArr = [JSUserInfo shareManager].allArray;
            NSMutableArray * deleteArr = [JSUserInfo shareManager].garbageArray;
            [allArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                JSFastLoginModel * model = (JSFastLoginModel*)obj;
                if ([model.class_name isEqualToString:classModel.class_name]) {
                    model.class_color = SMColorFromRGB(0xC5C2C2);
                    model.class_name = @"Normal";
                    [deleteArr addObject:model];
                    [allArr removeObject:model];
                }
            }];
            [JSUserInfo shareManager].garbageArray = deleteArr ;
            [JSUserInfo shareManager].allArray = allArr;
        }
        NSMutableArray * deleteArr =  [JSUserInfo shareManager].garbageArray;
        for (NSInteger i=0; i<deleteArr.count; i++) {
            JSFastLoginModel * model = deleteArr[i];
            if ([model.class_name isEqualToString:classModel.class_name]) {
                model.class_color = SMColorFromRGB(0xC5C2C2);
                model.class_name = @"Normal";
                [deleteArr replaceObjectAtIndex:i withObject:model];
            }
        }
        [JSUserInfo shareManager].garbageArray = deleteArr;
        [array addObjectsFromArray:wSelf.dataArr];
        [JSUserInfo shareManager].classArray = array;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshDiaryClassNotication" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
        [wSelf.tableView reloadData];
    } cancelBlock:nil];
}
@end
