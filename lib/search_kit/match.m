#import "Match.h"

@implementation Match

-(NSURL*)URL { return _url; }
-(void)setURL:(NSURL*)url { _url = [url copy]; }

-(NSNumber*)score { return _score; }
-(void)setScore:(NSNumber*)score { _score = [score copy]; }

-(Match*)initWithURL:(NSURL*)url score:(NSNumber*)score {
  if ([super init]) {
    [self setURL:url];
    [self setScore:score];
    return self;
  } else {
    return nil;
  }
}

@end

void Init_Match() {}