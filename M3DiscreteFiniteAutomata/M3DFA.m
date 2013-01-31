/*****************************************************************
 M3DFA.m
 M3Foundation
 
 Created by Martin Pilkington on 17/12/2009.
 
 Please read the LICENCE.txt for licensing information
*****************************************************************/

#import "M3DFA.h"

#if NS_BLOCKS_AVAILABLE

/** NB: Yes this is kinda ugly internally. I'll clean it up after I've written tests **/

@interface M3DFA ()

- (NSDictionary *)parseAutomata:(NSString *)aut error:(NSError **)error;
- (id)parseRule:(NSString *)rule;

@end


@implementation M3DFA

//*****//
- (id)initWithAutomaton:(NSString *)aut error:(NSError **)error {
	if ((self = [super init])) {
		initialState = NSNotFound;
		endStates = [[NSMutableArray alloc] init];
		automata = [[self parseAutomata:aut error:&*error] retain];
	}
	return self;
}

//*****//
- (void)dealloc {
	[endStates release];
	[automata release];
	[super dealloc];
}

//*****//
- (NSDictionary *)parseAutomata:(NSString *)aut error:(NSError **)error {
	NSMutableDictionary *parsedAutomata = [NSMutableDictionary dictionary];
	
	//Loop trhough our lines
	[aut enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		//Get the state and the transitions
		NSInteger split = [line rangeOfString:@":"].location;
		NSInteger state = [[line substringToIndex:split] integerValue];
		if (initialState == NSNotFound) {
			initialState = state;
		}
		
		NSMutableArray *transitions = [NSMutableArray array];
		NSString *temp = nil;
		//Get individual transitions
		for (NSString *transitionString in [[line substringFromIndex:split+1] componentsSeparatedByString:@","]) {
			while ([transitionString hasPrefix:@" "]) {
				transitionString = [transitionString substringFromIndex:1];
			}
			if ([transitionString hasSuffix:@"\""]) {
				temp = transitionString;
			} else if (temp) {
				[transitions addObject:[NSString stringWithFormat:@"%@,%@", temp, transitionString]];
				temp = nil;
			} else {
				[transitions addObject:transitionString];
			}
		}
		
		//Get the rules, states and whether it outputs
		NSMutableArray *finishedTransitions = [NSMutableArray array];
		for (NSString *str in transitions) {
			str = [str stringByReplacingOccurrencesOfString:@"\">\"" withString:@"{{{{GREATERTHAN}}}}"];
			str = [str stringByReplacingOccurrencesOfString:@"\">>\"" withString:@"{{{{2GREATERTHAN}}}}"];
			str = [str stringByReplacingOccurrencesOfString:@">>" withString:@">OUTPUT"];
			NSArray *components = [str componentsSeparatedByString:@">"];
			
			NSString *rule = [components objectAtIndex:0];
			NSString *newState = nil;
			
			if ([components count] > 1) {
				newState = [components objectAtIndex:1];
			}
			
			rule = [rule stringByReplacingOccurrencesOfString:@"{{{{GREATERTHAN}}}}" withString:@"\">\""];
			rule = [rule stringByReplacingOccurrencesOfString:@"{{{{2GREATERTHAN}}}}" withString:@"\">>\""];
			
			id parsedRule = [self parseRule:rule];
			BOOL output = NO;
			if ([newState hasPrefix:@"OUTPUT"]) {
				output = YES;
				newState = [newState substringFromIndex:6];
			}
			if (parsedRule) {
				[finishedTransitions addObject:[NSDictionary dictionaryWithObjectsAndKeys:parsedRule, @"rule", [NSNumber numberWithBool:output], @"output", [NSNumber numberWithInteger:[newState integerValue]], @"newState", nil]];
			} else {
				[endStates addObject:[NSNumber numberWithInteger:state]];
			}
		}
		[parsedAutomata setObject:finishedTransitions forKey:[NSNumber numberWithInteger:state]];
	}];
	return parsedAutomata;
}

//*****//
- (id)parseRule:(NSString *)rule {
	while ([rule hasPrefix:@" "]) {
		rule = [rule substringFromIndex:1];
	}
	while ([rule hasSuffix:@" "]) {
		rule = [rule substringToIndex:[rule length]-1];
	}
	
	//And now the end is near…
	if ([rule isEqualToString:@"END"]) {
		return nil;
	//Unquote
	} else if ([rule hasPrefix:@"\""] && [rule hasSuffix:@"\""]) {
		return [rule substringWithRange:NSMakeRange(1, [rule length] - 2)];
	//Handle character sets
	} else if ([rule hasPrefix:@"["] && [rule hasSuffix:@"]"]) {
		NSMutableString *str = [NSMutableString stringWithString:rule];
		NSMutableCharacterSet *characterSet = [[NSMutableCharacterSet alloc] init];
		NSRange lowerCase = [str rangeOfString:@"a-z"];
		if (lowerCase.location != NSNotFound) {
			[characterSet formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
			[str deleteCharactersInRange:lowerCase];
		}
		NSRange upperCase = [str rangeOfString:@"A-Z"];
		if (upperCase.location != NSNotFound) {
			[characterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
			[str deleteCharactersInRange:upperCase];
		}
		NSRange whitespace = [str rangeOfString:@"\\w"];
		if (whitespace.location != NSNotFound) {
			[characterSet formUnionWithCharacterSet:[NSCharacterSet whitespaceCharacterSet]];
			[str deleteCharactersInRange:whitespace];
		}
		NSRange numbers = [str rangeOfString:@"0-9"];
		if (numbers.location != NSNotFound) {
			[characterSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
			[str deleteCharactersInRange:numbers];
		}

		[characterSet addCharactersInString:str];
		return [characterSet autorelease];
		
	} else if ([rule isEqualToString:@"."]) {
		return @"";
	}

	return rule;
}

//*****//
- (BOOL)parseString:(NSString *)str outputBlock:(void (^)(NSString *output, NSInteger state))block {
	NSInteger currentState = initialState;
	
	NSInteger index = 0;
	NSMutableString *outputString = [NSMutableString string];
	
	//While we still have more characters
	while (index < [str length]) {
		//Get the next character and the current rules
		NSString *character = [str substringWithRange:NSMakeRange(index, 1)];
		NSArray *rules = [automata objectForKey:[NSNumber numberWithInteger:currentState]];
		//Find the matching rule and move to the next state
		for (NSDictionary *rule in rules) {
			id ruleObject = [rule objectForKey:@"rule"];
			NSInteger newState = [[rule objectForKey:@"newState"] integerValue];
			BOOL output = [[rule objectForKey:@"output"] boolValue];
			if ([ruleObject isKindOfClass:[NSCharacterSet class]]) {
				if ([ruleObject characterIsMember:[character characterAtIndex:0]]) {
					currentState = newState;
					if (output)
						[outputString appendString:character];
					else {
						if ([outputString length]) {
							block(outputString, currentState);
							[outputString setString:@""];
						}
					}
						
					break;
				}
			} else if ([ruleObject isEqualToString:@""]) {
				currentState = newState;
				if (output)
					[outputString appendString:character];
				else {
					if ([outputString length]) {
						block(outputString, currentState);
						[outputString setString:@""];
					}
				}
				break;
			} else if ([ruleObject isEqualToString:character]) {
				currentState = newState;
				if (output)
					[outputString appendString:character];
				else {
					if ([outputString length]) {
						block(outputString, currentState);
						[outputString setString:@""];
					}
				}
				break;
			}
		}
		index++;
	}
	//Was the string accepted?
	return [endStates containsObject:[NSNumber numberWithInteger:currentState]];
}

@end

#endif