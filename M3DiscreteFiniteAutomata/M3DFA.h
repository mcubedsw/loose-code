/*****************************************************************
 M3DFA.h
 M3Foundation
 
 Created by Martin Pilkington on 17/12/2009.
 
 Please read the LICENCE.txt for licensing information
*****************************************************************/

#import <Cocoa/Cocoa.h>

#if NS_BLOCKS_AVAILABLE

/***************************
 A deterministic finite automaton class. The automaton is defined using the format described below and passed into the initialise to create an automaton.
 This can then be used to parse an input string to see if the string is valid and retreive any output from it. While this may seem a trivial and academic class, it is highly
 useful for creating more complex regular expressions, as an automaton can be much easier to visualise and debug.
 
 __This class requires Mac OS X 10.6 or later__
 
 **Defining an automaton**
 
 An automaton is defined as a series of states, each states being contained on a single line and given an integer value. Each state contains a series of transitions,
 consiting of an input value and the state to move to upon receiving that value. There is also a special state, END, which signifies that this is a valid end state. If
 your automaton parses a string and does not finish in a state with an END transition, the parsing of the string will have failed.
 
 Transitions are defined in the form: 
 
 input > x
 
 Where input is a character, a character set or a wildcard (.) and x is the number of the state to transition to. A transition can also result in the output of the input charcter 
 (useful  for capturing text). Such a transition is defined with a double > as so:
 
 input >> x
 
Single character input is defined by adding the character inside double quotes, eg "a", "%", "9".

Character sets are defined by putting characters inside square brackets. For example, [mac42] would only match the characters a, c, m, 2 and 4. There are also 4 special 
 character sets:
 
 \w - All whitespace character sets
 a-z - all lower case latin characters
 A-Z - all upper case latin characters
 0-9 - all digits
 
 These can be grouped together. For example, a character set for hexadecimal characters and whitespace could be defined as [0-9abcdef\w]
 
 The last item is a wildcard character, which is signified by a dot . and allows any character.
 
 
 States are defined as the state number followed by a : which is then followed by a comma separated list of transitions.
 
 
 And example automaton is shown below. It looks for a URL begining with www. and ending with a TLD and extracts the site name, eg www.apple.com would return 
 apple:
 
 0: "w" > 1
 1: "w" > 2
 2: "w" > 3
 3: "." > 4
 4: "." > 5, . >> 4
 5: . > 5, END
 
 Notice how in state 4, the transition when a . character is encontered is before the wildcard transition. Transitions are checked in the order in which they are written, 
 so a wild card transition should come after any other transitions, or they won't be checked.
 
 @since M3Foundation 1.0 and later
***************************/
@interface M3DFA : NSObject {
	NSDictionary *automata;
	NSMutableArray *endStates;
	NSInteger initialState;
}

/***************************
 Creates an automaton from a supplied string, returning an error if it fails
 @param aut The automaton string
 @param error A pointer to an NSError object
 @result The created automaton, of nil if invalid
 @since M3Foundation 1.0 and later
***************************/
- (id)initWithAutomaton:(NSString *)aut error:(NSError **)error;

/***************************
 Parses the supplied string, checking its validity and returning output against the automaton
 Output is collected upon first encountering an output transition up until it encounters a non-output transition. It then invokes the block passing in the 
 output and the state it is moving to. Note that output is returned while parsing is continuing, but the validity of the full string is not known until it has been parsed in
 its entirerity. As such, if you only want to accept output of a fully valid string then you should store the output in a temporary location until the parsing is complete.
 
 @param str The string to parse
 @param block A block to handle any output
 @result YES if the string is valid, otherwise NO
 @since M3Foundation 1.0 and later
***************************/
- (BOOL)parseString:(NSString *)str outputBlock:(void (^)(NSString *output, NSInteger state))block;


@end

#endif