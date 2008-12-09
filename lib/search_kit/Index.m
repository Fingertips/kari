#import "Index.h"

@implementation Index
-(SKIndexRef)index { return _index; }
-(void)setIndex:(SKIndexRef)index { _index = index; }

-(NSMutableArray*)search:(NSString*)query {
  NSLog(@"Search query: %@", query);
  
  Boolean more = true;
  int totalCount = 0;
  CFIndex pos;
  
  NSMutableArray *matches = [[[NSMutableArray alloc] init] autorelease];
  
  SKSearchRef search = SKSearchCreate(_index, (CFStringRef) query, kSKSearchOptionDefault);
  [(id) search autorelease];
  
  while (more) {
    SKDocumentID  foundDocIDs  [kSearchMax];
    SKDocumentRef foundDocRefs [kSearchMax];
    float         foundScores  [kSearchMax];
    float         *scores = foundScores;
    // [Q] Why do I need to create a pointer for the foundScores array,
    // but not for the foundDocIDs array??
    
    CFIndex foundCount = 0;
    more = SKSearchFindMatches(search, kSearchMax, foundDocIDs, scores, 1, &foundCount);
    
    totalCount += foundCount;
    
    //SKIndexCopyDocumentRefsForDocumentIDs(_index, foundCount, (SKDocumentID *) foundDocIDs, (SKDocumentRef *) foundDocRefs);
    SKIndexCopyDocumentRefsForDocumentIDs(_index, foundCount, foundDocIDs, foundDocRefs);
    
    for (pos = 0; pos < foundCount; pos++) {
      SKDocumentRef doc = (SKDocumentRef) [(id) foundDocRefs [pos] autorelease];
      NSURL *url = [(id) SKDocumentCopyURL (doc) autorelease];
      
      //[searchSource addPath:[url path] Score:foundScores[pos]];
      [matches addObject: [NSDictionary dictionaryWithObjectsAndKeys: [url path], @"path", foundScores[pos], @"score"]];
    }
  }
  
  NSLog(@"Total match count: %d", totalCount);
  return matches;
}

@end

void Init_Index() {}