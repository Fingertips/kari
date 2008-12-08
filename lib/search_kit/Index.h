#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

@interface Index : NSObject {
  SKIndexRef _index;
}

-(void)search:(NSString *)query;

@end
