//
//  JoinPthreadTesting.m
//  JoinPthreadTesting
//
//  Created by Dean Ji on 12/26/20.
//

#import <XCTest/XCTest.h>
#include <pthread/pthread.h>

static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t condition = PTHREAD_COND_INITIALIZER;
static int done = 0;

static void custom_thread_exist()
{
    pthread_mutex_lock(&lock);
    done = 1;
    pthread_cond_signal(&condition);
    pthread_mutex_unlock(&lock);
}

static void *childThread(void *args)
{
    printf("child start\n");
    custom_thread_exist();
    printf("child end\n");
    
    return NULL;
}

static void custom_thread_join()
{
    pthread_mutex_lock(&lock);
    while (done == 0) {
        pthread_cond_wait(&condition, &lock);
    }
    pthread_mutex_unlock(&lock);
}

static int testEntry()
{
    printf("parent start\n");
    pthread_t p;
    pthread_create(&p, NULL, childThread, NULL);
    custom_thread_join();
    printf("parent end\n");
    
    return 0;
}


@interface JoinPthreadTesting : XCTestCase


@end

@implementation JoinPthreadTesting

- (void)testLockCondiation {
    testEntry();
}

@end
