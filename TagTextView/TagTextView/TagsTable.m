//
//  TagsTable.m
//  TagTextView
//
//  Created by bigzl on 2018/5/31.
//  Copyright © 2018年 bigzl. All rights reserved.
//

#import "TagsTable.h"

@interface TagsTable ()

@property (nonatomic, strong) NSMutableArray <NSString *> *indexs;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *tags;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSAttributedString *> *attrsImages;
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSString *> *tagIDs;

@end

@implementation TagsTable

#pragma mark - add
- (void)addTagIndex:(NSString *)tagIndex {
    [self.indexs addObject:tagIndex];
}

- (void)setTagValue:(NSString *)tagValue forKey:(NSString *)key {
    NSInteger idx = [_indexs indexOfObject:key];
    key = [self configKey:key index:idx];
    [self.tags setObject:tagValue forKey:key];
}

- (void)setTagAttrs:(NSAttributedString *)tagAttrs forKey:(NSString *)key {
    NSInteger idx = [_indexs indexOfObject:key];
    key = [self configKey:key index:idx];
    [self.attrsImages setObject:tagAttrs forKey:key];
}

- (void)setTagID:(NSString *)tagID forKey:(NSString *)key {
    NSInteger idx = [_indexs indexOfObject:key];
    key = [self configKey:key index:idx];
    [self.tagIDs setObject:tagID forKey:key];
}

#pragma mark - get
- (NSString *)getTagIndex:(NSInteger)idx {
    NSAssert(self.indexs[idx], @"******非法取值******");
    return self.indexs[idx];
}

- (NSString *)tagValueForKey:(NSString *)key {
    NSInteger idx = [_indexs indexOfObject:key];
    key = [self configKey:key index:idx];
    return [self.tags objectForKey:key];
}

- (NSAttributedString *)tagAttrsForKey:(NSString *)key {
    NSInteger idx = [_indexs indexOfObject:key];
    key = [self configKey:key index:idx];
    return [self.attrsImages objectForKey:key];
}

#pragma mark - all data
- (NSArray<NSString *> *)getAllTagIndexs {
    __block NSUInteger length = 0;
    NSMutableArray <NSString *> *indexs = [NSMutableArray array];
    [self.indexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = NSRangeFromString(obj);
        range.location += length;
        length += range.length - 1;
        [indexs addObject:NSStringFromRange(range)];
    }];
    return indexs;
}

- (NSArray<NSString *> *)getAllTagValues {
    NSMutableArray <NSString *> *attrss = [NSMutableArray array];
    [self.indexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [self configKey:obj index:idx];
        [attrss addObject:[self.tags objectForKey:key]];
    }];
    return [[NSArray alloc] initWithArray:attrss copyItems:YES];
}

- (NSArray<NSAttributedString *> *)getAllTagAttrss {
    NSMutableArray <NSAttributedString *> *attrss = [NSMutableArray array];
    [self.indexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [self configKey:obj index:idx];
        [attrss addObject:[self.attrsImages objectForKey:key]];
    }];
    return [[NSArray alloc] initWithArray:attrss copyItems:YES];
}

- (NSArray<NSString *> *)getAllTagIDs {
    NSMutableArray <NSString *> *attrss = [NSMutableArray array];
    [self.indexs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = [self configKey:obj index:idx];
        [attrss addObject:[self.tagIDs objectForKey:key]];
    }];
    return [[NSArray alloc] initWithArray:attrss copyItems:YES];
}

#pragma method
- (void)removeTagKey:(NSString *)key index:(NSInteger)idx {
    NSInteger index = [_indexs indexOfObject:key];
    key = [self configKey:key index:index];
    
    [self.indexs removeObjectAtIndex:idx];
    [self.tags removeObjectForKey:key];
    [self.attrsImages removeObjectForKey:key];
    
    [self reloadValues];
}

