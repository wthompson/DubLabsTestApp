//
//  FlickrFeedReader.m
//  DubLabsTestApp_v1
//
//  Created by Wendell Thompson on 2/24/13.
//  Copyright (c) 2013 Wendell Thompson. All rights reserved.
//

#import "FlickrFeedReader.h"

NSString * const FLICKR_FEED_URL = @"http://api.flickr.com/services/feeds/photos_public.gne?format=%@";

@interface FlickrFeedReader()
@property (nonatomic, strong) NSMutableDictionary *responseDict;
@property (nonatomic, strong) NSMutableArray *elementChainArray;
@property (nonatomic, strong) NSMutableString *elementTextString;
@property (nonatomic, strong) NSString *currentElementName;
@property (nonatomic, weak) NSMutableDictionary *currentDict;
@end

@implementation FlickrFeedReader

@synthesize responseDict = _responseDict;
@synthesize elementChainArray = _elementChainArray;
@synthesize elementTextString = _elementTextString;
@synthesize currentElementName = _currentElementName;
@synthesize currentDict = _currentDict;

//
-(FlickrFeedFormatType)formatType
{
    return FlickrFeedFormatTypeNone;
}

//
-(NSDictionary *)feedDataDict
{
    return self.responseDict;
}

//
-(void)refreshWithTags:(NSArray *)tags
{
    NSMutableString *urlString = [NSMutableString stringWithFormat:FLICKR_FEED_URL, [self stringForFeedFormat]];
    NSString *tagsCGIParameter = [self stringForTags:tags];
    if([tagsCGIParameter length] > 0)
    {
        [urlString appendFormat:@"&tags=%@", tagsCGIParameter];
    }
    
    
    
    NSURL *flickrURL = [NSURL URLWithString:urlString];
    NSError *error = nil;
    NSData *responseData = [[NSData alloc] initWithContentsOfURL:flickrURL options:NSDataReadingMapped error:&error];
    
    if(error == nil)
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:responseData];
        [parser setDelegate:self];
        [parser parse];
    }
    else
    {
        NSLog(@"ERROR:%@", [error localizedDescription]);
    }
}

//
-(NSUInteger)itemCount
{
    NSAssert(NO, @"\"itemCount\" needs to be implemented by a derived class.");
    return 0;
}

//
-(NSString *)stringForFeedFormat
{
    NSAssert(NO, @"\"stringForFeedFormat\" needs to be implemented by a derived class.");
    return nil;
}

//
-(NSString *)stringForTags:(NSArray *)tags
{
    NSAssert(NO, @"\"stringForTags\" needs to be implemented by a derived class.");
    return nil;
}

//
-(NSString *)authorForFeedItemAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"\"authorForFeedItemAtIndex\" needs to be implemented by a derived class.");
    return nil;
}

//
-(NSString *)descriptionForFeedItemAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"\"descriptionForFeedItemAtIndex\" needs to be implemented by a derived class.");
    return nil;
}

//
-(NSString *)thumbnailImageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"\"thumbnailImageURLStringForFeedItemAtIndex\" needs to be implemented by a derived class.");
    return nil;
}

//
-(NSString *)imageURLStringForFeedItemAtIndex:(NSUInteger)index
{
    NSAssert(NO, @"\"imageURLStringForFeedItemAtIndex\" needs to be implemented by a derived class.");
    return nil;
}

#pragma mark - NSXMLParserDelegate
//
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.responseDict = [NSMutableDictionary dictionary];
    self.elementChainArray = [NSMutableArray array];
    self.elementTextString = [NSMutableString string];
    
    [self setCurrentDict:self.responseDict];
}

//
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [self setCurrentElementName:elementName];
    
    NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
    if([attributeDict count] > 0)
    {
        [elementDict addEntriesFromDictionary:attributeDict];
    }
    
    id existingValue = [self.currentDict objectForKey:self.currentElementName];
    if(existingValue != nil)
    {
        if([existingValue isKindOfClass:[NSMutableArray class]])
        {
            [(NSMutableArray *)existingValue addObject:elementDict];
        }
        else
        {
            NSMutableArray *tempArray = [NSMutableArray array];
            [tempArray addObject:existingValue];
            [tempArray addObject:elementDict];
            
            [self.currentDict setObject:tempArray forKey:self.currentElementName];
        }
    }
    else
    {
        [self.currentDict setObject:elementDict forKey:self.currentElementName];
    }
    
    [self.elementChainArray addObject:elementDict];
    [self setCurrentDict:[self.elementChainArray lastObject]];
}

//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [self.elementTextString appendString:string];
}

//
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //Flag if the current element is empty
    BOOL isElementEmpty = ([self.currentDict count] == 0);
    
    //Pop back to parent element
    [self.elementChainArray removeLastObject];
    [self setCurrentDict:[self.elementChainArray lastObject]];
    
    //If child was empty, remove from parent
    if(isElementEmpty)
    {
        [self.currentDict removeObjectForKey:self.currentElementName];
    }
    
    //Check to see if we have accumulated text
    if([self.elementTextString length] > 0)
    {
        //Strip out invlaid characters
        NSString *elementStringValue = [self.elementTextString stringByReplacingOccurrencesOfString:@"\n" withString:[NSString flickr_emptyString]];
        elementStringValue = [elementStringValue stringByReplacingOccurrencesOfString:@"\t" withString:[NSString flickr_emptyString]];
        elementStringValue = [elementStringValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[NSString flickr_space]]];
        
        //If we have a valid value set it
        if([elementStringValue length] > 0)
        {
            [self.currentDict setObject:elementStringValue forKey:self.currentElementName];
        }
    }
    
    //Clear out string buffer
    [self.elementTextString setString:[NSString flickr_emptyString]];
}

// sent when the parser begins parsing of the document.
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"FINISHED:%@", [self.responseDict description]);
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"ResponseDict.plist"];
    [self.responseDict writeToFile:filePath atomically:YES];
}
@end

@implementation NSString(Flickr)
//
+(NSString *)flickr_emptyString
{
    return @"";
}

//
+(NSString *)flickr_space
{
    return @" ";
}
@end
