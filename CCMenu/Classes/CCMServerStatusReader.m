
#import "CCMServerStatusReader.h"


@implementation CCMServerStatusReader

- (id)initWithServerResponse:(NSData *)data
{
	[super init];
	responseData = [data copy];
	return self;
}

- (void)dealloc
{
	[responseData release];
	[super dealloc];
}

- (NSDate *)convertDateString:(NSString *)dateString
{
    // see http://stackoverflow.com/questions/2201216/is-there-a-simple-way-of-converting-an-iso8601-timestamp-to-a-formatted-nsdate
    return [NSDate dateWithNaturalLanguageString:dateString];
}

- (NSString *)fixUrlStringIfNecessary:(NSString *)urlString
{
	// The following is a workaround for a CruiseControl.rb bug
	NSRange ppRange = [urlString rangeOfString:@"projectsprojects"];
	if(ppRange.length > 0)
	{
		NSMutableString *copy = [NSMutableString stringWithString:urlString];
		[copy replaceCharactersInRange:ppRange withString:@"projects"];
		urlString = copy;
	}
	return urlString;
}

- (NSArray *)readProjectInfos:(NSError **)errorPtr
{
    NSXMLDocument *doc = [[[NSXMLDocument alloc] initWithData:responseData options:NSXMLNodeOptionsNone error:errorPtr] autorelease];
    if(doc == nil)
        return nil;
    
    NSMutableArray *projectInfos = [NSMutableArray array];
    for(NSXMLElement *element in [doc nodesForXPath:@"//Project" error:nil])
	{
		NSDictionary *info = [NSMutableDictionary dictionary];
        for(NSXMLNode *attribute in [element attributes])
		{
			id value = [attribute stringValue];
			if([[attribute name] isEqualToString:@"lastBuildTime"])
				value = [self convertDateString:value];
			if([[attribute name] isEqualToString:@"webUrl"])
				value = [self fixUrlStringIfNecessary:value];
			[info setValue:value forKey:[attribute name]];
		}
		[projectInfos addObject:info];
	}
    return projectInfos;        
}

@end
