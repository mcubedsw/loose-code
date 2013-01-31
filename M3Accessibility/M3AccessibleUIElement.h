/*****************************************************************
 M3AccessibleUIElement.h
 M3Foundation
 
 Created by Martin Pilkington on 03/11/2009.
 
 Please read the LICENCE.txt for licensing information
*****************************************************************/

#import <Cocoa/Cocoa.h>

@class M3AccessibilityController;

/***************************
 Represents an AXUIElementRef, providing a more Cocoa like interface to it.
 @since M3Foundation 1.0 and later
 ***************************/
@interface M3AccessibleUIElement : NSObject <NSCopying> 

/***************************
 @property element
 Returns the AXUIElement represented by the object
 @since M3Foundation 1.0 and later
 ***************************/
@property (readonly) AXUIElementRef element;

@property (readonly, weak) M3AccessibilityController *accessibilityController;

/***************************
 Creates a new object with the supplied element
 @discussion The element is retained using CFRetain
 @param newElement The element to initialise the object with
 @result The initialised object
 @since M3Foundation 1.0 and later
 ***************************/
- (id)initWithElement:(AXUIElementRef)newElement accessibilityController:(M3AccessibilityController *)aController;

/***************************
 Returns the description for the supplied action
 @param action The action to get the description for
 @param error A pointer to an NSError object
 @result The action description
 @since M3Foundation 1.0 and later
 ***************************/
- (NSString *)descriptionForAction:(NSString *)action error:(NSError **)error;

/***************************
 Returns the names of the actions on the item
 @param error A pointer to an NSError object
 @result An array of action names
 @since M3Foundation 1.0 and later
 ***************************/
- (NSArray *)actionNamesAndError:(NSError **)error;

/***************************
 Returns the names of the attributes on the item
 @param error A pointer to an NSError object
 @result An array of attribute names
 @since M3Foundation 1.0 and later
 ***************************/
- (NSArray *)attributeNamesAndError:(NSError **)error;

/***************************
 Returns the value for the attribute
 @param attribute The attribute to get the value of
 @param error A pointer to an NSError object
 @result The value of the supplied attribute
 @since M3Foundation 1.0 and later
 ***************************/
- (id)valueForAttribute:(NSString *)attribute error:(NSError **)error;

/***************************
 Returns the values for the supplied attribute
 @param attribute The attribute to get
 @param range The range of values to return
 @param error A pointer to an NSError object
 @result The values for the attribute
 @since M3Foundation 1.0 and later
 ***************************/
- (id)valuesForAttribute:(NSString *)attribute inRange:(NSRange)range error:(NSError **)error;

/***************************
 Checks if the supplied attribute is settable
 @param attribute The attribute to check
 @param error A pointer to an NSError object
 @result YES if the attribute is settable, otherwise NO
 @since M3Foundation 1.0 and later
 ***************************/
- (BOOL)isAttributeSettable:(NSString *)attribute error:(NSError **)error;

/***************************
 Performs the supplied action
 @param action The action to perform
 @param error A pointer to an NSError object
 @since M3Foundation 1.0 and later
 ***************************/
- (BOOL)performAction:(NSString *)action error:(NSError **)error;

/***************************
 Posts a keyboard character
 @param keyChar The key character to post
 @param virtualKey The virtual key to post
 @param keyDown The key to press
 @param error A pointer to an NSError object
 @since M3Foundation 1.0 and later
 ***************************/
- (BOOL)postKeyboardEventWithKeyCharacter:(CGCharCode)keyChar virtualKey:(CGKeyCode)virtualKey keyDown:(BOOL)keyDown error:(NSError **)error;

/***************************
 Sets the value of the supplied attribute
 @param value The new value
 @param attribute The attribute to set
 @param error A pointer to an NSError object
 @since M3Foundation 1.0 and later
 ***************************/
- (BOOL)setValue:(id)value forAttribute:(NSString *)attribute error:(NSError **)error;

/***************************
 Returns the process ID for the represented element
 @param error A pointer to an NSError object
 @result The process ID for the represented element
 @since M3Foundation 1.0 and later
 ***************************/
- (pid_t)processIDAndError:(NSError **)error;

@end
