/*****************************************************************
 M3AccessibleUIElement.m
 M3Foundation
 
 Created by Martin Pilkington on 03/11/2009.
 
 Please read the LICENCE.txt for licensing information
*****************************************************************/

#import "M3AccessibleUIElement.h"
#import "M3AccessibilityController.h"

@interface M3AccessibleUIElement ()

- (id)sanitiseValue:(id)value;

@end


@implementation M3AccessibleUIElement 

@synthesize element, accessibilityController;

//*****//
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

//*****//
- (id)initWithElement:(AXUIElementRef)newElement accessibilityController:(M3AccessibilityController *)aController {
	if ((self = [super init])) {
		element = CFRetain(newElement);
		accessibilityController = aController;
	}
	return self;
}

//*****//
- (void)dealloc {
	if (element) CFRelease(element);
}

//*****//
- (void)finalize {
	if (element) CFRelease(element);
	[super finalize];
}

//*****//
- (NSString *)descriptionForAction:(NSString *)action error:(NSError **)error {
	CFStringRef description = nil;
	AXError errorCode = AXUIElementCopyActionDescription (element, (__bridge_retained CFStringRef)action, &description);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	return returnError != nil ? (__bridge_transfer NSString *)description : nil;
}

//*****//
- (NSArray *)actionNamesAndError:(NSError **)error {
	CFArrayRef names = nil;
	AXError errorCode = AXUIElementCopyActionNames(element, &names);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	return (__bridge_transfer NSArray *)names;
}

//*****//
- (NSArray *)attributeNamesAndError:(NSError **)error {
	CFArrayRef names = nil;
	AXError errorCode = AXUIElementCopyAttributeNames(element, &names);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	return (__bridge_transfer NSArray *)names;
}

//*****//
- (id)valueForAttribute:(NSString *)attribute error:(NSError **)error {
	CFTypeRef value = nil;
	if ([[self attributeNamesAndError:NULL] containsObject:attribute]) {
		AXError errorCode = AXUIElementCopyAttributeValue(element, (__bridge_retained CFStringRef)attribute, &value);
		NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
		if (error != NULL && returnError)
			*error = returnError;
	}
	
	return [self sanitiseValue:(__bridge_transfer id)value];
}

//*****//
- (id)valuesForAttribute:(NSString *)attribute inRange:(NSRange)range error:(NSError **)error {
	CFArrayRef values = nil;
	AXError errorCode = AXUIElementCopyAttributeValues(element, (__bridge_retained CFStringRef)attribute, range.location, range.length, &values);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	return [self sanitiseValue:(__bridge_transfer id)values];
}

//*****//
- (BOOL)isAttributeSettable:(NSString *)attribute error:(NSError **)error {
	Boolean settable;
	AXError errorCode = AXUIElementIsAttributeSettable(element, (__bridge_retained CFStringRef)attribute, &settable);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	return (BOOL)settable;
}

//*****//
- (BOOL)performAction:(NSString *)action error:(NSError **)error {
	AXError errorCode = AXUIElementPerformAction(element, (__bridge_retained CFStringRef)action);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError) {
		*error = returnError;
		return NO;
	}
	return YES;
}

//*****//
- (BOOL)postKeyboardEventWithKeyCharacter:(CGCharCode)keyChar virtualKey:(CGKeyCode)virtualKey keyDown:(BOOL)keyDown error:(NSError **)error {
	AXError errorCode = AXUIElementPostKeyboardEvent(element, keyChar, virtualKey, (Boolean)keyDown);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError) {
		*error = returnError;
		return NO;
	}
	return YES;
}

//*****//
- (BOOL)setValue:(id)value forAttribute:(NSString *)attribute error:(NSError **)error {
	AXError errorCode = AXUIElementSetAttributeValue(element, (__bridge_retained CFStringRef)attribute, (__bridge_retained CFTypeRef)value);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError) {
		*error = returnError;
		return NO;
	}
	return YES;
}

