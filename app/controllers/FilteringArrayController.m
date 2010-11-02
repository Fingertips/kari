#import "FilteringArrayController.h"
#import "ScoredRubyName.h"
#import <Foundation/NSKeyValueObserving.h>

@implementation FilteringArrayController

- (void)search:(id)sender
{
    [self setSearchString: sender];
    [self rearrangeObjects];
}

- (NSArray *)arrangeObjects:(NSArray *)objects
{
  if ((searchString == nil) || ([searchString isEqualToString:@""]))
  {
    return [super arrangeObjects:objects];
  }
  
  NSMutableArray *matchedObjects = [NSMutableArray arrayWithCapacity:[objects count]];
  NSEnumerator *oEnum = [objects objectEnumerator];
  ScoredRubyName *item;
  
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  while (item = [oEnum nextObject]) {
    [item setQuery:searchString];
    if ([item score] > 0) [matchedObjects addObject:item];
  }
  [pool release];
  
  return [super arrangeObjects:matchedObjects];
}

- (void)dealloc
{
  [self setSearchString:nil];
  [super dealloc];
}

- (NSString *)searchString
{
  return searchString;
}

- (void)setSearchString:(NSString *)newSearchString
{
  if (searchString != newSearchString)
  {
    [searchString autorelease];
    searchString = [newSearchString copy];
  }
}

@end