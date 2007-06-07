//
//  Action.m
//  MarcoPolo
//
//  Created by David Symonds on 3/04/07.
//

#import "Action.h"
#import "SysConf.h"


@implementation Action

+ (NSString *)typeForClass:(Class)klass
{
	// Hack "Action" off class name (6 chars)
	// TODO: make this a bit more robust?
	NSString *className = NSStringFromClass(klass);
	return [className substringToIndex:([className length] - 6)];
}

+ (Class)classForType:(NSString *)type
{
	NSString *classString = [NSString stringWithFormat:@"%@Action", type];
	Class klass = NSClassFromString(classString);
	if (!klass) {
		NSLog(@"ERROR: No implementation class '%@'!\n", classString);
		return nil;
	}
	return klass;
}

+ (Action *)actionFromDictionary:(NSDictionary *)dict
{
	NSString *type = [dict valueForKey:@"type"];
	if (!type) {
		NSLog(@"ERROR: Action doesn't have a type!\n");
		return nil;
	}
	Action *obj = [[[Action classForType:type] alloc] initWithDictionary:dict];
	return [obj autorelease];
}

- (id)init
{
	if ([[self class] isEqualTo:[Action class]]) {
		[NSException raise:@"Abstract Class Exception"
			    format:@"Error, attempting to instantiate Action directly."];
	}

	if (!(self = [super init]))
		return nil;

	// Some sensible defaults
	delay = 0;
	type = [Action typeForClass:[self class]];
	location = [SysConf getCurrentLocation];
	when = @"Arrival";

	return self;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
	if ([[self class] isEqualTo:[Action class]]) {
		[NSException raise:@"Abstract Class Exception"
			    format:@"Error, attempting to instantiate Action directly."];
	}

	if (!(self = [super init]))
		return nil;

	delay = [[dict valueForKey:@"delay"] intValue];
	type = [Action typeForClass:[self class]];
	location = [dict valueForKey:@"location"];
	when = [dict valueForKey:@"when"];

	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (NSMutableDictionary *)dictionary
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:delay], @"delay",
		type, @"type",
		location, @"location",
		when, @"when",
		nil];
}

+ (NSString *)helpTextForActionOfType:(NSString *)type
{
	return [[Action classForType:type] helpText];
}

- (void)notImplemented:(NSString *)methodName
{
	[NSException raise:@"Abstract Class Exception"
		    format:[NSString stringWithFormat:@"Error, -[%@ %@] not implemented.",
			    [self class], methodName]];
}

- (NSString *)description
{
	[self notImplemented:@"description"];
	return @"Not implemented!";
}

- (BOOL)execute:(NSString **)errorString
{
	[self notImplemented:@"execute"];
	*errorString = @"Not implemented!";
	return NO;
}

+ (NSString *)helpText
{
	return @"Sorry, no help text written yet!";
}

@end

#pragma mark -

#import "DefaultPrinterAction.h"
#import "MailSMTPServerAction.h"
#import "MuteAction.h"
#import "OpenAction.h"
#import "ShellScriptAction.h"
#import "ToggleBluetoothAction.h"
#import "ToggleWiFiAction.h"

@implementation ActionSetController

- (id)init
{
	if (!(self = [super init]))
		return nil;

	classes = [[NSArray alloc] initWithObjects:
		[DefaultPrinterAction class],
		[MailSMTPServerAction class],
		[MuteAction class],
		[OpenAction class],
		[ShellScriptAction class],
		[ToggleBluetoothAction class],
		[ToggleWiFiAction class],
			nil];
	if (NO) {
		// Purely for the benefit of 'genstrings'
		NSLocalizedString(@"DefaultPrinter", @"Action type");
		NSLocalizedString(@"MailSMTPServer", @"Action type");
		NSLocalizedString(@"Mute", @"Action type");
		NSLocalizedString(@"Open", @"Action type");
		NSLocalizedString(@"ShellScript", @"Action type");
		NSLocalizedString(@"ToggleBluetooth", @"Action type");
		NSLocalizedString(@"ToggleWiFi", @"Action type");
		NSLocalizedString(@"Unmute", @"Action type");
	}

	return self;
}

- (void)dealloc
{
	[classes release];

	[super dealloc];
}

- (NSArray *)types
{
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[classes count]];
	NSEnumerator *en = [classes objectEnumerator];
	Class klass;
	while ((klass = [en nextObject])) {
		[array addObject:[Action typeForClass:klass]];
	}
	return array;
}

#pragma mark NSMenu delegates

- (BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel
{
	Class klass = [classes objectAtIndex:index];
	NSString *type = [Action typeForClass:klass];
	NSString *localisedType = NSLocalizedString(type, @"Action type");

	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Add %@ Action...", @"Menu item"),
		localisedType];
	[item setTitle:title];

	[item setTarget:prefsWindowController];
	[item setAction:@selector(addAction:)];
	[item setRepresentedObject:klass];

	return YES;
}

- (BOOL)menuHasKeyEquivalent:(NSMenu *)menu forEvent:(NSEvent *)event target:(id *)target action:(SEL *)action
{
	// TODO: support keyboard menu jumping?
	return NO;
}

- (int)numberOfItemsInMenu:(NSMenu *)menu
{
	return [classes count];
}

@end
