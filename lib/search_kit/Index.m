#import "Index.h"

@implementation Index
-(void)setIndex:(SKIndexRef)index {
  _index = index;
}

-(SKIndexRef)index {
  return _index;
}

-(void)search:(NSString *)query {
  // SKSearchRef search = SKSearchCreate([self index], query, NULL);
  // [(id)search autorelease];
  
  // return [[[NSClassFromString('Search') alloc] initWithIndex:[self index] query:query] autorelease];
}
@end

void Init_Index() {}