#import <Cocoa/Cocoa.h>
#import <Match.h>

#define kSearchMax 1000

@interface Index : NSObject {
  SKIndexRef _index;
  NSNumber *_countDifference;
}

+(id)createWithPath:(NSString*)path;

-(id)init;
-(id)initWithPath:(NSString*)path;

-(SKIndexRef)index;
-(void)setIndex:(SKIndexRef)index;

-(void)willAddDocument;
-(void)didAddDocument;
-(void)addDocument:(NSString*)path withText:(NSString*)text;
-(void)addDocument:(NSString*)path mimeTypeHint:(NSString*)hint;
-(void)addDocument:(NSString*)path;
-(void)removeDocument:(NSString*)path;

-(NSNumber*)lopsidedCount;
-(NSNumber*)count;

-(NSMutableArray*)search:(NSString*)query;

-(void)flush;
-(void)compact;
-(void)close;
-(void)dealloc;

@end
