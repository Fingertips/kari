#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>
#import <CoreFoundation/CoreFoundation.h>

typedef void (^FSEventCallback)(NSArray* events);

@interface FSEventStream : NSObject
{
  FSEventStreamRef stream;
}

@property (retain) FSEventCallback callback;
@property (retain) id delegate;
@property (retain) NSArray* paths;

- (id) initWithPaths:(NSArray*)pathsToWatch delegate:(id)receiver;
- (id) initWithPaths:(NSArray*)pathsToWatch onChanges:(FSEventCallback)block;

- (Boolean) createStream;
- (Boolean) start;
- (void) stop;

- (void) handleEvents:(NSArray*)events;

@end