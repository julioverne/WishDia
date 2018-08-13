#import <dlfcn.h>
#import <objc/runtime.h>
#import <notify.h>
#import <substrate.h>

#define NSLog(...)
#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.julioverne.wishdia.plist"

@interface HomeController : UIViewController
@end

@interface CYPackageController : UIViewController
- (void)updateWishButton;
@end

@interface Package : NSObject
- (id)id;
@end

@interface PackageCell : UITableViewCell
- (void)setPackage:(Package*)arg1 asSummary:(BOOL)arg2;
@end

@interface CydiaObject : NSObject
- (id)getPackageById:(id)arg1;
@end

@interface WishDiaController : UITableViewController
@property (nonatomic, strong) NSArray* package_list;
@property (nonatomic, strong) CydiaObject* cydiaObject;
+ (id)shared;
- (BOOL)wishIdExist:(NSString*)arg1;
- (void)addWishById:(NSString*)arg1;
- (void)removeWishById:(NSString*)arg1;
- (void)toggleById:(NSString*)arg1;
@end

@interface UIApplication ()
- (void)presentModalViewController:(id)arg1 force:(BOOL)arg2;
- (BOOL)openCydiaURL:(id)arg1 forExternal:(BOOL)arg2;
@end

%hook HomeController
- (void)viewWillAppear:(BOOL)arg1
{
	%orig;
	@try {
		BOOL hasButton = NO;
		for (UIBarButtonItem* now in self.navigationItem.leftBarButtonItems) {
			if (now.tag == 4698) {
				hasButton = YES;
				break;
			}
		}
		if (!hasButton) {
			static __strong UIBarButtonItem* btCyDown = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(launchWishDia)];
			btCyDown.tag = 4698;
			__autoreleasing NSMutableArray* BT = [self.navigationItem.leftBarButtonItems?:@[] mutableCopy];
			[BT addObject:btCyDown];
			self.navigationItem.leftBarButtonItems = [BT copy];
		}
	} @catch (NSException * e) {
	}
}
%new
- (void)launchWishDia
{
	@try {
		[[UIApplication sharedApplication] presentModalViewController:[%c(WishDiaController) shared] force:YES];
	} @catch (NSException * e) {
	}
}
%end

%hook CYPackageController
- (void)viewWillAppear:(BOOL)arg1
{
	%orig;
	[self updateWishButton];
}
- (void)applyRightButton
{
	%orig;
	[self updateWishButton];
}
%new
- (void)toggleWishDia
{
	Package* myPackage = MSHookIvar<Package *>(self, "package_");
	[[%c(WishDiaController) shared] toggleById:[myPackage id]];
	[self updateWishButton];
}
%new
- (void)updateWishButton
{
	@try {
		NSMutableArray* BT = [NSMutableArray array];
		for(UIBarButtonItem* nowBT in self.navigationItem.rightBarButtonItems) {
			if (nowBT.tag == 4652) {
				continue;
			}
			[BT addObject:nowBT];
		}
		UIBarButtonItem* btRomeve = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(toggleWishDia)];
		btRomeve.tag = 4652;
		UIBarButtonItem* btAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(toggleWishDia)];
		btAdd.tag = 4652;
		Package* myPackage = MSHookIvar<Package *>(self, "package_");
		[BT addObject:[[%c(WishDiaController) shared] wishIdExist:[myPackage id]]?btRomeve:btAdd];
		self.navigationItem.rightBarButtonItems = [BT copy];
	} @catch (NSException * e) {
	}
}
%new
- (void)launchWishDia
{
	@try {
		[[UIApplication sharedApplication] presentModalViewController:[%c(WishDiaController) shared] force:YES];
	} @catch (NSException * e) {
	}
}
%end


