//
//  XCThreadSafePthead.m
//
//  Created by 蔡腾远 on 2018/9/15.
//  Copyright © 2018年 xiaocai. All rights reserved.
//

#import "XCThreadSafeArrayPthead.h"
#import <pthread.h>
//#import "os/lock.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_arr) return nil; \
pthread_mutexattr_init(&_attr);\
pthread_mutexattr_settype(&_attr, PTHREAD_MUTEX_RECURSIVE);\
pthread_mutex_init(&_lock, &_attr);\
pthread_mutexattr_destroy(&_attr);\
return self;

#define LOCK(...) \
pthread_mutex_lock(&_lock);\
__VA_ARGS__; \
pthread_mutex_unlock(&_lock);

//#define INIT(...) self = super.init; \
//if (!self) return nil; \
//__VA_ARGS__; \
//if (!_arr) return nil; \
//_unfair_lock = OS_UNFAIR_LOCK_INIT;\
//return self;
//
//#define LOCK(...) \
//os_unfair_lock_lock(&_unfair_lock);\
//__VA_ARGS__; \
//os_unfair_lock_unlock(&_unfair_lock);

@implementation XCThreadSafeArrayPthead {
    NSMutableArray *_arr;  //Subclass a class cluster...
    pthread_mutex_t _lock;
    pthread_mutexattr_t _attr;
//    os_unfair_lock _unfair_lock;
}

#pragma mark - init

- (instancetype)init {
    INIT(_arr = [[NSMutableArray alloc] init]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_arr = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    INIT(_arr = [[NSMutableArray alloc] initWithArray:array]);
}

- (instancetype)initWithObjects:(const id[])objects count:(NSUInteger)cnt {
    INIT(_arr = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    INIT(_arr = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    INIT(_arr = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

#pragma mark - method

- (NSUInteger)count {
    LOCK(NSUInteger count = _arr.count); return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOCK(id obj = [_arr objectAtIndex:index]); return obj;
}

- (NSArray *)arrayByAddingObject:(id)anObject {
    LOCK(NSArray * arr = [_arr arrayByAddingObject:anObject]); return arr;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    LOCK(NSArray * arr = [_arr arrayByAddingObjectsFromArray:otherArray]); return arr;
}

- (BOOL)containsObject:(id)anObject {
    LOCK(BOOL c = [_arr containsObject:anObject]); return c;
}

- (void)getObjects:(id __unsafe_unretained[])objects range:(NSRange)range {
    LOCK([_arr getObjects:objects range:range]);
}

- (NSUInteger)indexOfObject:(id)anObject {
    LOCK(NSUInteger i = [_arr indexOfObject:anObject]); return i;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    LOCK(NSUInteger i = [_arr indexOfObject:anObject inRange:range]); return i;
}

- (id)firstObject {
    LOCK(id o = _arr.firstObject); return o;
}

- (id)lastObject {
    LOCK(id o = _arr.lastObject); return o;
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    LOCK(NSArray * arr = [_arr subarrayWithRange:range]) return arr;
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    LOCK(NSArray * arr = [_arr objectsAtIndexes:indexes]); return arr;
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    LOCK([_arr enumerateObjectsUsingBlock:block]);
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_arr sortedArrayUsingComparator:cmptr]); return a;
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_arr sortedArrayWithOptions:opts usingComparator:cmptr]); return a;
}

#pragma mark - mutable

- (void)addObject:(id)anObject {
    LOCK([_arr addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    LOCK([_arr insertObject:anObject atIndex:index]);
}

- (void)removeLastObject {
    LOCK([_arr removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    LOCK([_arr removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    LOCK([_arr replaceObjectAtIndex:index withObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    LOCK([_arr addObjectsFromArray:otherArray]);
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    LOCK([_arr exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)removeAllObjects {
    LOCK([_arr removeAllObjects]);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    LOCK([_arr removeObject:anObject inRange:range]);
}

- (void)removeObject:(id)anObject {
    LOCK([_arr removeObject:anObject]);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    LOCK([_arr removeObjectIdenticalTo:anObject inRange:range]);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    LOCK([_arr removeObjectIdenticalTo:anObject]);
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    LOCK([_arr removeObjectsInArray:otherArray]);
}

- (void)removeObjectsInRange:(NSRange)range {
    LOCK([_arr removeObjectsInRange:range]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    LOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    LOCK([_arr replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)setArray:(NSArray *)otherArray {
    LOCK([_arr setArray:otherArray]);
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    LOCK([_arr insertObjects:objects atIndexes:indexes]);
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    LOCK([_arr removeObjectsAtIndexes:indexes]);
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    LOCK([_arr replaceObjectsAtIndexes:indexes withObjects:objects]);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    LOCK([_arr setObject:obj atIndexedSubscript:idx]);
}


#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    LOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithArray:_arr]);
    return copiedDictionary;
}

- (void)dealloc {
    pthread_mutex_destroy(&_lock);
}

@end
