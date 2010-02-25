#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface FilteringArrayController : NSArrayController
{
  NSString *searchString;
}

- (void)search:(id)sender;
- (NSString *)searchString;
- (void)setSearchString:(NSString *)newSearchString;

@end