- (void)replaceTagIndexAtIndex:(NSInteger)idx withNewTagIndex:(NSString *)newTagIndex {
    NSString *oldKey = self.indexs[idx];
    [self.indexs replaceObjectAtIndex:idx withObject:newTagIndex];
    
    oldKey = [self configKey:oldKey index:idx];
    newTagIndex = [self configKey:newTagIndex index:idx];
    
    NSString *tagValue = self.tags[oldKey];
    [self.tags removeObjectForKey:oldKey];
    [self.tags setObject:tagValue forKey:newTagIndex];
    
    NSAttributedString *tagAttrs = self.attrsImages[oldKey];
    [self.attrsImages removeObjectForKey:oldKey];
    [self.attrsImages setObject:tagAttrs forKey:newTagIndex];
    
    NSString *tagID = self.tagIDs[oldKey];
    [self.tagIDs removeObjectForKey:oldKey];
    [self.tagIDs setObject:tagID forKey:newTagIndex];
}

- (void)reloadData {
    [self.indexs sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSRange range1 = NSRangeFromString(obj1);
        NSRange range2 = NSRangeFromString(obj2);
        NSNumber *num1 = [NSNumber numberWithInteger:range1.location];
        NSNumber *num2 = [NSNumber numberWithInteger:range2.location];
        return [num1 compare:num2];
    }];
    [self reloadValues];
}

- (void)reloadValues {
    NSMutableDictionary <NSString *, NSString *> *tagsTemp = [NSMutableDictionary dictionary];
    [_tags.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *rangeStr = [obj componentsSeparatedByString:@"-"][0];
        NSInteger index = [_indexs indexOfObject:rangeStr];
        NSString *key = [self configKey:rangeStr index:index];
        NSString *value = [_tags objectForKey:obj];
        [tagsTemp setObject:value forKey:key];
    }];
    
    NSMutableDictionary <NSString *, NSAttributedString *> *attrsImageTemp = [NSMutableDictionary dictionary];
    [_attrsImages.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *rangeStr = [obj componentsSeparatedByString:@"-"][0];
        NSInteger index = [_indexs indexOfObject:rangeStr];
        NSString *key = [self configKey:rangeStr index:index];
        NSAttributedString *value = [_attrsImages objectForKey:obj];
        [attrsImageTemp setObject:value forKey:key];
    }];
    
    NSMutableDictionary <NSString *, NSString *> *tagIDsTemp = [NSMutableDictionary dictionary];
    [_tagIDs.allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *rangeStr = [obj componentsSeparatedByString:@"-"][0];
        NSInteger index = [_indexs indexOfObject:rangeStr];
        NSString *key = [self configKey:rangeStr index:index];
        NSString *value = [_tagIDs objectForKey:obj];
        [tagIDsTemp setObject:value forKey:key];
    }];
    
    _tags = tagsTemp;
    _attrsImages = attrsImageTemp;
    _tagIDs = tagIDsTemp;
}

- (void)clean {
    [self.indexs removeAllObjects];
    [self.tags removeAllObjects];
    [self.attrsImages removeAllObjects];
}

#pragma mark - private
- (NSString *)configKey:(NSString *)key index:(NSInteger)idx {
    return [NSString stringWithFormat:@"%@-%ld", key, idx];
}

#pragma mark - lazy load
- (NSMutableArray<NSString *> *)indexs {
    if (!_indexs) {
        _indexs = [NSMutableArray array];
    }
    return _indexs;
}

- (NSMutableDictionary<NSString *,NSString *> *)tags {
    if (!_tags) {
        _tags = [NSMutableDictionary dictionary];
    }
    return _tags;
}

- (NSMutableDictionary<NSString *,NSAttributedString *> *)attrsImages {
    if (!_attrsImages) {
        _attrsImages = [NSMutableDictionary dictionary];
    }
    return _attrsImages;
}

- (NSMutableDictionary<NSString *,NSString *> *)tagIDs {
    if (!_tagIDs) {
        _tagIDs = [NSMutableDictionary dictionary];
    }
    return _tagIDs;
}

@end
