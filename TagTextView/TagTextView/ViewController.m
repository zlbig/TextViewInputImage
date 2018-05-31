//
//  ViewController.m
//  TagTextView
//
//  Created by bigzl on 2018/5/30.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import "ViewController.h"
#import "TagsTable.h"

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

/* tags 相关 */
@property (nonatomic, strong) TagsTable                   *tagTable;
@property (nonatomic, strong) NSMutableString             *text;
@property (nonatomic, strong) NSMutableString             *marekText;
@property (nonatomic, assign) BOOL                         isMarekText;
@property (nonatomic, assign) BOOL                         isDelText;
@property (nonatomic, assign) NSRange                      rangeTemp;
@property (nonatomic, assign) BOOL                         isLastText;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tagTable = [[TagsTable alloc] init];
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
    NSArray <NSString *> *tagIDs = [_tagTable getAllTagIDs];
    NSMutableString *tagIDStr = [NSMutableString string];
    [tagIDs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tagIDStr appendString:obj];
        [tagIDStr appendString:@","];
    }];
    [tagIDStr deleteCharactersInRange:NSMakeRange((tagIDStr.length - 1), 1)];
    
    NSString *msg = [NSString stringWithFormat:@"|%@| \n |%@|", _text, tagIDStr];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"标签文本" message:msg preferredStyle:1];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#define MAX_LIMIT_NUMS 140
- (void)compareTextLength {
    NSMutableAttributedString *attMu = [[NSMutableAttributedString alloc] initWithString:_textView.attributedText.string];
    __block NSInteger del = 0;
    [_tagTable.indexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange rangTag = NSRangeFromString(obj);
        rangTag.location -= del;
        rangTag.length = 1;
        [attMu deleteCharactersInRange:rangTag];
        del += 1;
    }];
    
    _text = [NSMutableString stringWithString:attMu.string];
    if (_tagTable.indexs.count > 0) {
        NSArray <NSString *> *indexsTemp = [[NSArray alloc] initWithArray:_tagTable.indexs copyItems:YES];
        __block NSUInteger tagValueLength = 0;
        [indexsTemp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange rangeTag = NSRangeFromString(obj);
            NSString *tagValue = [_tagTable tagValueForKey:obj];
            [_text insertString:tagValue atIndex:(rangeTag.location + tagValueLength)];
            tagValueLength += rangeTag.length - 1;
        }];
        indexsTemp = nil;
    }
    
    NSInteger existTextNum = [self pp_getStringLengthWithString:_text];
    NSArray <NSAttributedString *> *attrss = [_tagTable getAllTagAttrss];
    if (existTextNum > MAX_LIMIT_NUMS) {
        NSMutableAttributedString *attMu = [[NSMutableAttributedString alloc] initWithString:_textView.text];
        if (attrss.count > 0) {
            [attrss enumerateObjectsUsingBlock:^(NSAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange rangeTag = NSRangeFromString([_tagTable getTagIndex:idx]);
                [attMu deleteCharactersInRange:NSMakeRange(rangeTag.location, 1)];
                [attMu insertAttributedString:obj atIndex:rangeTag.location];
            }];
        }
        [attMu deleteCharactersInRange:[attMu.string rangeOfComposedCharacterSequenceAtIndex:attMu.length - 1]];
        if (!_isLastText) {
            NSString *obj = _tagTable.indexs.lastObject;
            NSUInteger idx = [_tagTable.indexs indexOfObject:obj];
            NSRange rangeLastTag = NSRangeFromString(obj);
            _text = [NSMutableString stringWithString:[_text substringWithRange:NSMakeRange(0, _text.length - rangeLastTag.length)]];
            [_tagTable removeTagKey:obj index:idx];
            existTextNum -= rangeLastTag.length;
        } else {
            _text = [NSMutableString stringWithString:[_text substringWithRange:NSMakeRange(0, 140)]];
        }
        
        [attMu addAttributes:[self getAttributes] range:NSMakeRange(0, attMu.length)];        
        _textView.attributedText = attMu;
        [_textView resignFirstResponder];
        attrss = nil;
    } else {
        NSRange selectedRange = _textView.selectedRange;
        NSMutableAttributedString *attMu = [[NSMutableAttributedString alloc] initWithString:_textView.text];
        if (attrss.count > 0) {
            [attrss enumerateObjectsUsingBlock:^(NSAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange rangeTag = NSRangeFromString([_tagTable getTagIndex:idx]);
                [attMu deleteCharactersInRange:NSMakeRange(rangeTag.location, 1)];
                [attMu insertAttributedString:obj atIndex:rangeTag.location];
            }];
        }
        NSUInteger offset = _textView.attributedText.length - attMu.length;
        [attMu addAttributes:[self getAttributes] range:NSMakeRange(0, attMu.length)];
        _textView.attributedText = attMu;
        _textView.selectedRange = NSMakeRange(selectedRange.location - offset, 0);
        attrss = nil;
    }
    //不让显示负数
    _labelLimit.text = [NSString stringWithFormat:@"还可以输入%ld个字", (MAX_LIMIT_NUMS - MIN(existTextNum, MAX_LIMIT_NUMS))];
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

