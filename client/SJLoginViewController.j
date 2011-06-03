@import <Foundation/Foundation.j>
@import "Frameworks/EKSpinner/EKSpinner.j"
@import "SJDataManager.j"
@import "SJHTTPRequest.j"
@import "SJConstants.j"


@implementation SJLoginViewController : CPObject
{
  CPView contentView;
  CPView connectionView;
  CPView spinnerView;
  CPURLConnection httpConnection;
  CPArray responseData;
}


- (id)initWithView:(CPView)aView
{
  if (self = [super init]) {
    responseData = [[CPArray alloc] init];
    contentView = aView;
    [self setupView];
  }
  return self;
}

- (void)setHidden:(BOOL)isHidden
{
  [connectionView setHidden:isHidden];
}

- (CGRect)addTextField:(CPString)aTextFieldName 
					 withLabel:(CPString)aLabelName 
					atPosition:(CPInteger)idx
					withTag:(CPInteger)aTag
{
	var offset = 0;
	var posX = ([contentView frame].size.width - 300) / 2;
	var startAtY = 100;
	var posY;
	
	offset = (idx <= 0 ? 0 : idx - 1);
	posY = (idx * 30) + startAtY;

   // Label Name for connection
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,120,28)]; 
  [label setStringValue:aTextFieldName]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [label setFrameOrigin:CGPointMake(posX, posY)]; 
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
  [connectionView addSubview:label];

  // Name for connection
  var nameField = [[CPTextField alloc] initWithFrame:CGRectMake(0,0,150,28)]; 
  [nameField setStringValue:@""]; 
  [nameField setPlaceholderString:aLabelName];
  [nameField setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [nameField setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [nameField setFrameOrigin:CGPointMake(posX + 120, posY)]; 
  [nameField setEditable:YES];
  [nameField setEnabled:YES];
  [nameField setBezeled:YES];
  [nameField setTag:aTag];

  [connectionView addSubview:nameField];
  
  var posWidth = ([label frame].size.width + [nameField frame].size.width);
  
  return CGRectMake(posX, posY, posWidth, [nameField frame].size.height);
}

- (void)setupView
{ 
  connectionView = [[CPView alloc] initWithFrame:CGRectMake(0, 0, [contentView frame].size.width, [contentView frame].size.height)];
  [connectionView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  
	var formPos = [self addTextField:@"Name" withLabel:@"Name" atPosition:0 withTag:100];
	[self addTitle:@"Enter connection details below, or choose a favorite" fromRect:formPos];
  
	[self addTextField:@"Host" withLabel:@"Host" atPosition:1 withTag:101];
	[self addTextField:@"Username" withLabel:@"Username" atPosition:2 withTag:102];
	[self addTextField:@"Password" withLabel:@"Password" atPosition:3 withTag:103];
  [self addTextField:@"Database" withLabel:@"Database" atPosition:4 withTag:104];
  
  var rect = [self addTextField:@"Port" withLabel:@"3306" atPosition:5 withTag:105];
	
	var loginbtn = [[CPButton alloc] initWithFrame:CGRectMake(rect.origin.x + rect.size.width - 102, 
	  rect.origin.y + rect.size.height + 10, 
	  100, 24)];
	
	[loginbtn setBordered:YES];
	[loginbtn setTitle:@"Connect"];
	[loginbtn setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
	[loginbtn setTarget:self];
	[loginbtn setAction:@selector(connectionButtonPressed:)];
	
	[connectionView addSubview:loginbtn];
	[connectionView setBackgroundColor:[CPColor colorWithHexString:"eeeeee"]];
	
	// Assign The Next Key View
	[self assignNextKeyView];  
	  
	// add the spinner
  [self addSpinnerFromRect:rect];
  
  // finally add the connectionView to the ContentView
  [contentView addSubview:connectionView];
}


- (void)assignNextKeyView
{
  var name     = [connectionView viewWithTag:100];
  var host     = [connectionView viewWithTag:101];
  var username = [connectionView viewWithTag:102];
  var password = [connectionView viewWithTag:103];
  var database = [connectionView viewWithTag:104];
  var port     = [connectionView viewWithTag:105];
  
  /** 
  * TODO: Issue #5
  * I don't know what happen but tabbing on each of the field would set focus to the next field
  * somehow it doesn't work anymore and I don't know why.
  */
  [name setNextKeyView:host];
  [host setNextKeyView:username];
  [username setNextKeyView:password];
  [password setNextKeyView:database];
  [database setNextKeyView:port];
  [port setNextKeyView:name];
}


- (void)addSpinnerFromRect:(CGRect)rect
{
  spinnerView = [[CPView alloc] initWithFrame:CGRectMake(rect.origin.x + 2, 
    rect.origin.y + rect.size.height, 
    140, 18)];
  
  var spinner = [[EKSpinner alloc] initWithFrame:CGRectMake(0, 0, 18, 18) andStyle:@"medium_gray"];
  [spinner setIsSpinning:YES];
  [spinner setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin];
  [spinnerView addSubview:spinner];

  var label = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 120, 28)]; 
  [label setStringValue:@"Connecting..."]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [label setFrameOrigin:CGPointMake(26, -5)]; 
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setAlignment:CPLeftTextAlignment];
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
	[spinnerView addSubview:label];
	[spinnerView setBackgroundColor:[CPColor clearColor]];
	
	[connectionView addSubview:spinnerView];
	[spinnerView setHidden:YES];
}


