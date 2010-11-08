#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface FilteringArrayController : NSArrayController
{
  NSString *searchString;
}

@property (retain) NSString* searchString;

- (void)search:(id)sender;

@end