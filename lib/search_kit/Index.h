#import <Cocoa/Cocoa.h>
#import <CoreServices/CoreServices.h>

#import <Match.h>

#define kSearchMax 1000

@interface Index : NSObject {
  SKIndexRef _index;
}

-(SKIndexRef)index;
-(void)setIndex:(SKIndexRef)index;

-(NSMutableArray*)search:(NSString*)query;

@end
