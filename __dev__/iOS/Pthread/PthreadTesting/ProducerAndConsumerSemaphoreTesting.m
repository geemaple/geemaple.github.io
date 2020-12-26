//
//  ProducerAndConsumerSemaphoreTesting.m
//  PthreadTesting
//
//  Created by Dean Ji on 12/26/20.
//

#import <XCTest/XCTest.h>
#include <pthread/pthread.h>
#include <semaphore.h>

#define kBufferSize 2
static sem_t *empty;
static sem_t *full;
static sem_t *mutex;

static int buffer[kBufferSize];
static int use = 0;
static int fill = 0;

static void put(int value)
{
    buffer[fill] = value;
    fill = (fill + 1) % kBufferSize;
}

static int get()
{
    int tmp = buffer[use];
    use = (use + 1) % kBufferSize;
    return tmp;
}


static void *producer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        sem_wait(empty);
        sem_wait(mutex);
        put(i);
        printf("produce %d \n", i);
        sem_post(mutex);
        sem_post(full);
    }
    
    return NULL;
}

static void *consumer(void *arg)
{
    int loops = (int)arg;
    for (int i = 0; i < loops; ++i) {
        sem_wait(full);
        sem_wait(mutex);
        int tmp = get();
        printf("consume %d \n", tmp);
        sem_post(mutex);
        sem_post(empty);
    }
    
    return NULL;
}

static int testEntry()
{
    sem_unlink("full");
    sem_unlink("empty");
    sem_unlink("mutex");

    full = sem_open("full", O_CREAT | O_EXCL, S_IRWXU, 0);
    empty = sem_open("empty", O_CREAT | O_EXCL, S_IRWXU, kBufferSize);
    mutex = sem_open("mutex", O_CREAT | O_EXCL, S_IRWXU, 1);
    
    printf("parent start\n");
    pthread_t p1, p2, c1, c2;
    pthread_create(&p1, NULL, producer, (void *)10);
    pthread_create(&p2, NULL, producer, (void *)10);
    pthread_create(&c1, NULL, consumer, (void *)10);
    pthread_create(&c2, NULL, consumer, (void *)10);
    printf("parent end\n");
    
    return 0;
}

@interface ProducerAndConsumerSemaphoreTesting : XCTestCase

@end

@implementation ProducerAndConsumerSemaphoreTesting

- (void)testProducerAndConsumer {
    testEntry();
}
@end