//*****//
- (id)sanitiseValue:(id)value {
	if (!value)
		return nil;
	AXValueRef valueRef = (__bridge_retained AXValueRef)value;
	//If we have a valid type convert to an NSPoint
	if (AXValueGetType(valueRef) != kAXValueIllegalType) {
		CGPoint rawValue;
		AXValueGetValue(valueRef, AXValueGetType(valueRef), &rawValue);
		switch (AXValueGetType(valueRef)) {
			case kAXValueCGPointType: {
				CGPoint rawValue;
				AXValueGetValue(valueRef, kAXValueCGPointType, &rawValue);
				return [NSValue valueWithPoint:rawValue];
			}
			case kAXValueCGSizeType: {
				CGSize rawValue;
				AXValueGetValue(valueRef, kAXValueCGSizeType, &rawValue);
				return [NSValue valueWithSize:rawValue];
			}
			case kAXValueCGRectType: {
				CGRect rawValue;
				AXValueGetValue(valueRef, kAXValueCGRectType, &rawValue);
				return [NSValue valueWithRect:rawValue];
			}
			case kAXValueCFRangeType: {
				NSRange rawValue;
				AXValueGetValue(valueRef, kAXValueCFRangeType, &rawValue);
				return [NSValue valueWithRange:rawValue];
			}
			default: {}
		}
	}
	
	//If we get back an array then create an array of values
	if ([value isKindOfClass:[NSArray class]]) {
		NSMutableArray *array = [NSMutableArray array];
		for (id subvalue in value) {
			[array addObject:[self sanitiseValue:subvalue]];
		}
		return [[array copy] autorelease];
	//And if we have a UI element, create a new element
	} else if ([[value description] rangeOfString:@"AXUIElement"].location != NSNotFound) {
		return [[M3AccessibleUIElement alloc] initWithElement:(__bridge_retained AXUIElementRef)value 
									  accessibilityController:self.accessibilityController];
	}
	return value;
}

//*****//
- (NSString *)description {
	NSString *role = [self valueForAttribute:@"AXRole" error:nil];
	id value = [self valueForAttribute:@"AXValue" error:nil];
	if (value) {
		return [NSString stringWithFormat:@"%@ (%@)", role, value];
	}
	return role;
}

//*****//
- (pid_t)processIDAndError:(NSError **)error {
	pid_t pid = 0;
	AXError errorCode = AXUIElementGetPid(element, &pid);
	NSError *returnError = [self.accessibilityController errorForCode:(NSInteger)errorCode];
	if (error != NULL && returnError)
		*error = returnError;
	
	return pid;
}

//*****//
- (BOOL)isEqual:(id)object {
	if (![[self valueForAttribute:(NSString *)kAXRoleAttribute error:NULL] isEqualToString:[object valueForAttribute:(NSString *)kAXRoleAttribute error:NULL]]) {
		return NO;
	}
	NSString *subroleSelf = [self valueForAttribute:(NSString *)kAXSubroleAttribute error:NULL];
	NSString *subroleObject = [object valueForAttribute:(NSString *)kAXSubroleAttribute error:NULL];
	if (![subroleSelf isEqualToString:subroleObject] && subroleSelf && subroleObject) {
		return NO;
	}
	
	NSString *titleSelf = [self valueForAttribute:(NSString *)kAXTitleAttribute error:NULL];
	NSString *titleObject = [object valueForAttribute:(NSString *)kAXTitleAttribute error:NULL];
	if (![titleSelf isEqualToString:titleObject] && titleSelf && titleObject) {
		return NO;
	}
	
	id valueSelf = [self valueForAttribute:(NSString *)kAXValueAttribute error:NULL];
	id valueObject = [object valueForAttribute:(NSString *)kAXValueAttribute error:NULL];
	if (![valueSelf isEqual:valueObject] && valueSelf && valueObject) {
		return NO;
	}

	if (!NSEqualPoints([[self valueForAttribute:(NSString *)kAXPositionAttribute error:NULL] pointValue], [[object valueForAttribute:(NSString *)kAXPositionAttribute error:NULL] pointValue])) {
		return NO;
	}
	return YES;
}

@end
