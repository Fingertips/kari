#import <Cocoa/Cocoa.h>

@interface Match : NSObject {
  NSURL *_url;
  NSNumber *_score;
}

-(NSURL*)URL;
-(void)setURL:(NSURL*)url;

-(NSNumber*)score;
-(void)setScore:(NSNumber*)score;

-(Match*)initWithURL:(NSURL*)url score:(NSNumber*)score;

@end