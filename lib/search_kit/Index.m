#import "Index.h"

@implementation Index
-(SKIndexRef)index { return _index; }
-(void)setIndex:(SKIndexRef)index { _index = index; }

-(NSMutableArray*)search:(NSString*)query {
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
    CFIndex       foundCount = 0;
    
    more = SKSearchFindMatches(search, kSearchMax, foundDocIDs, scores, 1, &foundCount);
    SKIndexCopyDocumentRefsForDocumentIDs(_index, foundCount, foundDocIDs, foundDocRefs);
    
    for (pos = 0; pos < foundCount; pos++) {
      SKDocumentRef doc = (SKDocumentRef) [(id) foundDocRefs[pos] autorelease];
      NSURL *url = [(id) SKDocumentCopyURL (doc) autorelease];
      
      [matches addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:
          url, @"url", [NSNumber numberWithFloat:foundScores[pos]], @"score", nil
        ]
      ];
    }
  }
  
  return matches;
}

@end

void Init_Index() {}