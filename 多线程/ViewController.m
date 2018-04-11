//
//  ViewController.m
//  多线程
//
//  Created by apple on 2018/3/6.
//  Copyright © 2018年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //
    [self dispatchQueueKnowledge];
    
    //[self mainQueue];
    
   // [self serialQueue];
    
    //[self globalQueue];
    
    [self concurrentQueue];
    
    
}

- (void)dispatchQueueKnowledge{
    // 进程：正在进行中的一个程序叫做一个进程，负责程序运行的内存分配，每一个进程都有自己的虚拟内存空间
    // 线程：线程是进程中独立的执行路径（就是一个任务），一个进程至少包含一条线程（主线程），
    
    // 队列
    // 主线程队列  每一个程序应用中对应唯一一个主线程队列（也是一种串行队列）
    //dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // 全局队列 （也是一种并行队列）
   // dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    // 串行队列
   // dispatch_queue_t serialQueue = dispatch_queue_create("com.serial.queue", DISPATCH_QUEUE_SERIAL);
    // 并行队列
   // dispatch_queue_t concurrentQueue = dispatch_queue_create("com.concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    // 操作（也叫做派发）
    // 同步操作  dispatch_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>),会依次按顺序执行，能够决定任务的执行顺序，一般不开启线程,阻塞当前线程
    // 同步派遣能够将队列调度到当前线程（不一定是主线程，也可能是子线程）
    // 异步操作  dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)，会并发执行，无法确定任务的执行顺序（串行队列除外）
   // ，一般开启线程（主队列除外），不会阻塞当前线程
    // 异步派遣能够将队列调度到别的子线程上去
    
    
}
// 主队列
- (void)mainQueue{
     dispatch_queue_t mainQueue = dispatch_get_main_queue();
    // 主线程队列同步，死锁,原因是sync操作会阻塞线程，需要等待block执行完返回，主线程队列的任务都是按顺序执行，但此时主线程正在执行dispatchQueueKnowledge这个方法，block需要主线程当前任务执行完之后才能执行，但主线程此时又在等待sync操作返回才能继续执行，所以主线程的任务是不可能完成的，而block也是不可能执行的，这样就成了互相等待，造成了死锁
    /*dispatch_sync(mainQueue, ^{
     NSLog(@"死锁");
     });*/
    // 解决办法是使用异步操作,原因是async是立即返回的，不需要等待block执行完之后再返回，主线程队列中使用异步操作不会开启新的线程，他是把当前任务的优先级降低，等到主线程空闲的时候再来执行这个任务
    dispatch_async(mainQueue, ^{
        NSLog(@"111-----%@",[NSThread currentThread]);
    });
    dispatch_async(mainQueue, ^{
        NSLog(@"222-----%@",[NSThread currentThread]);
    });
    dispatch_async(mainQueue, ^{
        NSLog(@"333-----%@",[NSThread currentThread]);
    });
    /**打印结果
     2018-03-07 14:39:53.910985+0800 多线程[1680:436490] 111-----<NSThread: 0x608000071280>{number = 1, name = main}
     2018-03-07 14:39:53.911123+0800 多线程[1680:436490] 222-----<NSThread: 0x608000071280>{number = 1, name = main}
     2018-03-07 14:39:53.911248+0800 多线程[1680:436490] 333-----<NSThread: 0x608000071280>{number = 1, name = main}
     */
    // 通过以上输出结果我们可以得出结论，主队列使用异步操作还是按顺序执行，并且任务还是在主线程中执行
    
}
// 串行队列
- (void)serialQueue{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.serial.queue", DISPATCH_QUEUE_SERIAL);
    // 串行队列同步
    dispatch_sync(serialQueue, ^{
        NSLog(@"111-----%@",[NSThread currentThread]);
        //serialQueue-----<NSThread: 0x608000262300>{number = 1, name = main}
        //这里打印出来的线程是主线程，其实这是不确定的
        
        // 这里我我也很疑问，既然是串行队列，并且最后打印出来的线程是主线程，这不就和主线程队列同步操作一样吗，为什么这里没有发生死锁呢
        // 去看苹果文档发现对dispatch_sync解释的最后一句话
        // As an optimization, this function invokes the block on the current thread when possible.
        // 作为一个优化，执行这个block尽可能的在当前线程执行
        // 所以我猜想这是苹果系统内部做的一个优化，因为当前线程是主线程，所以他在主线程运行，假设这个时候在其他的子线程进行的话，那么打印出来的结果就应该子线程了,可以运行这段代码进行验证一下
        /*dispatch_async(dispatch_get_global_queue(0, 0), ^{
         NSLog(@"%@",[NSThread currentThread]);
         dispatch_sync(serialQueue, ^{
         NSLog(@"ceshiceshi%@",[NSThread currentThread]);
         });
         });*/
       
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"全局队列----%@",[NSThread currentThread]);
        //2018-03-07 14:48:05.360076+0800 多线程[1744:452769] 全局队列----<NSThread: 0x60000046f440>{number = 3, name = (null)}
        dispatch_sync(serialQueue, ^{
            NSLog(@"当前队列----%@",[NSThread currentThread]);
            //2018-03-07 14:48:05.361086+0800 多线程[1744:452769] 当前队列----<NSThread: 0x60000046f440>{number = 3, name = (null)}
        });
    });
    // 通过上面的输出结果我们可以总结一下串行队列同步默认是在当前的线程执行，一般是不会开启新的线程，但不能说完全绝对
    // 串行队列异步
    dispatch_async(serialQueue, ^{
        NSLog(@"222-----%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue, ^{
        NSLog(@"333-----%@",[NSThread currentThread]);
    });
    
    dispatch_async(serialQueue, ^{
        NSLog(@"444-----%@",[NSThread currentThread]);
    });
    /**打印结果
     2018-03-07 14:43:15.045386+0800 多线程[1703:444609] 111-----<NSThread: 0x608000079f80>{number = 1, name = main}
     2018-03-07 14:43:15.045671+0800 多线程[1703:444743] 222-----<NSThread: 0x600000274fc0>{number = 3, name = (null)}
     2018-03-07 14:43:15.045777+0800 多线程[1703:444743] 333-----<NSThread: 0x600000274fc0>{number = 3, name = (null)}
     2018-03-07 14:43:15.046071+0800 多线程[1703:444743] 444-----<NSThread: 0x600000274fc0>{number = 3, name = (null)}
     */
    // 通过以上输出结果我们可以得出结论，串行队列使用同步操作时按顺序执行，默认是在当前的线程中执行，一般不会开启新的线程，但不能说完全绝对
    //串行队列使用异步操作还是按顺序执行，但是他会开启一条新的线程（为什么是一条线程，这是因为这个是串行队列，一次只能执行一个任务）
}

