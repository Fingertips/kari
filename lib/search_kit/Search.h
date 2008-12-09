#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

@interface Search : NSObject {
  SKIndexRef* index;
  NSString* query;
}

@property (readwrite) SKIndexRef* index;
@property (readwrite,copy) NSString* query;

@end
