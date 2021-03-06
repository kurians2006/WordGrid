//
//  TileView.m
//  WordGrid
//
//  Created by admin on 12-12-01.
//
//

#import "TileView.h"
#import "Tile.h"
#import "GameRating.h"

@interface TileView()
{
    UIImage *image;
    CGRect scaleNormalRect;
    CGRect scaleMidRect;
    CGRect scaleUpRect;
    Boolean errorMarkVisible;
}

@end

@implementation TileView

@synthesize tile = _tile;
@synthesize animatingFrom = _animatingFrom;
@synthesize isHovering = _isHovering;

@synthesize currentIndex = _currentIndex;
@synthesize isSelectable = _isSelectable;
@synthesize isSelected = _isSelected;
@synthesize isHidden = _isHidden;

static NSArray *imageStates;
static UIImage *errorImage;
static UIImage *checkImage;
static float hoverScale = 1.5;
static SystemSoundID tickSoundID;

- (id) initWithFrame:(CGRect)frame andTile:(Tile *) t
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _tile = t;
        [self setup];
    }
    return self;
}

-(Tile *)tile
{
    return _tile;
}

-(void)setTile:(Tile *)t
{
    _tile = t;
    if(t == (id)[NSNull null])
    {        
        self.isHidden = YES;
        self.isSelectable = NO;
        self.isSelected = NO;
    }
}

-(void) setIsHovering:(Boolean)hovering
{
    if(_isHovering != hovering)
    {
        _isHovering = hovering;
        
        if(_isHovering)
        {        
            [self.superview bringSubviewToFront:self];
            if(self.tile.isSelectable)
            {
                self.bounds = scaleUpRect;
            }
            else
            {
                self.bounds = scaleMidRect;
            }
        }
        else
        {
            self.bounds = scaleNormalRect;        
        }
        
        [self setNeedsDisplay];
    }
}

- (void) setup
{
    image = [imageStates objectAtIndex:0];
    self.animatingFrom = CGRectNull;
    _isHovering = NO;
    _currentIndex = CGPointMake(-1, -1);
    _isSelected = NO;
    _isSelectable = NO;
    _isHidden = YES;
    
    CGRect f = [self frame];
    float xBorder = ((f.size.width * hoverScale) - f.size.width) / 2.0;
    float yBorder = ((f.size.height * hoverScale) - f.size.height) / 2.0;
    scaleNormalRect = f;    
    scaleMidRect = CGRectInset(f, -xBorder / 3.0f, -yBorder / 3.0f);
    scaleUpRect = CGRectInset(f, -xBorder, -yBorder);
}

+ (void) load
{
    errorImage = [UIImage imageNamed:@"errorTile.png"];
    checkImage = [UIImage imageNamed:@"checkTile.png"];
    
    imageStates = [[NSArray alloc] initWithObjects:
                   [UIImage imageNamed:@"let_norm.png"],
                   [UIImage imageNamed:@"let_sel0.png"],
                   [UIImage imageNamed:@"let_sel1.png"],
                   [UIImage imageNamed:@"let_sel2.png"], nil];
    
    NSURL *tickURLRef = [[NSBundle mainBundle] URLForResource:@"smallTick" withExtension:@"caf"];
    AudioServicesCreateSystemSoundID ( (__bridge CFURLRef) tickURLRef, &tickSoundID);
}

- (void)drawRect:(CGRect)rect
{
    if(_tile == (id)[NSNull null] || _tile.isHidden)
    {
        self.hidden = YES;
    }
    else
    {
        //self.clipsToBounds = NO;
        
        self.hidden = NO;
        CGRect r = self.bounds;
        
        //[image drawAtPoint:(CGPointMake(0.0f, 0.0f))];
        [image drawInRect:r];
        
        if(errorMarkVisible)
        {
            [errorImage drawInRect:r];
        }
        
        float sc = r.size.width / 48.0;
        UIFont *f = [UIFont fontWithName:@"VTC Letterer Pro" size:(48.0 * sc)];        
        CGRect letR = CGRectOffset(r, 0.0, 2.0);

        if(_tile.isSelected)
        {
            [[UIColor lightGrayColor] set];
        }
        else
        {
            [[UIColor whiteColor] set];
        }
        
        [_tile.letter drawInRect:letR withFont:f lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
        
        CGContextRef context;
        if(_tile.isSelectable && (_tile.rating == nil || _tile.rating.roundRating < inProgress))
        {
            context = UIGraphicsGetCurrentContext();
            CGContextSetLineWidth(context, 4);
            CGContextSetRGBStrokeColor(context, 0.2, 0.5, 1.0, 1);
            CGContextStrokeRect(context, r);
        }
        
        if(_tile.rating)
        {
            switch (_tile.rating.roundRating)
            {
                case notStarted:
                    break;
                    
                case inProgress:
                    context = UIGraphicsGetCurrentContext();
                    CGContextSetLineWidth(context, 8);
                    CGContextSetRGBStrokeColor(context, 1.0, 0.3, 0.3, 0.3);
                    CGContextStrokeRect(context, CGRectInset(r, 4, 4));
                    break;
                    
                case complete0:
                case complete1:
                case complete2:
                    context = UIGraphicsGetCurrentContext();
                    CGContextSetLineWidth(context, 8);
                    CGContextSetRGBStrokeColor(context, 0.2, 1.0, 0.5, 0.3);
                    CGContextStrokeRect(context, CGRectInset(r, 4, 4));
                    
                    [checkImage drawInRect:r];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"canSel:%@t%@ sel:%@t%@, let:%@, pt:%d,%d ptt:%d,%d",
            self.isSelectable ? @"Y" : @"N",            
            self.tile.isSelectable ? @"Y" : @"N",
            self.isSelected ? @"Y" : @"N",
            self.tile.isSelected ? @"Y" : @"N",
            self.tile.letter,
            (int)self.currentIndex.x,
            (int)self.currentIndex.y,
            (int)self.tile.currentIndex.x,
            (int)self.tile.currentIndex.y];
}


//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//    // move hover to grid
//    self.isHovering = YES;
//}
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//    self.isHovering = NO;
//    //NSLog(@"%i", gridIndex);
//    if(self.tile.isSelectable)
//    {
//        AudioServicesPlaySystemSound(tickSoundID);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"onTileSelected" object:self];
//    }
//    [self setNeedsDisplay];
//}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//}

@end
