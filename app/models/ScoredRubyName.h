#import <Cocoa/Cocoa.h>

@interface ScoredRubyName : NSObject
{
  NSString *name, *query;
  NSAttributedString *nameWithMarkup;
  NSInteger score;
}

@property (readwrite,nonatomic,assign) NSAttributedString *nameWithMarkup;
@property (readwrite,nonatomic,assign) NSInteger score;

-(id)initWithName:(NSString *)aName query:(NSString *)aQuery;
-(void)setQuery:(NSString *)query;
-(NSString *)query;
-(void)setName:(NSString *)name;
-(NSString *)name;
@end