@implementation WishDiaController
{
	UIView *view;
}
@synthesize package_list, cydiaObject;
+ (id) shared
{
	static __strong WishDiaController *WishDiaC;
	if (!WishDiaC) {
		WishDiaC = [[self alloc] init];
		WishDiaC.cydiaObject = [[%c(CydiaObject) alloc] init];
	}
	return WishDiaC;
}
- (void)closePopUp
{
	[self dismissModalViewControllerAnimated:YES];
}
- (void)Refresh
{
	@try {
		NSDictionary *TweakPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];
		NSMutableArray* ArrMut = (NSMutableArray*)[[TweakPrefs objectForKey:@"package_list"]?:@[] mutableCopy];		
		package_list = [ArrMut copy];
		[self.tableView reloadData];
	} @catch (NSException * e) {
	}
}
- (BOOL)wishIdExist:(NSString*)arg1
{
	@autoreleasepool {
		if(arg1) {
			NSDictionary *TweakPrefsCheck = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary];
			NSArray* Arr = (NSArray*)[TweakPrefsCheck objectForKey:@"package_list"]?:@[];
			for(NSDictionary* dicNow in Arr) {
				if([dicNow[@"id"] isEqualToString:arg1]) {
					return YES;
				}
			}
		}
		return NO;
	}
}
- (void)removeWishById:(NSString*)arg1
{
	@autoreleasepool {
		if(![self wishIdExist:arg1]) {
			return;
		}
		NSMutableDictionary *TweakPrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		NSArray* Arr = (NSArray*)[TweakPrefsCheck objectForKey:@"package_list"]?:@[];
		NSMutableArray* newArr = [NSMutableArray array];
		for(NSDictionary* dicNow in Arr) {
			if([dicNow[@"id"] isEqualToString:arg1]) {
				continue;
			}
			[newArr addObject:dicNow];
		}
		[newArr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSString* d1 = obj1[@"time"];
			NSString* d2 = obj2[@"time"];
			return [d2 compare:d1];
		}];
		[TweakPrefsCheck setObject:newArr forKey:@"package_list"];
		[TweakPrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
	}
}
- (void)addWishById:(NSString*)arg1
{
	@autoreleasepool {
		if([self wishIdExist:arg1]) {
			[self removeWishById:arg1];
		}
		NSMutableDictionary *TweakPrefsCheck = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
		NSMutableArray* ArrMut = (NSMutableArray*)[[TweakPrefsCheck objectForKey:@"package_list"]?:@[] mutableCopy];
		[ArrMut addObject:@{@"id":arg1, @"time":[NSDate date],}];
		[ArrMut sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSString* d1 = obj1[@"time"];
			NSString* d2 = obj2[@"time"];
			return [d2 compare:d1];
		}];
		[TweakPrefsCheck setObject:ArrMut forKey:@"package_list"];
		[TweakPrefsCheck writeToFile:@PLIST_PATH_Settings atomically:YES];
	}
}
- (void)toggleById:(NSString*)arg1
{
	if([self wishIdExist:arg1]) {
		[self removeWishById:arg1];
	} else {
		[self addWishById:arg1];
	}
}
- (void) loadView
{
	[super loadView];	
    view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self setView:view];
    self.tableView = [[UITableView alloc] initWithFrame:[view bounds] style:UITableViewCellStyleSubtitle];
    [self.tableView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [(UITableView *)self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    [view addSubview:self.tableView];
	[self Refresh];
}

- (void)viewWillAppear:(BOOL)arg1
{
	[super viewWillAppear:arg1];
	[self Refresh];
	static __strong UIBarButtonItem* kBTClose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closePopUp)];
	self.navigationItem.leftBarButtonItems = @[kBTClose];
}
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"WishDia";
}
- (PackageCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static __strong NSString* packageident = [@"PackageWish" copy];
	PackageCell *cellP((PackageCell *)[tableView dequeueReusableCellWithIdentifier:packageident]);
	if (cellP == nil) {
		cellP = [[%c(PackageCell) alloc] init];
	}
	
	Package *Package_id = [cydiaObject getPackageById:package_list[indexPath.row][@"id"]];
	if(Package_id&&[Package_id isKindOfClass:%c(Package)]) {
		[cellP setPackage:Package_id asSummary:NO];
	} else {
		UITableViewCell* cell = [[%c(UITableViewCell) alloc] init];
		cell.textLabel.text = package_list[indexPath.row][@"id"];
		return (PackageCell*)cell;
	}
	return cellP;
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self dismissViewControllerAnimated:YES completion:^{
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
			[[UIApplication sharedApplication] openCydiaURL:[NSURL URLWithString:[[[@"cydia://" stringByAppendingString:@"package"] stringByAppendingString:@"/"] stringByAppendingString:package_list[indexPath.row][@"id"]]] forExternal:YES];
		});
	}];
	return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [package_list count];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 73;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self removeWishById:package_list[indexPath.row][@"id"]];
	[self Refresh];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"Wish List (%d)", (int)[package_list count]];
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [[NSBundle bundleWithPath:@"/System/Library/Frameworks/UIKit.framework"] localizedStringForKey:@"Delete" value:@"Delete" table:nil]?:@"Delete";
}
- (NSURL *) navigationURL
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://"]];
}
@end
