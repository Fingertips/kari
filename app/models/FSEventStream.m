#import <FSEventStream.h>

static void bounceCallback(ConstFSEventStreamRef streamRef,
  void *clientCallBackInfo,
  size_t numEvents,
  void *eventPaths,
  const FSEventStreamEventFlags eventFlags[],
  const FSEventStreamEventId eventIds[])
{
  FSEventStream *fsEventStream = (FSEventStream*)clientCallBackInfo;
  NSDate *time = [NSDate date];
  char **paths = eventPaths;
  NSMutableArray *events;
  size_t index;
  
  NSLog(@"Here!");
  
  events = [NSMutableArray arrayWithCapacity:numEvents];
  for (index=0; index < numEvents; index++) {
    [events addObject:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithUnsignedLongLong:eventIds[index]], @"id",
        [NSString stringWithUTF8String:paths[index]], @"path",
        [NSString stringWithFormat:@"%04x",eventFlags[index]] , @"flag",
        time , @"time",
        NULL
    ]];
  }
  [fsEventStream handleEvents:[NSArray arrayWithArray:events]];
}

@implementation FSEventStream

@synthesize callback;
@synthesize delegate;
@synthesize paths;


- (id) initWithPaths:(NSArray*)pathsToWatch delegate:(id)receiver {
  self = [self init];
  paths = pathsToWatch;
  delegate = receiver;
  if ([self createStream]) return self;
}

- (id) initWithPaths:(NSArray*)pathsToWatch onChanges:(FSEventCallback)block {
  self = [self init];
  paths = pathsToWatch;
  callback = block;
  [self createStream];
  if ([self createStream]) return self;
}

- (Boolean) start {
  return FSEventStreamStart(stream);
}

- (void) stop {
  FSEventStreamStop(stream);
}

- (Boolean) createStream {
  FSEventStreamContext *context = malloc(sizeof(FSEventStreamContext));
  context->version = 0;
  context->info = (void*)self; 
  context->retain = NULL;
  context->release = NULL;
  context->copyDescription = NULL;
  
  stream = FSEventStreamCreate(kCFAllocatorDefault, (FSEventStreamCallback)&bounceCallback, context, (CFArrayRef)paths, kFSEventStreamEventIdSinceNow, 0.0, 0);
  FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
  
  return(stream ? true : false);
}

- (void) handleEvents:(NSArray*)events {
  if (delegate) {
    NSLog(@"Asking the delegate to handle the events");
    [delegate handleEvents:events];
  } else if (callback) {
    NSLog(@"Asking the callback to handle the events");
    callback(events);
  } else {
    NSLog(@"FSEventStream received a filesystem event, but it has no delegate or callback to respond.");
  }
}

- (void) dealloc {
  FSEventStreamRelease(stream);
  [super dealloc];
}

@end