// 串行队列开启异步任务之后嵌套同步任务会造成死锁，同理串行队列开启同步任务后嵌套同步任务造成死锁，原因就是串行队列不管是异步还是同步都是按顺序执行的
- (void)testSerialQueue{
    dispatch_queue_t q = dispatch_queue_create("cn.itcast.gcddemo", DISPATCH_QUEUE_SERIAL);
    dispatch_async(q, ^{
        NSLog(@"异步任务 %@", [NSThread currentThread]);
        // 下面开启同步造成死锁：因为串行队列中线程是有执行顺序的，需要等上面开启的异步任务执行完毕，才会执行下面开启的同步任务。而上面的异步任务还没执行完，要到下面的大括号才算执行完毕，而下面的同步任务已经在抢占资源了，就会发生死锁。（还有其他的解释不太好理解http://ju.outofmemory.cn/entry/325371）
        dispatch_sync(q, ^{
            NSLog(@"同步任务 %@", [NSThread currentThread]);
        });
    });
}

// 全局队列
- (void)globalQueue{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //同步
   
    dispatch_sync(globalQueue, ^{
        NSLog(@"111----%@",[NSThread currentThread]);
    });
    dispatch_sync(globalQueue, ^{
        NSLog(@"222----%@",[NSThread currentThread]);
    });
    dispatch_sync(globalQueue, ^{
        NSLog(@"333----%@",[NSThread currentThread]);
    });
    dispatch_async(globalQueue, ^{
        dispatch_sync(globalQueue, ^{
            NSLog(@"000----%@",[NSThread currentThread]);
            //000----<NSThread: 0x60400007aa00>{number = 3, name = (null)}
        });
    });
    /** 打印结果
     2018-03-07 14:53:15.601007+0800 多线程[1772:464510] 111----<NSThread: 0x6080000793c0>{number = 1, name = main}
     2018-03-07 14:53:15.601170+0800 多线程[1772:464510] 222----<NSThread: 0x6080000793c0>{number = 1, name = main}
     2018-03-07 14:53:15.601318+0800 多线程[1772:464510] 333----<NSThread: 0x6080000793c0>{number = 1, name = main}
     2018-03-07 14:55:44.239095+0800 多线程[1817:471997] 000----<NSThread: 0x60400007aa00>{number = 3, name = (null)}
     */
    // 这里可以看到前面三个都是主线程，第四个是子线程，原理在serialQueue已经讲到
    dispatch_async(globalQueue, ^{
        NSLog(@"444----%@",[NSThread currentThread]);
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"555----%@",[NSThread currentThread]);
    });
    dispatch_async(globalQueue, ^{
        NSLog(@"666----%@",[NSThread currentThread]);
    });
    /** 打印结果
     2018-03-07 15:02:22.167386+0800 多线程[1860:487970] 444----<NSThread: 0x604000267d00>{number = 4, name = (null)}
     2018-03-07 15:02:22.167417+0800 多线程[1860:487969] 666----<NSThread: 0x604000267d40>{number = 6, name = (null)}
     2018-03-07 15:02:22.167427+0800 多线程[1860:487971] 555----<NSThread: 0x600000275340>{number = 5, name = (null)}
     */
    
    // 从上面的打印结果我们可以得出结论，全局队列同步操作时时按顺序执行的，并且一般操作也是在当前的线程执行的（即一般不会开启新的线程），全局队列异步操作时会开启新的线程(有可能多条)，并且操作时无序的，没有规律的执行
}
// 并行队列
- (void)concurrentQueue{
    // 同全局队列
    dispatch_queue_t conCuurentQueue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
    // block异步任务包裹同步任务
    void (^task)(void) = ^{
         NSLog(@"111----%@", [NSThread currentThread]);
        // 同步任务的应用场景
        dispatch_sync(conCuurentQueue, ^{
             NSLog(@"用户登录 %@", [NSThread currentThread]);//当前的线程是子线程
        });
        dispatch_async(conCuurentQueue, ^{
             NSLog(@"扣费 %@", [NSThread currentThread]);
        });
        dispatch_async(conCuurentQueue, ^{
            NSLog(@"下载 %@", [NSThread currentThread]);
        });
    };
    dispatch_async(conCuurentQueue, task);
    /** 打印结果
     2018-03-07 15:24:21.921023+0800 多线程[1988:532705] 111----<NSThread: 0x604000078fc0>{number = 3, name = (null)}
     2018-03-07 15:24:21.921272+0800 多线程[1988:532705] 用户登录 <NSThread: 0x604000078fc0>{number = 3, name = (null)}
     2018-03-07 15:24:21.921408+0800 多线程[1988:532705] 扣费 <NSThread: 0x604000078fc0>{number = 3, name = (null)}
     2018-03-07 15:24:21.921447+0800 多线程[1988:532704] 下载 <NSThread: 0x604000079300>{number = 4, name = (null)}
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
