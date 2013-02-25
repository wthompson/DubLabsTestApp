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

//This method should be called in the background
-(void)refreshWithTags:(NSArray *)tags
{
    //Construct initial URL string
    NSMutableString *urlString = [NSMutableString stringWithFormat:FLICKR_FEED_URL, [self stringForFeedFormat]];
    
    //Append tags CGI parameter if provided
    NSString *tagsCGIParameter = [self stringForTags:tags];
    if([tagsCGIParameter length] > 0)
    {
        [urlString appendFormat:@"&tags=%@", tagsCGIParameter];
    }
    
    //Invoke the URL and retrieve the feed data
    NSURL *flickrURL = [NSURL URLWithString:urlString];
    NSError *error = nil;
    NSData *responseData = [[NSData alloc] initWithContentsOfURL:flickrURL options:NSDataReadingMapped error:&error];
    
    //If there was no error, process the response message
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

//These methods are to be implemented by subclasses of FlickrFeedReader
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
    //Instantiate parsing variables
    self.responseDict = [NSMutableDictionary dictionary];
    self.elementChainArray = [NSMutableArray array];
    self.elementTextString = [NSMutableString string];
    
    [self setCurrentDict:self.responseDict];
}

//
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //Track current element name
    [self setCurrentElementName:elementName];
    
    //Construct initial element dictionary and story available XML attributes
    NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
    if([attributeDict count] > 0)
    {
        [elementDict addEntriesFromDictionary:attributeDict];
    }
    
    //Check for an existing element key
    id existingValue = [self.currentDict objectForKey:self.currentElementName];
    if(existingValue != nil)
    {
        //If we have a duplicate element, construct Array to story all elements
        if([existingValue isKindOfClass:[NSMutableArray class]])
        {
            //Add to existing array
            [(NSMutableArray *)existingValue addObject:elementDict];
        }
        else
        {
            //Build new array and place exisitng objects inside
            NSMutableArray *tempArray = [NSMutableArray array];
            [tempArray addObject:existingValue];
            [tempArray addObject:elementDict];
            
            //Replace the element key with the array
            [self.currentDict setObject:tempArray forKey:self.currentElementName];
        }
    }
    else
    {
        //First occurence of the element, set as element key
        [self.currentDict setObject:elementDict forKey:self.currentElementName];
    }
    
    //Track elements through the XML structure
    [self.elementChainArray addObject:elementDict];
    [self setCurrentDict:[self.elementChainArray lastObject]];
}

//
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //Accumulate XML characters
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
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docDir stringByAppendingPathComponent:@"ResponseDict.plist"];
    
    //This is for debugging purposes or persistent storage
    [self.responseDict writeToFile:filePath atomically:YES];
}
@end

#pragma mark - NSString Flickr Category
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
