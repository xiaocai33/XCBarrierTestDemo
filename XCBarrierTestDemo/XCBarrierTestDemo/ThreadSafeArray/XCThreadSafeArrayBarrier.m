//
//  XCThreadSafeBarrier.m
//
//  Created by 蔡腾远 on 2018/9/15.
//  Copyright © 2018年 xiaocai. All rights reserved.
//

#import "XCThreadSafeArrayBarrier.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_array) return nil; \
NSString* uuid = [NSString stringWithFormat:@"com.cty._%p", self]; \
_syncQueue = dispatch_queue_create([uuid UTF8String], DISPATCH_QUEUE_CONCURRENT); \
return self;

#define SYNC(block)\
dispatch_sync(_syncQueue, block);

#define BARRIER(block)\
dispatch_barrier_async(_syncQueue, block);


@implementation XCThreadSafeArrayBarrier {
    NSMutableArray *_array;
    dispatch_queue_t _syncQueue;
}

#pragma mark - init

- (instancetype)init {
    INIT(_array = [[NSMutableArray alloc] init]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_array = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    INIT(_array = [[NSMutableArray alloc] initWithArray:array]);
}

- (instancetype)initWithObjects:(const id[])objects count:(NSUInteger)cnt {
    INIT(_array = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    INIT(_array = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    INIT(_array = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

#pragma mark - 数据操作方法 (凡涉及更改数组中元素的操作，使用异步派发+栅栏块；读取数据使用 同步派发+并行队列)
#pragma mark - method
- (NSUInteger)count{
    __block NSUInteger count;
    SYNC(^{count = self->_array.count;}); return count;
    
}

- (id)objectAtIndex:(NSUInteger)index{
    
    __block id obj;
    SYNC(^{
        if (index < [self->_array count]) {
            obj = self->_array[index];
        }
    });
    return obj;
}

- (BOOL)containsObject:(id)anObject {
    __block BOOL c;
    SYNC(^{c = [self->_array containsObject:anObject];}); return c;
}

- (void)getObjects:(id __unsafe_unretained[])objects range:(NSRange)range {
    SYNC(^{[self->_array getObjects:objects range:range];});
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    __block NSUInteger i;
    SYNC(^{i = [self->_array indexOfObject:anObject inRange:range];}); return i;
}

- (id)firstObject {
    __block id o;
    SYNC(^{o = self->_array.firstObject;}); return o;
}

- (id)lastObject {
    __block id o;
    SYNC(^{o = self->_array.lastObject;}); return o;
}

- (NSUInteger)indexOfObject:(id)anObject{
    
    __block NSUInteger index = NSNotFound;
    SYNC(^{
        for (int i = 0; i < [self->_array count]; i ++) {
            if ([self->_array objectAtIndex:i] == anObject) {
                index = i;
                break;
            }
        }
    });
    return index;
}

- (NSEnumerator *)objectEnumerator{
    __block NSEnumerator *enu;
    SYNC(^{enu = [self->_array objectEnumerator];}); return enu;
}

- (NSEnumerator *)reverseObjectEnumerator {
    __block NSEnumerator *e;
    SYNC(^{e = [self->_array reverseObjectEnumerator];}); return e;
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    __block NSArray *arr;
    SYNC(^{arr = [self->_array subarrayWithRange:range];}); return arr;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    SYNC(^{[self->_array enumerateObjectsUsingBlock:block];});
}


#pragma mark - mutable
- (void)insertObject:(id)anObject atIndex:(NSUInteger)index{
    BARRIER(^{
        if (anObject && index < [self->_array count]) {
            [self->_array insertObject:anObject atIndex:index];
        }
    });
}

- (void)addObject:(id)anObject{
    
    BARRIER(^{
        if(anObject){
            [self->_array addObject:anObject];
        }
    });
}

- (void)removeObjectAtIndex:(NSUInteger)index{
    BARRIER(^{
        if (index < [self->_array count]) {
            [self->_array removeObjectAtIndex:index];
        }
    });
}

- (void)removeLastObject{
    BARRIER(^{[self->_array removeLastObject];});
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    BARRIER(^{
        if (anObject && index < [self->_array count]) {
            [self->_array replaceObjectAtIndex:index withObject:anObject];
        }
    });
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    BARRIER(^{[self->_array addObjectsFromArray:otherArray];});
}

- (void)removeAllObjects {
    BARRIER(^{[self->_array removeAllObjects];});
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    BARRIER(^{[self->_array removeObject:anObject inRange:range];});
}

- (void)removeObject:(id)anObject {
    BARRIER(^{[self->_array removeObject:anObject];});
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    BARRIER(^{[self->_array removeObjectsInArray:otherArray];});
}

- (void)removeObjectsInRange:(NSRange)range {
    BARRIER(^{[self->_array removeObjectsInRange:range];});
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    BARRIER(^{[self->_array replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];});
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    BARRIER(^{[self->_array replaceObjectsInRange:range withObjectsFromArray:otherArray];});
}

- (void)setArray:(NSArray *)otherArray {
    BARRIER(^{[self->_array setArray:otherArray];});
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    BARRIER(^{[self->_array insertObjects:objects atIndexes:indexes];});
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    BARRIER(^{[self->_array removeObjectsAtIndexes:indexes];});
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    BARRIER(^{[self->_array replaceObjectsAtIndexes:indexes withObjects:objects];});
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    BARRIER(^{[self->_array setObject:obj atIndexedSubscript:idx];});
}


- (void)dealloc{
    if (_syncQueue) {
        _syncQueue = NULL;
    }
}

@end
