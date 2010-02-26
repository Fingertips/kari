#import "ScoredRubyName.h"

@interface ScoredRubyName (PrivateMethods)
-(NSAttributedString *)createAttributedString:(NSString *)aString;
-(void)update;
@end

@implementation ScoredRubyName

@synthesize nameWithMarkup, score;

-(id)initWithName:(NSString *)aName karidocFilename:(NSString *)aFilename query:(NSString *)aQuery
{
  if ([super init])
  {
    [self setName:aName];
    [self setKaridocFilename:aFilename];
    [self setQuery:aQuery];
    return self;
  }
  return nil;
}

-(void)setQuery:(NSString *)aQuery
{
  [query autorelease];
  query = [aQuery copy];
  [self update];
}

-(NSString *)query
{
  return query;
}

-(void)setName:(NSString *)aName
{
  [name autorelease];
  name = [aName copy];
}

-(NSString *)name
{
  return name;
}

-(void)setKaridocFilename:(NSString *)aFilename
{
  [karidocFilename autorelease];
  karidocFilename = [aFilename copy];
}

-(NSString *)karidocFilename
{
  return karidocFilename;
}

-(NSAttributedString *)createAttributedString:(NSString *)aString
{
  NSData *data = [aString dataUsingEncoding:NSUnicodeStringEncoding];
  return [[NSAttributedString alloc] initWithHTML:data documentAttributes:nil];
}

-(void)update
{
  NSFont *normalFont = [NSFont systemFontOfSize:[NSFont systemFontSize]];
  NSFont *boldFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
  
  NSMutableAttributedString *newNameWithMarkup = [[NSMutableAttributedString alloc] initWithString:name];
  [newNameWithMarkup addAttribute:NSFontAttributeName
                            value:normalFont
                            range:NSMakeRange(0, [name length])];
  
  if (query == nil) {
    score = 0;
  } else {
    NSString *match, *currentName, *currentQuery;
    
    Boolean eoq = FALSE;
    NSInteger newScore = 0,
              matchScore = 0,
              queryCursor = 0,
              nameCursor = 0;
    
    while (!eoq) {
      currentQuery = [query substringFromIndex:queryCursor];
      currentName = [name substringFromIndex:nameCursor];
      match = [currentName commonPrefixWithString:currentQuery
                                          options:NSCaseInsensitiveSearch];
      matchScore = [match length];
      if (matchScore == 0)
      {
        nameCursor += 1;
      } else {
        [newNameWithMarkup addAttribute:NSFontAttributeName
                                  value:boldFont
                                  range:NSMakeRange(nameCursor, matchScore)];
        
        nameCursor += matchScore;
        queryCursor += matchScore;
        newScore += matchScore;
      }
      
      // When we've reached the end of the name or query we're done
      if ((nameCursor > [name length]) || (queryCursor > [query length])) eoq = TRUE;
    }
    
    score = newScore;
  }
  
  [nameWithMarkup release];
  nameWithMarkup = newNameWithMarkup;
}

-(void)dealloc
{
  [name release];
  [karidocFilename release];
  [query release];
  [nameWithMarkup release];
}

@end

void Init_ScoredRubyName() {}