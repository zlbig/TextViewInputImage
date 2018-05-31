//
//  TagsTable.h
//  TagTextView
//
//  Created by bigzl on 2018/5/31.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagsTable : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 只读，不要做任何增删操作
 */
@property (nonatomic, readonly) NSMutableArray <NSString *> *indexs;

// 添加 key：index 值
- (void)addTagIndex:(NSString *)tagIndex;
- (void)setTagValue:(NSString *)tagValue forKey:(NSString *)key;
- (void)setTagAttrs:(NSAttributedString *)tagAttrs forKey:(NSString *)key;
- (void)setTagID:(NSString *)tagID forKey:(NSString *)key;

// 获取 key：index 值
- (NSString *)getTagIndex:(NSInteger)idx;
- (NSString *)tagValueForKey:(NSString *)key;
- (NSAttributedString *)tagAttrsForKey:(NSString *)key;

// 获取所有的数据
// 实际索引
- (NSArray <NSString *> *)getAllTagIndexs;
- (NSArray <NSString *> *)getAllTagValues;
- (NSArray <NSAttributedString *> *)getAllTagAttrss;
- (NSArray <NSString *> *)getAllTagIDs;

// 删除
- (void)removeTagKey:(NSString *)key index:(NSInteger)idx;

// 替换
- (void)replaceTagIndexAtIndex:(NSInteger)idx withNewTagIndex:(NSString *)newTagIndex;

// 刷新数据
- (void)reloadData;

- (void)clean;

@end

NS_ASSUME_NONNULL_END

