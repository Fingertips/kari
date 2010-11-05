#import "Index.h"

@implementation Index

+(id)createWithPath:(NSString*)path; {
  Index *index;
  SKIndexRef skIndex = SKIndexCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL, kSKIndexInverted, NULL);
  
  if (skIndex) {
    index = [[Index alloc] init];
    [index autorelease];
    [index setIndex:skIndex];
    return index;
  } else {
    return nil;
  }
}

-(id)init {
  [super init];
  _countDifference = nil;
  return self;
}

-(id)initWithPath:(NSString*)path
{
  [self init];
  _index = SKIndexOpenWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL, YES);
  if (_index) {
    return self;
  } else {
    return nil;
  }
}

-(SKIndexRef)index { return _index; }
-(void)setIndex:(SKIndexRef)index {
  if (_index) { SKIndexClose(_index); }
  _index = index;
}

-(void)willAddDocument {
}

-(void)didAddDocument {
  if (!_countDifference) {
    [self flush];
    _countDifference = [NSNumber numberWithLong:([[self lopsidedCount] longValue] - 1)];
  }
}

-(void)addDocument:(NSString*)path withText:(NSString*)text {
  SKDocumentRef document;
  
  [self willAddDocument];
  if (document = SKDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path])) {
    SKIndexAddDocumentWithText(_index, document, (CFStringRef)text, TRUE);
    CFRelease(document);
  }
  [self didAddDocument];
}

-(void)addDocument:(NSString*)path mimeTypeHint:(NSString*)hint {
  SKDocumentRef document;
  
  [self willAddDocument];
  if (document = SKDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path])) {
    SKIndexAddDocument(_index, document, (CFStringRef)hint, TRUE);
    CFRelease(document);
  }
  [self didAddDocument];
}

-(void)addDocument:(NSString*)path {
  [self addDocument:path mimeTypeHint:nil];
}

-(void)removeDocument:(NSString*)path {
  SKDocumentRef document;
  if (document = SKDocumentCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path])) {
    SKIndexRemoveDocument(_index, document);
    CFRelease(document);
  }
}

-(NSNumber*)lopsidedCount {
  if (_index) {
    CFIndex documentCount = SKIndexGetDocumentCount(_index);
    return [NSNumber numberWithLong:documentCount];
  } else {
    return [NSNumber numberWithInteger:0];
  }
}

-(NSNumber*)count {
  if (_index) {
    if (_countDifference) {
      return [NSNumber numberWithLong:([[self lopsidedCount] longValue] - [_countDifference longValue])];
    } else {
      return [NSNumber numberWithInteger:0];
    }
  } else {
    return nil;
  }
}

-(NSMutableArray*)search:(NSString*)query {
  Boolean more = true;
  CFIndex pos;
  
  NSMutableArray *matches = [[NSMutableArray alloc] init];
  
  SKSearchRef search = SKSearchCreate(_index, (CFStringRef)query, kSKSearchOptionDefault);
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
      [matches addObject: [[Match alloc] initWithURL:url score:[NSNumber numberWithFloat:foundScores[pos]]]];
    }
  }
  
  return [matches autorelease];
}

-(void)flush {
  if (_index) SKIndexFlush(_index);
}

-(void)compact {
  if (_index) SKIndexCompact(_index);
}

-(void)close {
  if (_index) SKIndexClose(_index);
  _index = nil;
}

-(void)dealloc {
  [self close];
  [super dealloc];
}

@end