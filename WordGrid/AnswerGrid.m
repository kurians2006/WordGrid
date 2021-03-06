#import "Tile.h"
#import "AnswerGrid.h"
#import "AnswerData.h"

@implementation AnswerGrid 

int answerLength;
int currentIndex;

NSMutableArray *wordBoundries;

- (void) setup
{    
    self.gridWidth = 15;
    self.gridHeight = 4;
    self.margin = 2;  
    direction = 1;
    
    [self createGrid];
}

- (void) setDirection:(int)dir
{
    direction = dir;
    currentIndex = (direction == 1) ? 0 : answerLength - 1;
}

- (void) createLetters
{  
    answer = [AnswerData getCurrentQuote];
    answer = [answer stringByReplacingOccurrencesOfString:@"," withString:@""];
    answer = [answer stringByReplacingOccurrencesOfString:@"." withString:@""];
    answer = [answer stringByReplacingOccurrencesOfString:@"'" withString:@""];
    answerWords = [answer componentsSeparatedByString: @" "];
    wordBoundries = [[NSMutableArray alloc] init];
    answerLength = 0;
    
    int wordIndex = 0;       
    int charIndex = 0;  
    NSString *curWord = [answerWords objectAtIndex:wordIndex];
    NSString *curLetter;   
    BOOL complete = NO;
    
    for (Tile* t in self.tiles) 
    {        
        [t setIsSelectable:NO];
        [t setSelected:NO];
        [t setErrorMarkVisible:NO];
        [t setLetterShowing:NO];
        
        if(complete)
        {
            [t setHidden:YES];            
        }
        else
        {
            [t setHidden:NO];
            
            answerLength++;
            curLetter = [curWord substringWithRange:[curWord rangeOfComposedCharacterSequenceAtIndex:charIndex]]; 
            //[t setLetter:curLetter];
            [t setCorrectLetter:curLetter];
            [t setLetter:@""];
            
            charIndex++;
            
            if(charIndex >= [curWord length])
            {
                [wordBoundries addObject:[NSNumber numberWithInt:answerLength]];
                wordIndex++;
                charIndex = 0;
                if(wordIndex < [answerWords count])
                {
                    curWord = [answerWords objectAtIndex:wordIndex];                
                }
                else
                {
                    complete = YES;
                }                
            }                
        }             
    } 
    currentIndex = (direction == 1) ? 0 : answerLength - 1;   
}

