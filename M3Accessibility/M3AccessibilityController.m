/*****************************************************************
 M3AccessibilityController.m
 M3Foundation
 
 Created by Martin Pilkington on 03/11/2009.
 
 Please read the LICENCE.txt for licensing information
*****************************************************************/

#import "M3AccessibilityController.h"
#import "M3AccessibleUIElement.h"

NSString *M3AccessibilityErrorDomain = @"com.mcubedsw.M3Foundation.accessibility";

@implementation M3AccessibilityController

@synthesize systemWideElement;

//*****//
- (BOOL)isAccessibilityEnabled {
	return (BOOL)AXAPIEnabled();
}

//*****//
- (M3AccessibleUIElement *)elementForActiveApplication {
	pid_t processid = (pid_t)[[[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationProcessIdentifier"] integerValue];
	return [[M3AccessibleUIElement alloc] initWithElement:AXUIElementCreateApplication(processid) accessibilityController:self];
}

//*****//
- (M3AccessibleUIElement *)elementForApplicationWithPid:(pid_t)processid {
	return [[M3AccessibleUIElement alloc] initWithElement:AXUIElementCreateApplication(processid) accessibilityController:self];
}

//*****//
- (M3AccessibleUIElement *)systemWideElement {
	if (!systemWideElement) {
		systemWideElement = [[M3AccessibleUIElement alloc] initWithElement:AXUIElementCreateSystemWide() accessibilityController:self];
	}
	return systemWideElement;
}

//*****//
- (M3AccessibleUIElement *)elementAtPosition:(NSPoint)point error:(NSError **)error {
	AXUIElementRef element = NULL;
	AXError errorCode = AXUIElementCopyElementAtPosition([[self systemWideElement] element], point.x, point.y, &element);
	
	if (error != NULL && errorCode != 0) {
		*error = [self errorForCode:errorCode];
	}
	return [[M3AccessibleUIElement alloc] initWithElement:element accessibilityController:self];
}

//*****//
- (NSError *)errorForCode:(NSInteger)code {
	NSString *localisedDescription = @"";
	if (code == kAXErrorFailure) {
		localisedDescription = NSLocalizedString(@"A system error occured.", @"");
	} else if (code == kAXErrorIllegalArgument) {
		localisedDescription = NSLocalizedString(@"An illegal argument was passed to the function.", @"");
	} else if (code == kAXErrorInvalidUIElement) {
		localisedDescription = NSLocalizedString(@"The UI element passed to the function was invalid.", @"");
	} else if (code == kAXErrorInvalidUIElementObserver) {
		localisedDescription = NSLocalizedString(@"The observer passed to the function was invalid", @"");
	} else if (code == kAXErrorCannotComplete) {
		localisedDescription = NSLocalizedString(@"Could not complete the operation. The application being communicated with may be busy or unresponsive.", @"");
	} else if (code == kAXErrorAttributeUnsupported) {
		localisedDescription = NSLocalizedString(@"The supplied attribute is not supported by this UI element.", @"");
	} else if (code == kAXErrorActionUnsupported) {
		localisedDescription = NSLocalizedString(@"The supplied action is not supported by this UI element.", @"");
	} else if (code == kAXErrorNotificationUnsupported) {
		localisedDescription = NSLocalizedString(@"The supplied notification is not supported by this UI element", @"");
	} else if (code == kAXErrorNotImplemented) {
		localisedDescription = NSLocalizedString(@"The targeted application does not implement the correct accessibility API methods", @"");
	} else if (code == kAXErrorNotificationAlreadyRegistered) {
		localisedDescription = NSLocalizedString(@"The supplied notification has already been registered", @"");
	} else if (code == kAXErrorNotificationNotRegistered) {
		localisedDescription = NSLocalizedString(@"The notification is not yet registered", @"");
	} else if (code == kAXErrorAPIDisabled) {
		localisedDescription = NSLocalizedString(@"The accessibility API is not enabled", @"");
	} else if (code == kAXErrorNoValue) {
		localisedDescription = NSLocalizedString(@"The requested value does not exist", @"");
	} else if (code == kAXErrorParameterizedAttributeUnsupported) {
		localisedDescription = NSLocalizedString(@"The supplied parameterised attribute is not supported by this UI element", @"");
	} else if (code == kAXErrorNotEnoughPrecision) {
		localisedDescription = NSLocalizedString(@"Undocumented Error: Not Enough Precision", @"");
	} else {
		return nil;
	}
	
	NSError *error = [NSError errorWithDomain:M3AccessibilityErrorDomain 
										 code:code 
									 userInfo:[NSDictionary dictionaryWithObject:localisedDescription forKey:NSLocalizedDescriptionKey]];
	
	return error;
}


@end
