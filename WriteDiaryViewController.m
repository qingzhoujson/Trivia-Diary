#import "WriteDiaryViewController.h"
#import "SelectClassTableViewCell.h"
#import "FillContantTableViewCell.h"
#import "POPublishPictureCell.h"
@interface WriteDiaryViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray <JSImageModel *>*realImageModes;
@property (nonatomic,assign) NSInteger class_index;
@property (nonatomic,strong) NSMutableArray * classArr;
@end
@implementation WriteDiaryViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.index_count = self.index_count -1;
    if (self.index_count<=0) {
        self.index_count = 0;
    }
    if ([self.titleStr isEqualToString:@"All"]) {
        self.navigationItem.title = @"Normal";
    } else {
        self.navigationItem.title = self.titleStr;
    }
    if (self.model.class_name.length>0) {
        self.navigationItem.title = self.model.class_name;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveDiary)];
    if (self.model.class_imageArr.count>0) {
        for (NSInteger i=0; i<self.model.class_imageArr.count; i++) {
            JSImageModel * model = [[JSImageModel alloc]init];
            model.image = [UIImage imageWithData:self.model.class_imageArr[i]];
            [self.realImageModes addObject:model];
        }
    }
    self.classArr = [NSMutableArray array];
    NSMutableArray * customArr = [JSUserInfo shareManager].classArray;
    for (NSInteger i=0; i<customArr.count; i++) {
        JSClassModel * model = customArr[i];
        if (![model.class_name isEqualToString:@"All"]) {
            if ([self.model.class_name isEqualToString:model.class_name]) {
                self.index_count = i-1;
                self.class_index = i;
                self.navigationItem.title = model.class_name;
            }
            [self.classArr addObject:model.class_name];
        }
    }
}
-(void)customTimeModel{
    NSArray * arrWeek=[NSArray arrayWithObjects:@"SAT",@"SUN",@"MON",@"TUE",@"WED",@"THU",@"FRI", nil];
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear |NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitWeekday | NSCalendarUnitHour |NSCalendarUnitMinute |NSCalendarUnitSecond;
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    NSInteger year=[comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hours = [comps hour];
    NSInteger minutes = [comps minute];
    NSInteger seconds = [comps second];
    if (month < 10) {
        self.model.class_year = [NSString stringWithFormat:@"%ld.0%ld",year,month];
    }else{
         self.model.class_year = [NSString stringWithFormat:@"%ld.%ld",year,month];
    }
    if (day<10) {
        self.model.class_day = [NSString stringWithFormat:@"0%ld",day];
    } else {
        self.model.class_day = [NSString stringWithFormat:@"%ld",day];
    }
    self.model.class_week = [arrWeek objectAtIndex:week];
    self.model.class_hour = [NSString stringWithFormat:@"%ld:%ld:%ld",hours,minutes,seconds];
}
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
-(void)saveDiary{
    if (self.model.class_note.length == 0) {
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"Diary content cannot be empty", nil)];
        return;
    }
    BOOL isClass;
    isClass = YES;
    NSMutableArray * classArr = [JSUserInfo shareManager].classArray;
    JSClassModel * classModel = classArr[self.index_count+1];
    if (self.isEditor&&![self.model.class_name isEqualToString:classModel.class_name]) {
        isClass = NO;
    }
    NSString * str1 = [NSString stringWithFormat:@"%@.%@.%@",self.model.class_year,self.model.class_day,self.model.class_hour];
    self.model.class_name = classModel.class_name;
    self.model.class_color = classModel.class_color;
    if (!self.isEditor) {
        [self customTimeModel];
    }
    NSMutableArray * allArr = [JSUserInfo shareManager].allArray;
    if (self.isEditor) {
        for (NSInteger i=0; i<allArr.count; i++) {
            JSFastLoginModel * model1 = allArr[i];
            NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model1.class_year,model1.class_day,model1.class_hour];
            if ([str isEqualToString:str1]) {
                [allArr replaceObjectAtIndex:i withObject:self.model];
                break;
            }
        }
    } else {
        [allArr insertObject:self.model atIndex:0];
    }
    [JSUserInfo shareManager].allArray = allArr;
    NSMutableArray * array = classModel.userInfoArray;
    if (self.isEditor) {
        if (!isClass) {
            JSClassModel * deleteModel = classArr[self.class_index];
            NSMutableArray * deleteArr = deleteModel.userInfoArray;
            for (NSInteger i=0; i<deleteArr.count; i++) {
                JSFastLoginModel * model1 = deleteArr[i];
                NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model1.class_year,model1.class_day,model1.class_hour];
                if ([str isEqualToString:str1]) {
                    [deleteArr removeObject:model1];
                    break;
                }
            }
            deleteModel.userInfoArray = [NSMutableArray arrayWithArray:deleteArr];
            [classArr replaceObjectAtIndex:self.class_index withObject:deleteModel];
            [array insertObject:self.model atIndex:0];
        }else{
            for (NSInteger i=0; i<array.count; i++) {
                JSFastLoginModel * model1 = array[i];
                NSString * str = [NSString stringWithFormat:@"%@.%@.%@",model1.class_year,model1.class_day,model1.class_hour];
                if ([str isEqualToString:str1]) {
                    [array replaceObjectAtIndex:i withObject:self.model];
                    break;
                }
            }
        }
    } else {
        [array insertObject:self.model atIndex:0];
    }
    classModel.userInfoArray = [NSMutableArray arrayWithArray:array];
    [classArr replaceObjectAtIndex:self.index_count+1 withObject:classModel];
    [JSUserInfo shareManager].classArray = classArr;
    if (self.isEditor) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"editorDiaryDataNotication" object:nil userInfo:@{@"JSFastLoginModel":self.model}];
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"addDiaryDataNotication" object:nil userInfo:@{@"JSFastLoginModel":self.model}];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CalenRefreshDiaryClassNotication" object:nil userInfo:nil];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
# pragma mark - UITableViewDelegate UITableViewDatasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
        } else {
            return 150;
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
        SelectClassTableViewCell * cell = [SelectClassTableViewCell cellWithTableView:tableView];
        return cell;
    } else if(indexPath.row == 1) {
        FillContantTableViewCell * cell = [FillContantTableViewCell cellWithTableView:tableView];
        if (self.model.class_note.length==0) {
            cell.textView.PlaceHolder = NSLocalizedString(@"Start writing a diary", nil);
        } else {
            cell.textView.text = self.model.class_note;
        }
        @weakify(self);
        cell.textView.delegate = self;
        [[cell.textView rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.model.class_note = x;
        }];
        return cell;
    }else{
        POPublishPictureCell * cell = [POPublishPictureCell cellWithTableView:tableView];
        cell.isShow = NO;
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
    if (indexPath.row == 0) {
        [self.view endEditing:YES];
        WS(wSelf);
        [[JSSelectViewTool sharedManager] inpour:self.classArr currentIndexd:self.index_count confirmBlock:^(id obj, NSInteger currentIndex) {
            wSelf.navigationItem.title = (NSString*)obj;
            wSelf.index_count = currentIndex;
        } cancelBlock:nil];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    self.model.class_note = textView.text;
    [self.tableView reloadData];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
-(NSMutableArray *)realImageModes{
    if (!_realImageModes) {
        _realImageModes = [[NSMutableArray alloc]init];
    }
    return _realImageModes;
}
-(JSFastLoginModel *)model{
    if (!_model) {
        _model = [[JSFastLoginModel alloc]init];
    }
    return _model;
}
@end