- (NSInteger)pp_getStringLengthWithString:(NSString *)string {
    __block NSInteger stringLength = 0;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
     {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff)
         {
             if (substring.length > 1)
             {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f)
                 {
                     stringLength += 1;
                 }
                 else
                 {
                     stringLength += 1;
                 }
             }
             else
             {
                 stringLength += 1;
             }
         } else if (substring.length > 1)
         {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3)
             {
                 stringLength += 1;
             }
             else
             {
                 stringLength += 1;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff)
             {
                 stringLength += 1;
             }
             else if (0x2B05 <= hs && hs <= 0x2b07)
             {
                 stringLength += 1;
             }
             else if (0x2934 <= hs && hs <= 0x2935)
             {
                 stringLength += 1;
             }
             else if (0x3297 <= hs && hs <= 0x3299)
             {
                 stringLength += 1;
             }
             else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50)
             {
                 stringLength += 1;
             }
             else
             {
                 stringLength += 1;
             }
         }
     }];
    
    return stringLength;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length <= 0) {
        _isDelText = YES;
        _rangeTemp = range;
    } else {
        _isDelText = NO;
        _rangeTemp = NSMakeRange(range.location, text.length);
        [_marekText appendString:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        if (_isDelText) {
            // 删除高亮状态字符的时候，计算是否删除最后一位长度
            if (_marekText.length > 1) {
                _isMarekText = YES;
                [_marekText deleteCharactersInRange:NSMakeRange(0, 1)];
            }
        }
        return;
    }
    // 删除高亮状态字符的时候，计算是否删除最后一位长度
    if (_marekText.length == 1 && _isMarekText) {
        // 清空所有
        _isMarekText = NO;
        _marekText = [NSMutableString string];
        _rangeTemp = NSMakeRange(9999, 0);
        return;
    }
    _marekText = [NSMutableString string];
    if (_rangeTemp.location == 9999) {
        return;
    }
    if (_isDelText) {
        // 删除文本，更新 tags range
        if (_tagTable.indexs.count > 0) {
            NSArray <NSString *> *indexsTemp = [[NSArray alloc] initWithArray:_tagTable.indexs copyItems:YES];
            __block BOOL isDelTags = NO;
            [indexsTemp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange rangTag = NSRangeFromString(obj);
                if (rangTag.location == _rangeTemp.location) {
                    isDelTags = YES;
                    [_tagTable removeTagKey:obj index:idx];
                } else if (rangTag.location > _rangeTemp.location) {
                    rangTag.location -= _rangeTemp.length;
                    if (_tagTable.indexs.count > 0) {
                        if (_tagTable.indexs.count == 1) {
                            [_tagTable replaceTagIndexAtIndex:0 withNewTagIndex:NSStringFromRange(rangTag)];
                        } else {
                            NSInteger index = idx;
                            if (isDelTags) {
                                index = idx - 1;
                            }
                            [_tagTable replaceTagIndexAtIndex:index withNewTagIndex:NSStringFromRange(rangTag)];
                        }
                    }
                } else {
                    
                }
            }];
            indexsTemp = nil;
        }
    } else {
        // 插入文本，更新 tags range
        if (_tagTable.indexs.count > 0) {
            NSArray <NSString *> *indexsTemp = [[NSArray alloc] initWithArray:_tagTable.indexs copyItems:YES];
            [indexsTemp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSRange rangTag = NSRangeFromString(obj);
                if (rangTag.location >= _rangeTemp.location) {
                    NSUInteger location = rangTag.location + _rangeTemp.length;
                    rangTag.location = location;
                    [_tagTable replaceTagIndexAtIndex:idx withNewTagIndex:NSStringFromRange(rangTag)];
                }
            }];
        }
    }
    _isLastText = YES;
    [self compareTextLength];
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
    
    NSRange selectedRange = _textView.selectedRange;
    
    // text 首位均添加“ ”，添加到 tags 里时需要注意
    // 如果需要移除首位“ ”时，rangeTag 需要 rangge.length - 2，同时，text 也需要移除首位“ ”
    NSRange rangeCurTag = NSMakeRange(selectedRange.location, text.length);
    
    // 插入 tag ，更新 tags range
    __block BOOL needUpdate = NO;
    if (_tagTable.indexs.count > 0) {
        NSArray <NSString *> *indexsTemp = [[NSArray alloc] initWithArray:_tagTable.indexs copyItems:YES];
        [indexsTemp enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange rangeTag = NSRangeFromString(obj);
            if (rangeTag.location >= rangeCurTag.location) {
                needUpdate = YES;
                NSUInteger location = rangeTag.location + attImage.length;
                rangeTag.location = location;
                [_tagTable replaceTagIndexAtIndex:idx withNewTagIndex:NSStringFromRange(rangeTag)];
            }
        }];
    }
    
    [_tagTable addTagIndex:NSStringFromRange(rangeCurTag)];
    [_tagTable setTagValue:text forKey:NSStringFromRange(rangeCurTag)];
    [_tagTable setTagAttrs:attImage forKey:NSStringFromRange(rangeCurTag)];
//    tag 对应的 id
    [_tagTable setTagID:self.tagIDs[indexPath.item] forKey:NSStringFromRange(rangeCurTag)];
    if (needUpdate) {
        [_tagTable reloadData];
    }
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithAttributedString:_textView.attributedText];
    [att insertAttributedString:attImage atIndex:selectedRange.location];
    _textView.attributedText = att;
    _textView.selectedRange = NSMakeRange(selectedRange.location + 1, 0);
    _isLastText = NO;
    [self compareTextLength];
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
