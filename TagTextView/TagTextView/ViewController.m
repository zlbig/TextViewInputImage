//
//  ViewController.m
//  TagTextView
//
//  Created by bigzl on 2018/5/30.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import "ViewController.h"

#import "UIColor+Add.h"
#import "UIImage+Add.h"

@interface TagCell ()

@property (weak, nonatomic) IBOutlet UILabel *tagLabel;

@end

@implementation TagCell

@end

@interface ViewController () <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView           *textView;
@property (weak, nonatomic) IBOutlet UILabel              *labelLimit;
@property (weak, nonatomic) IBOutlet UICollectionView     *collectionView;
@property (nonatomic, strong) NSMutableArray <NSString *> *tags;
@property (nonatomic, strong) NSMutableArray <NSString *> *tagIDs;

@property (nonatomic, strong) NSMutableAttributedString   *tagsString;

@property (nonatomic, strong) NSMutableArray <NSTextAttachment *> *attachments;
@property (nonatomic, strong) NSMutableArray <NSString *>         *tagStrs;
@property (nonatomic, strong) NSMutableArray <NSString *>         *tagIndexs;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tagsString = [[NSMutableAttributedString alloc] init];
    
    _attachments = [NSMutableArray array];
    _tagStrs = [NSMutableArray array];
    _tagIndexs = [NSMutableArray array];
    
    _textView.typingAttributes = [self getAttributes];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - method
- (IBAction)outputText:(UIButton *)sender {
    
    NSMutableArray <NSTextAttachment *> *selAttachments = [NSMutableArray array];
    NSMutableArray <NSString *> *selTagStrs = [NSMutableArray array];
    NSMutableArray <NSString *> *selTagIDs = [NSMutableArray array];
    NSMutableArray <NSString *> *selIndexs = [NSMutableArray array];
    __block NSUInteger length = 0;
    
    NSMutableAttributedString *pureAttString = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    __block NSUInteger attachmentCount = 0;
    [_textView.attributedText enumerateAttributesInRange:NSMakeRange(0, _textView.attributedText.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = attrs[@"NSAttachment"];
        if (attachment) {
            [_attachments enumerateObjectsUsingBlock:^(NSTextAttachment * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isEqual:attachment]) {
                    [pureAttString deleteCharactersInRange:NSMakeRange(range.location - attachmentCount, range.length)];
                    attachmentCount += 1;
                    
                    [selAttachments addObject:obj];
                    [selTagStrs addObject:_tagStrs[idx]];
                    [selTagIDs addObject:self.tagIDs[idx]];
                    
                    NSUInteger tagLength = _tagStrs[idx].length;
                    NSRange tagRange = NSMakeRange(range.location + length, tagLength);
                    length += tagLength - 1;
                    [selIndexs addObject:NSStringFromRange(tagRange)];
                    NSLog(@"------>>>>>> %@", NSStringFromRange(tagRange));
                }
            }];
        }
    }];
    
    _attachments = selAttachments;
    _tagStrs = selTagStrs;
    _tagIDs = selTagIDs;
    _tagIndexs = selIndexs;
    
    NSMutableString *content = [NSMutableString stringWithString:pureAttString.string];
    [_tagIndexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = NSRangeFromString(obj);
        [content insertString:_tagStrs[idx] atIndex:range.location];
    }];
    NSLog(@"--->content: %@", content);
}


- (NSDictionary *)getAttributes {
    UIFont *font = [UIFont systemFontOfSize:14];
    CGFloat lineSpace = (20 - font.lineHeight) / 2;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;
    paragraphStyle.minimumLineHeight = 20.0 - lineSpace;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle, NSForegroundColorAttributeName:[UIColor blackColor]};
    return attributes;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    _textView.typingAttributes = [self getAttributes];
    return YES;
}

#pragma mark - UICollectionViewDelegate  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.tagLabel.text = self.tags[indexPath.item];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCell *cell = (TagCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor yellowColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cell.backgroundColor = [UIColor whiteColor];
    });
    
    NSString *text = [NSString stringWithFormat:@" %@ # ", self.tags[indexPath.item]];
    UIFont *font = [UIFont systemFontOfSize:14];
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor whiteColor];
    label.text = text;
    label.textColor = [UIColor colorWithHex:0xFFBB10 alpha:1.0];
    label.font = font;
    [label sizeToFit];
    UIImage *image = [UIImage imageFromString:text attributes:@{NSFontAttributeName:font, NSForegroundColorAttributeName:[UIColor colorWithHex:0xFFBB10 alpha:1.0]} size:label.frame.size];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, font.descender, image.size.width, font.lineHeight);
    attachment.image = image;
    NSAttributedString *attImage = [NSAttributedString attributedStringWithAttachment:attachment];
    
    [_attachments addObject:attachment];
    [_tagStrs addObject:text];
    
    NSRange selectedRange = _textView.selectedRange;
    _tagsString = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [_tagsString insertAttributedString:attImage atIndex:selectedRange.location];
    _textView.attributedText = _tagsString;
    _textView.selectedRange = NSMakeRange(selectedRange.location + 1, 0);
}

#pragma mark - lazy load
- (NSMutableArray<NSString *> *)tags {
    if (!_tags) {
        _tags = [NSMutableArray array];
        do {
            NSString *tag = [NSString stringWithFormat:@"# 测试tag-%ld", _tags.count];
            [_tags addObject:tag];
        } while (_tags.count < 20);
    }
    return _tags;
}

- (NSMutableArray<NSString *> *)tagIDs {
    if (!_tagIDs) {
        _tagIDs = [NSMutableArray array];
        do {
            NSString *tag = [NSString stringWithFormat:@"10100%ld", _tagIDs.count];
            [_tagIDs addObject:tag];
        } while (_tagIDs.count < 20);
    }
    return _tagIDs;
}

@end
