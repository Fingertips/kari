#import "Index.h"

@implementation Index
-(void)search:(NSString *)query {
  NSLog(@"Search query: %s", query);
}
@end

void Init_Index() {}