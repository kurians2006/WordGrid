#import <UIKit/UIKit.h>
#import "Tile.h"

@protocol GridProtocol

- (void)    setup;
- (void)    createGrid;
- (void)    createRound;
- (void)    resetGrid;
- (void)    layoutGrid:(Boolean) useAnimation;
- (int)     getTileIndexFromMousePoint:(CGPoint) point;
- (Tile *)  getTileFromPoint:(CGPoint) p;
- (void)    hoverTileAtPoint:(CGPoint) point;
- (void)    removeWordAndDrop:(NSArray *) indexes;
- (void)    removeTile:(int) index;
- (void)    setAllIsSelectable:(Boolean) sel;


@end
