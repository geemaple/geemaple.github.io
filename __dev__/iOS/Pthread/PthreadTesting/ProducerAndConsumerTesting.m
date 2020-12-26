//
//  ProducerAndConsumerTesting.m
//  JoinPthreadTesting
//
//  Created by Dean Ji on 12/26/20.
//

#import <XCTest/XCTest.h>
#include <pthread/pthread.h>

#define kBufferSize 2
static pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t empty = PTHREAD_COND_INITIALIZER;
static pthread_cond_t full = PTHREAD_COND_INITIALIZER;

static int buffer[kBufferSize];
static int count = 0; // 大小为1
static int use = 0;
static int fill = 0;

static void put(int value)
{
    buffer[fill] = value;
    fill = (fill + 1) % kBufferSize;
    count++;
}

static int get()
{
    int tmp = buffer[use];
    use = (use + 1) % kBufferSize;
    count--;
    return tmp;
}


static void *producer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        pthread_mutex_lock(&lock);
        while (count == kBufferSize) {
            pthread_cond_wait(&empty, &lock);
        }
        
        put(i);
        printf("produce %d \n", i);
        pthread_cond_signal(&full);
        pthread_mutex_unlock(&lock);
    }
    
    return NULL;
}

static void *consumer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        pthread_mutex_lock(&lock);
        
        while (count == 0) {
            pthread_cond_wait(&full, &lock);
        }
        int tmp = get();
        printf("consume %d \n", tmp);
        pthread_cond_signal(&empty);
        pthread_mutex_unlock(&lock);
    }
    
    return NULL;
}

static int testEntry()
{    
    printf("parent start\n");
    pthread_t p1, p2, c1, c2;
    pthread_create(&p1, NULL, producer, (void *)10);
    pthread_create(&p2, NULL, producer, (void *)10);
    pthread_create(&c1, NULL, consumer, (void *)10);
    pthread_create(&c2, NULL, consumer, (void *)10);
    printf("parent end\n");
    
    return 0;
}

@interface ProducerAndConsumerTesting : XCTestCase

@end

@implementation ProducerAndConsumerTesting

- (void)testProducerAndConsumer {
    testEntry();
}
@end