- (void) ownTileSelected:(Tile *)tile;
{ 
    [tile setSelected:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onAnswerGridTileSelected" object:tile];
}

- (void) layoutGrid:(Boolean)useAnimation
{    
    Tile *tile = [self.tiles objectAtIndex:0];
    
    float spcH = tile.bounds.size.width + self.margin;
    float spcV = tile.bounds.size.height + self.margin;
    
    float l = 0;
    float t = 0;
    
    CGRect fr = CGRectMake(l, t, tile.bounds.size.width, tile.bounds.size.height);   
    
    int wordIndex = 0;       
    int charIndex = 0;  
    NSString *curWord = [answerWords objectAtIndex:wordIndex];
    BOOL complete = NO;
    
    for (tile in self.tiles) 
    {        
        if(!complete)
        {    
            tile.frame = fr;        
            fr.origin.x += spcH;
            charIndex++;    
            
            if(charIndex >= [curWord length])
            {
                wordIndex++;
                charIndex = 0;
                fr.origin.x += spcH / 2;
                
                if(wordIndex < [answerWords count])
                {
                    curWord = [answerWords objectAtIndex:wordIndex]; 
                    if(fr.origin.x + [curWord length] * spcH > self.gridWidth * spcH)
                    {
                        fr.origin.x = l;
                        fr.origin.y += spcV;
                    }
                }
                else
                {
                    complete = YES;
                }                
            }                
        }             
    }
    [self showFirstLetterHints];
}

- (void) showAllLetters
{
    for(Tile *t in self.tiles)
    {
        [t setLetterShowing:YES];
    }
}
- (void) showFirstLetterHints
{
    int counter = 0;
    for (int wordIndex = 0; wordIndex < answerWords.count; wordIndex++) 
    {
        NSString *word = [answerWords objectAtIndex:wordIndex];
        Tile *t = [self.tiles objectAtIndex:counter];
        [t setLetterShowing:YES];
        counter += word.length;
    }
}

- (void) showVowelHints
{
    int counter = 0;
    for (int wordIndex = 0; wordIndex < answerWords.count; wordIndex++) 
    {
        NSString *word = [answerWords objectAtIndex:wordIndex];
        for (int let = 0; let < word.length; let++) 
        {
            unichar letter = [word characterAtIndex:let];
            if(letter == 'A' || letter == 'E' || letter == 'I' || letter == 'O' || letter == 'U')
            {
                Tile *t = [self.tiles objectAtIndex:counter + let];
                [t setLetterShowing:YES];
                //break;
            }
        }
        counter += word.length;
    }
}

- (Tile *) getNextTile
{
    Tile * result = nil;
    if(currentIndex < answerLength && currentIndex >= 0)
    {
        result = [self.tiles objectAtIndex:currentIndex];
    }
    return result;
}

- (void) setNextTileUsingTile:(Tile *)srcTile
{    
    if(currentIndex < answerLength)
    {
        Tile *newTile = [self.tiles objectAtIndex:currentIndex];
        [newTile setLetter:[srcTile letter]];
        [newTile setOriginalIndex:srcTile.gridIndex];
        //[newTile setIsSelectable:YES];
        [newTile setSelected:YES];
        
        currentIndex += direction;
    }
}

- (int) getAnswerIndex
{
    return currentIndex;
}

- (int) getWordStartIndex:(int) index 
{
    int result = 0;
    int counter = 0;
    int wordLen = [[answerWords objectAtIndex:counter] length];
    
    if(index < 0)
    {
        index = 0;
    }
    else if(index > answerLength)
    {
        index = answerLength;
    }
    
    for (int i = wordLen; i <= index; i += wordLen) 
    {
        result += wordLen;
        counter++;
        if(counter < answerWords.count)
        {
            wordLen = [[answerWords objectAtIndex:counter] length];
        }
        else
        {
            break;
        }
    }
     
    //NSLog(@"index: %i start: %i", index, result);
    return result;
}

- (int) getCurrentWordStart 
{
    int result = [self getWordStartIndex:currentIndex];
    return result;
}

- (NSString *) getCurrentLetter
{
    NSString *result = nil;
    if(currentIndex > 0)
    {
        Tile *t = [self.tiles objectAtIndex:currentIndex];
        result = t.letter;
    }
    return result;
}
- (NSString *) getCurrentCorrectLetter
{
    NSString *result = nil;
    if(currentIndex >= 0)
    {
        Tile *t = [self.tiles objectAtIndex:currentIndex];
        result = t.correctLetter;
    }
    return result;
}

- (Tile *) removeCurrentTile
{
    Tile *result = nil;
    if(currentIndex > 0)
    {
        result = [self.tiles objectAtIndex:currentIndex - 1];
        //[result setLetter:@""];
        [result setIsSelectable:NO];
        [result setSelected:NO];
        [result setErrorMarkVisible:NO];
        
        currentIndex += -direction;
        [[self.tiles objectAtIndex:currentIndex] setIsSelectable:YES];
    }
    return result;
}

- (BOOL) atWordBoundry
{
    BOOL result = false;
    
    for (NSNumber *n in wordBoundries) 
    {
        
        if ([n integerValue] == currentIndex) 
        {
            result = YES;
            break;
        }
    }
    return result;
}

- (NSRange) getWordRange
{    
    int counter = 0;
    int wordLen = 0;
    int start = 0;
        
    for (; start < currentIndex; start += wordLen) 
    {
        if(counter < answerWords.count)
        {
            wordLen = [[answerWords objectAtIndex:counter] length];            
            counter++;
        }
        else
        {
            break;
        }
    }
    
    return NSMakeRange(start - wordLen, wordLen);
}

- (Boolean) testCurrentWordCorrect
{
    Boolean result = NO;
    if([self atWordBoundry])
    {
        result = YES;
        NSRange range = [self getWordRange];
        for (int i = range.location; i < range.location + range.length; i++) 
        {
            Tile *t = [self.tiles objectAtIndex:i];
            if(![t isCorrectLetter])
            {
                result = NO;
            }
        }
        
        if(!result)
        {            
            for (int i = range.location; i < range.location + range.length; i++) 
            {
                Tile *t = [self.tiles objectAtIndex:i];
                [t setErrorMarkVisible:YES];           
            }
        }
    }
    return result;
}

- (Boolean) didWin
{
    Boolean result = YES;
    for (int i = 0; i < answerLength; i++)
    {
        if(![[self.tiles objectAtIndex:i] isCorrectLetter])
        {
            result = NO;
            break;
        }
    }
    return result;
}


@end



