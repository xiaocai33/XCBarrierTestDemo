//
//  ViewController.m
//  XCBarrierTestDemo
//
//  Created by 蔡腾远 on 2018/9/15.
//  Copyright © 2018年 xiaocai. All rights reserved.
//

#import "ViewController.h"
#import "XCThreadSafeArrayPthead.h"
#import "XCThreadSafeArrayBarrier.h"
#import "XCThreadSafeArrayRecursive.h"
#import "XCThreadSafeArraySemaphore.h"
#import "XCThreadSafePthreadMutex.h"

#define TICK(i, str)   NSDate *startTime##str##i = [NSDate date]
#define TOCK(i, str)   NSLog(@"%@, Time%d: %f", @#str, i, -[startTime##str##i timeIntervalSinceNow])
#define CALC(i, str) double value = dictionary[@#str].doubleValue; \
dictionary[@#str] = @(-[startTime##str##i timeIntervalSinceNow] + value);

#define TestArrayThreadSafeMode(identifier,array,time,loop,ratio) \
@autoreleasepool {  \
TICK(time, identifier); \
dispatch_apply(loop, self.barrierQueue, ^(size_t i) {   \
if(!(i % ratio)) { \
[array addObject:[NSString stringWithFormat:@"abc%d",loop]];\
} else {    \
for (NSString *temp in array) {\
__unused NSString * temp1 = temp;\
}\
}   \
}); \
dispatch_barrier_sync(self.barrierQueue, ^{ \
TOCK(time, identifier); \
CALC(time, identifier); \
}); \
}

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) dispatch_queue_t barrierQueue;

@end

@implementation ViewController

NSMutableDictionary<NSString *,NSNumber *> *dictionary;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"Thread Safe Mutable Test";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];

    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    
    dictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    self.barrierQueue = dispatch_queue_create("barrier", DISPATCH_QUEUE_CONCURRENT);
    
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = @"数组加锁性能测试";
    } else {
        cell.textLabel.text = @"死锁验证";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self arrayPerformanceTest];
    } else {
        [self test_ThreadSafeArray];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"数组测试";
    } else {
        return @"性能测试";
    }
}


#pragma mark - Performance Test
- (void)arrayPerformanceTest {
    
    int loop = 10000; //loop times
    int times = 50; //test times
    int ratio = 5; //the ratio of read to write
    for (int i = 0; i < times; i++) {
        XCThreadSafeArraySemaphore *array = [[XCThreadSafeArraySemaphore alloc] init];
        XCThreadSafeArrayPthead *array1 = [[XCThreadSafeArrayPthead alloc] init];
        XCThreadSafeArrayRecursive *array2 = [[XCThreadSafeArrayRecursive alloc] init];
        XCThreadSafeArrayBarrier *array3 = [[XCThreadSafeArrayBarrier alloc] init];
        XCThreadSafePthreadMutex *array4 = [[XCThreadSafePthreadMutex alloc] init];
        
        TestArrayThreadSafeMode(XCThreadSafeArraySemaphore,array,i,loop,ratio)
        TestArrayThreadSafeMode(XCThreadSafeArrayPthead,array1,i,loop,ratio)
        TestArrayThreadSafeMode(XCThreadSafeArrayRecursive,array2,i,loop,ratio)
        TestArrayThreadSafeMode(XCThreadSafeArrayBarrier,array3,i,loop,ratio)
        TestArrayThreadSafeMode(XCThreadSafePthreadMutex,array4,i,loop,ratio)
    }
    dispatch_barrier_sync(self.barrierQueue, ^{
        NSLog(@"%@", dictionary);
        [dictionary removeAllObjects];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)test_ThreadSafeArray {
//    XCThreadSafeArrayBarrier *arr = [[XCThreadSafeArrayBarrier alloc] init]; // 无问题
    XCThreadSafeArraySemaphore *arr = [[XCThreadSafeArraySemaphore alloc] init]; // 或者 XCThreadSafePthreadMutex 死锁
    
    for (int i=0; i<100; i++) {
        [arr addObject:@(i)];
    }
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr count];
        if (idx == arr.count - 1) {
            NSLog(@" index:%ld , count:%ld",idx,arr.count);
        }
    }];
    NSLog(@"finished");
}


@end
