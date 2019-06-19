#import "POPublishPictureCell.h"
#import "JSPictureManager.h"
#define PictureSize (ScreenWidth-60)/3
@interface POPublishPictureCell ()
@property (nonatomic,strong) NSMutableArray *picImageViewArray;
@property (nonatomic,strong) NSMutableArray *addBtnsArray;
@property (nonatomic,strong) NSMutableArray *deleteBtnsArray;
@property (nonatomic,strong) JSPictureManager * pictureManager;
@end
@implementation POPublishPictureCell
+ (POPublishPictureCell *)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"POPublishPictureCell";
    POPublishPictureCell *cell=(POPublishPictureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if(cell == nil) {
        UINib *nib = [UINib nibWithNibName:identifier bundle:[NSBundle bundleForClass:[NSClassFromString(@"POPublishPictureCell") class]]];
        [tableView registerNib:nib forCellReuseIdentifier:identifier];
        cell = (POPublishPictureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, ScreenWidth)];
    }
    return cell;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}
-(void)layoutBgPictureScrollview{
    for (UIView *view in self.bgPictureScrollview.subviews) {
        [view removeFromSuperview];
    }
    for (int i=0; i<9; i++) {
        UIImageView *picImageView=self.picImageViewArray[i];
        UIButton *addBtn=self.addBtnsArray[i];
        UIButton *deleteBtn=self.deleteBtnsArray[i];
        [self.bgPictureScrollview addSubview:picImageView];
        if (!self.isShow) {
            [self.bgPictureScrollview addSubview:addBtn];
            [self.bgPictureScrollview addSubview:deleteBtn];
        }
        picImageView.hidden=NO;
        addBtn.hidden=NO;
        deleteBtn.hidden=NO;
        if (i<self.realImageModes.count) {
            JSImageModel * model = self.realImageModes[i];
            model.imageView = picImageView;
            picImageView.image = model.image;
            picImageView.hidden=NO;
            addBtn.hidden=NO;
            deleteBtn.hidden=NO;
        } else if (i==self.realImageModes.count&&!self.isShow) {
            picImageView.hidden=NO;
            picImageView.image = [UIImage imageNamed:@"po_add_image_biding"];
            addBtn.hidden=NO;
            deleteBtn.hidden=YES;
        } else {
            picImageView.hidden=YES;
            addBtn.hidden=YES;
            deleteBtn.hidden=YES;
        }
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(void)addAction:(UIButton *)sender{
    if (sender.tag - 1000 == self.realImageModes.count ) {
        WS(wSelf);
        [self.pictureManager getMultiplePictureInViewController:self.delegateViewController count:9-self.realImageModes.count block:^(NSArray *images, NSString *errorStr) {
            for (int i =0; i < images.count; i++) {
                JSImageModel * model = [[JSImageModel alloc]init];
                model.image = images[i] ;
                [wSelf.realImageModes addObject:model];
            }
            if (wSelf.refreshTableView) {
                wSelf.refreshTableView();
            }
        }];
    } else {
        if (self.realImageModes[sender.tag - 1000].state == ImageLoadingFaild) {
            [self.realImageModes[sender.tag - 1000] reloadPic];
        }
    }
}
-(void)deleteAction:(UIButton *)sender{
    JSImageModel * model = self.realImageModes[sender.tag-2000];
    model.state = ImageDeleted;
    [self.realImageModes removeObject:model];
    if (_refreshTableView) {
        _refreshTableView();
    }
}
-(JSPictureManager *)pictureManager{
    if (!_pictureManager) {
        _pictureManager=[[JSPictureManager alloc]init];
    }
    return _pictureManager;
}
-(NSMutableArray *)picImageViewArray{
    if (!_picImageViewArray) {
        _picImageViewArray=[[NSMutableArray alloc]init];
        for (int i=0; i<9; i++) {
            UIImageView *picImageView=[[UIImageView alloc]initWithFrame:CGRectMake((i%3)*(PictureSize+15), 15+(i/3)*(PictureSize+15), PictureSize, PictureSize)];
            picImageView.contentMode = UIViewContentModeScaleAspectFill;
            picImageView.layer.cornerRadius = 3;
            picImageView.clipsToBounds = YES;
            [_picImageViewArray addObject:picImageView];
        }
    }
    return _picImageViewArray;
}
-(NSMutableArray *)addBtnsArray{
    if (!_addBtnsArray) {
        _addBtnsArray=[[NSMutableArray alloc]init];
        for (int i=0; i<9; i++) {
            UIButton *addBtn=[[UIButton alloc]initWithFrame:CGRectMake((i%3)*(PictureSize+15), 15+(i/3)*(PictureSize+15), PictureSize, PictureSize)];
            [addBtn addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
            addBtn.tag=i+1000;
            [_addBtnsArray addObject:addBtn];
        }
    }
    return _addBtnsArray;
}
-(NSMutableArray *)deleteBtnsArray{
    if (!_deleteBtnsArray) {
        _deleteBtnsArray=[[NSMutableArray alloc]init];
    }
    for (int i=0; i<9; i++) {
        UIButton *deleteBtn=[[UIButton alloc]init];
        deleteBtn.center=CGPointMake(PictureSize+(PictureSize+15)*(i%3), 15+(i/3)*(PictureSize+15));
        deleteBtn.bounds=CGRectMake(0, 0, 30, 30);
        [deleteBtn setImage:[UIImage imageNamed:@"po_delete_biding"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteBtn.tag=i+2000;
        [_deleteBtnsArray addObject:deleteBtn];
    }
    return _deleteBtnsArray;
}
-(NSMutableArray *)realImageModes{
    if (!_realImageModes) {
        _realImageModes = [[NSMutableArray alloc]init];
    }
    return _realImageModes;
}
@end
