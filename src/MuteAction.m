//
//  MuteAction.m
//  MarcoPolo
//
//  Created by David Symonds on 7/06/07.
//

#import "MuteAction.h"


@implementation MuteAction

- (NSString *)description
{
	if (turnOn)
		return NSLocalizedString(@"Unmuting system audio.", @"");
	else
		return NSLocalizedString(@"Muting system audio.", @"");
}

- (BOOL)execute:(NSString **)errorString
{
	NSString *script = [NSString stringWithFormat:@"set volume %@ output muted",
				(turnOn ? @"without" : @"with")];
	NSArray *args = [NSArray arrayWithObjects:@"-e", script, nil];
	NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/osascript" arguments:args];
	[task waitUntilExit];

	// Should never happen
	//if ([task terminationStatus] != 0) {
	//	return NO;
	//}

	return YES;
}

+ (NSString *)helpText
{
	return NSLocalizedString(@"The parameter for Mute actions is simply either \"on\" "
				 "or \"off\", depending on whether you want your system audio "
				 "unmuted or muted.", @"");
}

+ (NSArray *)limitedOptions
{
	return [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"off", @"option",
			NSLocalizedString(@"Mute system audio", @""), @"description", nil],
		[NSDictionary dictionaryWithObjectsAndKeys:@"on", @"option",
			NSLocalizedString(@"Unmute system audio", @""), @"description", nil],
		nil];
}

+ (NSString *)limitedOptionHelpText
{
	return @"";
}

- (id)initWithOption:(NSString *)option
{
	return [super initWithOption:option];
}

@end
