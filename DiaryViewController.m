#import "DiaryViewController.h"
#import "DiaryTableViewCell.h"
#import "WriteDiaryViewController.h"
#import "ShowDiaryViewController.h"
@interface DiaryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)UIButton * classBtn;
@property (nonatomic,strong) NSMutableArray<JSFastLoginModel*> * dataArr;
@property (nonatomic,strong) NSMutableArray * classArr;
@property (nonatomic,strong) NSString * titleStr;
@property (nonatomic,assign) NSInteger index_count;
@end
@implementation DiaryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Diary", nil);
    self.index_count = 0;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"select_doDiary"] style:UIBarButtonItemStylePlain target:self action:@selector(getTimeData)];
    UIButton * classBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [classBtn setTitle:@"All" forState:UIControlStateNormal];
    [classBtn setImage:[UIImage imageNamed:@"ico_downw"] forState:UIControlStateNormal];
    classBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [classBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    classBtn.frame = CGRectMake(0, 0, 60, 30);
    [classBtn addTarget:self action:@selector(beginDiary) forControlEvents:UIControlEventTouchUpInside];
    self.classBtn = classBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:classBtn];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.titleStr = @"All";
    if ([JSUserInfo shareManager].classArray.count == 0) {
        JSClassModel * model = [[JSClassModel alloc]init];
        model.class_name = @"All";
        model.class_color = SMColorFromRGB(0xC5C2C2);
        model.userInfoArray = [NSMutableArray array];
        JSClassModel * model1 = [[JSClassModel alloc]init];
        model1.class_name = @"Normal";
        model1.class_color = SMColorFromRGB(0xC5C2C2);
        model1.userInfoArray = [NSMutableArray array];
        [JSUserInfo shareManager].classArray = [NSMutableArray arrayWithObjects:model,model1, nil];
    }
    self.classArr = [JSUserInfo shareManager].classArray;
    self.dataArr = [JSUserInfo shareManager].allArray;
    [self customNotiationData];
}
-(void)customNotiationData{
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"addDiaryDataNotication" object:nil]takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        JSFastLoginModel * addModel = [x.userInfo objectForKey:@"JSFastLoginModel"];
        if ([self.titleStr isEqualToString:addModel.class_name]||[self.titleStr isEqualToString:@"All"]) {
            [self.dataArr insertObject:addModel atIndex:0];
        }
        self.classArr = [JSUserInfo shareManager].classArray;
        [self.tableView reloadData];
    }];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"editorDiaryDataNotication" object:nil]takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        self.classArr = [JSUserInfo shareManager].classArray;
        JSFastLoginModel * editorModel = [x.userInfo objectForKey:@"JSFastLoginModel"];
        NSString * str1 = [NSString stringWithFormat:@"%@.%@.%@",editorModel.class_year,editorModel.class_day,editorModel.class_hour];
        for (NSInteger i=0; i<self.dataArr.count; i++) {
            JSFastLoginModel * model = self.dataArr[i];
            NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model.class_year,model.class_day,model.class_hour];
            if ([str isEqualToString:str1]) {
                [self.dataArr replaceObjectAtIndex:i withObject:editorModel];
                break;
            }
        }
        [self.tableView reloadData];
    }];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"deleteDiaryDataNotication" object:nil]takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        if (self.index_count == 0) {
            self.dataArr = [JSUserInfo shareManager].allArray;
        } else {
            self.classArr = [JSUserInfo shareManager].classArray;
            JSClassModel * model = self.classArr[self.index_count];
            NSArray * array = [NSArray arrayWithArray:model.userInfoArray];
            self.dataArr = [NSMutableArray arrayWithArray:[self sortedArrayUsingComparatorByPaymentTimeWithDataArr:array]];
        }
        [self.tableView reloadData];
    }];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"refreshDiaryClassNotication" object:nil]takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        self.classArr = [JSUserInfo shareManager].classArray;
        JSClassModel * model = self.classArr[self.index_count];
        if ([self.titleStr isEqualToString:@"All"]) {
            self.dataArr = [JSUserInfo shareManager].allArray;
        }else{
            NSArray * array = [NSArray arrayWithArray:model.userInfoArray];
            self.dataArr = [NSMutableArray arrayWithArray:[self sortedArrayUsingComparatorByPaymentTimeWithDataArr:array]];
        }
        [self.tableView reloadData];
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)getTimeData{
    WriteDiaryViewController * writeDiayVC = [[WriteDiaryViewController alloc ]init];
    writeDiayVC.hidesBottomBarWhenPushed = YES;
    writeDiayVC.index_count = self.index_count;
    writeDiayVC.titleStr = self.titleStr;
    writeDiayVC.isEditor = NO;
    [self.navigationController pushViewController:writeDiayVC animated:YES];
}
-(void)beginDiary
{
    NSMutableArray * array = [NSMutableArray array];
    for (JSClassModel * model in self.classArr) {
        [array addObject:model.class_name];
    }
    [self.classBtn setImage:[UIImage imageNamed:@"ico_upw"] forState:UIControlStateNormal];
    WS(wSelf);
    [[JSSelectViewTool sharedManager] inpour:array currentIndexd:self.index_count confirmBlock:^(id obj, NSInteger currentIndex) {
        [wSelf.classBtn setImage:[UIImage imageNamed:@"ico_downw"] forState:UIControlStateNormal];
        [wSelf.classBtn setTitle:obj forState:UIControlStateNormal];
        wSelf.index_count = currentIndex;
        wSelf.titleStr = obj;
        if (currentIndex == 0) {
            self.dataArr = [JSUserInfo shareManager].allArray;
        } else {
            JSClassModel * model = self.classArr[currentIndex];
            NSArray * array = [NSArray arrayWithArray:model.userInfoArray];
            wSelf.dataArr = [NSMutableArray arrayWithArray:[self sortedArrayUsingComparatorByPaymentTimeWithDataArr:array]];
        }
        [wSelf.tableView reloadData];
    } cancelBlock:^{
        [wSelf.classBtn setImage:[UIImage imageNamed:@"ico_downw"] forState:UIControlStateNormal];
    }];
}
- (NSArray *)sortedArrayUsingComparatorByPaymentTimeWithDataArr:(NSArray<JSFastLoginModel*> *)dataArr{
    NSMutableArray *sortArray = [dataArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        JSFastLoginModel *model1 = obj1;
        JSFastLoginModel *model2 = obj2;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy.MM.dd HH:mm:ss"];
        NSString * time1 = [NSString stringWithFormat:@"%@.%@ %@",model1.class_year,model1.class_day,model1.class_hour];
        NSString * time2 = [NSString stringWithFormat:@"%@.%@ %@",model2.class_year,model2.class_day,model2.class_hour];
        NSDate *date1= [dateFormatter dateFromString:time1];
        NSDate *date2= [dateFormatter dateFromString:time2];
        if (date1 == [date1 earlierDate: date2]) { 
            return NSOrderedDescending;
        }else if (date1 == [date1 laterDate: date2]) {
            return NSOrderedAscending;
        }else{
            return NSOrderedSame;
        }
    }];
    return sortArray;
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
    ShowDiaryViewController * showDiaryVC = [[ShowDiaryViewController alloc]init];
    showDiaryVC.hidesBottomBarWhenPushed = YES;
    showDiaryVC.model = model;
    showDiaryVC.index_count = self.index_count;
    [self.navigationController pushViewController:showDiaryVC animated:YES];
}
@end
