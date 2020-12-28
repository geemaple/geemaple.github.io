# objc4-709 building

Tested with Xcode 8.3.3

All private header file could be download from [Apple Open Source](https://opensource.apple.com/release/macos-10124.html)

## Step 1: Add custom header search path:

Add ```$(SRCROOT)/include``` add Xcode Header Search Paths

## step 2: Add missing private headers:

```
cp ./xnu-3789.51.2/bsd/sys/reason.h include/sys/
cp ./xnu-3789.51.2/osfmk/machine/cpu_capabilities.h include/System/machine
cp ./xnu-3789.51.2/libsyscall/os/tsd.h include/os
cp ./dyld-433.5/include/mach-o/dyld_priv.h include/
mach-o/
cp ./dyld-433.5/include/objc-shared-cache.h include
cp ./libplatform-126.50.8/include/_simple.h include
cp ./libplatform-126.50.8/include/os/lock_private.h include/os/
cp ./libplatform-126.50.8/include/os/base_private.h include/os
cp ./libpthread-218.51.1/private/tsd_private.h include/pthread
cp ./libpthread-218.51.1/private/spinlock_private.h include/pthread
cp ./Libc-825.40.1/pthreads/pthread_machdep.h include/System
cp ./libpthread-218.51.1/private/workqueue_private.h include/pthread
cp ./libpthread-218.51.1/private/qos_private.h include/pthread
cp ./libpthread-218.51.1/sys/qos_private.h include/sys
cp ./libdispatch-703.50.37/src/BlocksRuntime/Block_private.h include
cp ./Libc-825.40.1/include/CrashReporterClient.h include
```

## step 3: Fix issues

1. redefinition > Xcode search ```//FIX redefinition```
2. casting, Xcode can auto fix these >  Xcode search ```//FIX AUTO```
3. add include before ```#include "objc-os.h"``` > Xcode search ```//FIX INCLUDE```
4. change Build Settings->Linking->Order File to ```$(SRCROOT)/libobjc.order```
5. add `#define LIBC_NO_LIBCRASHREPORTERCLIENT 1` to CrashReporterClient.h
6. add missing macro in ```dyld_priv.h``` > Xcode search ```//FIX MACRO```
7. remove ```-lCrashReporterClient``` from other linker flags

