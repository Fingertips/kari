#import <Cocoa/Cocoa.h>
#import <math.h>

@interface ScoredRubyName : NSObject
{
  NSString *name, *query, *karidocFilename;
  NSAttributedString *nameWithMarkup;
  NSInteger score;
}

@property (readwrite,nonatomic,assign) NSAttributedString *nameWithMarkup;
@property (readwrite,nonatomic,assign) NSInteger score;

-(id)initWithName:(NSString *)aName karidocFilename:(NSString *)aFilename query:(NSString *)aQuery;
-(void)setQuery:(NSString *)query;
-(NSString *)query;
-(void)setName:(NSString *)name;
-(NSString *)name;
-(void)setKaridocFilename:(NSString *)aFilename;
-(NSString *)karidocFilename;

@end