- (void)connectionButtonPressed:(id)sender
{
  [spinnerView setHidden:NO];

  var name     = [[contentView viewWithTag:100] stringValue];
  var host     = [[contentView viewWithTag:101] stringValue];
  var username = [[contentView viewWithTag:102] stringValue];
  var password = [[contentView viewWithTag:103] stringValue];
  var database = [[contentView viewWithTag:104] stringValue];
  var port     = [[contentView viewWithTag:105] stringValue];
  
  if(port == "") port = "3306";

  var request = [SJHTTPRequest requestWithURL:SERVER_BASE + "/connect"];
  [request setObject:username forKey:@"username"];
  [request setObject:password forKey:@"password"];
  [request setObject:host forKey:@"host"];
  [request setObject:database forKey:@"database"];
  [request setObject:port forKey:@"port"];
  
  [[SJDataManager sharedInstance] setCredentials:[request params]];
  
  httpConnection = [CPURLConnection connectionWithRequest:[request toRequest] delegate:self];
}


- (void)databaseConnectionDidFail:(id)jsObject
{
  alert(jsObject['error']);
  [spinnerView setHidden:YES];

  [[CPNotificationCenter defaultCenter] postNotificationName:@"kLoginDidFail" object:nil];
}

- (void)databaseConnectionWasSuccess:(id)jsObject
{
  [[CPNotificationCenter defaultCenter] postNotificationName:@"kLoginSuccess" object:nil];
  [[CPNotificationCenter defaultCenter] postNotificationName:SHOW_DATABASES_NOTIFICATION object:nil];
  [[CPNotificationCenter defaultCenter] postNotificationName:SHOW_DATABASE_TABLES_NOTIFICATION object:nil];
}


- (void)connectionDidFinishLoading:(CPURLConnection)connection
{
  var json = JSON.parse([responseData componentsJoinedByString:@""]);
  response = nil;
  [responseData removeAllObjects];

  if(json['connected'] == true) {
    [self databaseConnectionWasSuccess:json];
  } else {
    [self databaseConnectionDidFail:json];
  }
}

- (void)connection:(CPURLConnection)connection didReceiveData:(CPString)data
{
  //This method is called when a connection receives a response. in a
  //multi-part request, this method will (eventually) be called multiple times,
  //once for each part in the response.
  
  [responseData addObject:data];
}

- (void)connection:(CPURLConnection)connection didFailWithError:(CPString)error
{
    //This method is called if the request fails for any reason.
    alert("Connection Failed: " + error);
}

- (void)clearConnection:(CPURLConnection)aConnection
{
    //we no longer need to hold on to a reference to this connection
    if (aConnection == httpConnection)
        httpConnection = nil;
}



- (void)addTitle:(CPString)aMessage fromRect:(CGRect)rect
{
  // Label Name for connection
  var label = [[CPTextField alloc] initWithFrame:CGRectMake(0, 0, 350, 28)]; 
  [label setStringValue:aMessage]; 
  [label setFont:[CPFont boldSystemFontOfSize:12.0]]; 
  [label setAutoresizingMask:CPViewMinXMargin | CPViewMaxXMargin | CPViewMinYMargin | CPViewMaxYMargin]; 
  [label setFrameOrigin:CGPointMake(rect.origin.x - 32, rect.origin.y - 42)]; 
  [label setEditable:NO]; 
  [label setBezeled: NO]; 
  [label setAlignment:CPCenterTextAlignment];
  [label setVerticalAlignment:CPCenterVerticalTextAlignment];
	[label setBackgroundColor:[CPColor clearColor]];
	
  [connectionView addSubview:label];
}

@end