#import "ShowDiaryViewController.h"
#import "FillContantTableViewCell.h"
#import "POPublishPictureCell.h"
#import "ShowDiaryTableViewCell.h"
#import "WriteDiaryViewController.h"
#import "ShowDiaryViewController+Triviad.h"
@interface ShowDiaryViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray <JSImageModel *>*realImageModes;
@property (nonatomic,strong) NSMutableArray * allArr;
@property (nonatomic,strong) NSMutableArray * classArray;
@property (nonatomic,strong) NSMutableArray * garbageArray;
@end
@implementation ShowDiaryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.model.class_name;
    [self cusotmClassModel:self.model];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"editorDiaryDataNotication" object:nil]takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self);
        JSFastLoginModel * editorModel = [x.userInfo objectForKey:@"JSFastLoginModel"];
        self.model = editorModel;
        self.navigationItem.title = editorModel.class_name;
        [self cusotmClassModel:editorModel];
        [self.tableView reloadData];
    }];
    self.allArr =  [JSUserInfo shareManager].allArray;
    self.classArray = [JSUserInfo shareManager].classArray;
    self.garbageArray = [JSUserInfo shareManager].garbageArray;
}
-(void)cusotmClassModel:(JSFastLoginModel*)model{
    if (self.model.class_imageArr.count>0) {
        [self.realImageModes removeAllObjects];
        for (NSInteger i=0; i<model.class_imageArr.count; i++) {
            JSImageModel * imageModel = [[JSImageModel alloc]init];
            imageModel.image = [UIImage imageWithData:model.class_imageArr[i]];
            [self.realImageModes addObject:imageModel];
        }
    }
}
- (IBAction)deleteDiaryBtn:(UIButton *)sender {
    WS(wSelf);
    JSCommonAlertView *alter = [[JSCommonAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil) textArray:nil textAlignment:TextAlignmentCenter buttonStyle:ButtonLandscapeStyle];
    [alter showAlertView:NSLocalizedString(@"Cancel", nil) sureTitle:NSLocalizedString(@"Confirm", nil) cancelBlock:^{
    } sureBlock:^{
        NSString * str1 = [NSString stringWithFormat:@"%@.%@.%@",wSelf.model.class_year,wSelf.model.class_day,wSelf.model.class_hour];
        for (NSInteger i=0; i<wSelf.allArr.count; i++) {
            JSFastLoginModel * model1 = wSelf.allArr[i];
            NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model1.class_year,model1.class_day,model1.class_hour];
            if ([str isEqualToString:str1]) {
                [wSelf.allArr removeObject:model1];
                break;
            }
        }
        [self.garbageArray insertObject:wSelf.model atIndex:0];
        for (NSInteger i=0; i<wSelf.classArray.count; i++) {
            JSClassModel * classModel = wSelf.classArray[i];
            if ([self.model.class_name isEqualToString:classModel.class_name]) {
                NSMutableArray * array = classModel.userInfoArray;
                for (JSFastLoginModel * model1 in array) {
                    NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model1.class_year,model1.class_day,model1.class_hour];
                    if ([str isEqualToString:str1]) {
                        [array removeObject:model1];
                        classModel.userInfoArray = array;
                        [wSelf.classArray replaceObjectAtIndex:i withObject:classModel];
                        break;
                    }
                }
            }
        }
        [JSUserInfo shareManager].allArray = wSelf.allArr;
        [JSUserInfo shareManager].garbageArray = wSelf.garbageArray;
        [JSUserInfo shareManager].classArray = wSelf.classArray;
        [[NSNotificationCenter defaultCenter]postNotificationName:@"deleteDiaryDataNotication" object:nil userInfo:@{@"JSFastLoginModel":self.model}];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
        [wSelf.navigationController popViewControllerAnimated:YES];
    }];
}
- (IBAction)editorDiaryBtn:(UIButton *)sender {
    WriteDiaryViewController * writeDiayVC = [[WriteDiaryViewController alloc ]init];
    writeDiayVC.model = self.model;
    writeDiayVC.index_count = self.index_count;
    writeDiayVC.isEditor = YES;
    [self.navigationController pushViewController:writeDiayVC animated:YES];
}
# pragma mark - UITableViewDelegate UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.realImageModes.count == 0) {
        return 2;
    } else {
        return 3;
    }
}
- (CGFloat)calculateRowHeight:(NSString *)string fontSize:(NSInteger)fontSize{
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]};
    CGRect rect = [string boundingRectWithSize:CGSizeMake(ScreenWidth - 55, 0) options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    return rect.size.height;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 40;
    } else if (indexPath.row == 1) {
        if (self.model.class_note.length>0) {
            CGFloat noteHeight = [self calculateRowHeight:self.model.class_note fontSize:13];
            return noteHeight+40;
        }
    } else {
        if (self.realImageModes.count == 9) {
            return self.realImageModes.count/3*((ScreenWidth-60)/3+15) + 15;
        } else {
            return self.realImageModes.count/3*((ScreenWidth-60)/3+15) + 30 + (ScreenWidth-60)/3;
        }
    }
    return 40;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        ShowDiaryTableViewCell * cell = [ShowDiaryTableViewCell cellWithTableView:tableView];
        cell.dateLabel.text = [NSString stringWithFormat:@"%@.%@",self.model.class_year,self.model.class_day];
        cell.timeLabel.text = self.model.class_hour;
        cell.weekLabel.text = self.model.class_week;
        return cell;
    } else if(indexPath.row == 1) {
        FillContantTableViewCell * cell = [FillContantTableViewCell cellWithTableView:tableView];
        cell.textView.text = self.model.class_note;
        cell.textView.userInteractionEnabled = NO;
        return cell;
    }else{
        POPublishPictureCell * cell = [POPublishPictureCell cellWithTableView:tableView];
        cell.isShow = YES;
        cell.delegateViewController =self;
        cell.realImageModes = self.realImageModes;
        [cell layoutBgPictureScrollview];
        WS(wSelf);
        cell.refreshTableView = ^{
            [wSelf.tableView reloadData];
        };
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
-(NSMutableArray *)realImageModes{
    if (!_realImageModes) {
        _realImageModes = [[NSMutableArray alloc]init];
    }
    return _realImageModes;
}
@end
