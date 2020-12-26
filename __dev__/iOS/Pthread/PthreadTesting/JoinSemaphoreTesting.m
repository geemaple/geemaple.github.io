//
//  JoinSemaphoreTesting.m
//  JoinSemaphoreTesting
//
//  Created by Dean Ji on 12/26/20.
//

#import <XCTest/XCTest.h>
#include <pthread/pthread.h>
#include <semaphore.h>

static sem_t *semaphore;

static void *childThread(void *args)
{
    printf("child start\n");
    sem_post(semaphore);
    printf("child end\n");
    
    return NULL;
}

static int testEntry()
{
    sem_unlink("semaphore");
    semaphore = sem_open("semaphore", O_CREAT | O_EXCL, S_IRWXU, 0);
    printf("parent start\n");
    pthread_t p;
    pthread_create(&p, NULL, childThread, NULL);
    sem_wait(semaphore);
    printf("parent end\n");
    
    return 0;
}


@interface JoinSemaphoreTesting : XCTestCase

@end

@implementation JoinSemaphoreTesting

- (void)testLockCondiation {
    testEntry();
}

@end
