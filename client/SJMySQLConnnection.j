@import "SJAPIRequest.j"

var sharedMySQLConnection = '';

@implementation SJMySQLConnnection : CPObject
{

}

+ (id)sharedConnection
{
	if( sharedMySQLConnection )
		sharedMySQLConnection = [[SJMySQLConnnection alloc] init];
	
	return SJMySQLConnnection;
}

- (void)query:(CPString)aQuery callback:(id)aCallback
{
	
}

- (void)getColumnForQuery:(CPString)aQuery callback:(id)aCallback
{
	
}

- (void)getResultsForQuery:(CPString)aQuery callback:(id)aCallback
{
	
}

@end}