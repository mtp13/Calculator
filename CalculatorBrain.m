//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Mike Pullen on 7/1/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "CalculatorBrain.h"

@interface CalculatorBrain()
@property (nonatomic, strong) NSMutableArray *programStack;
@end

@implementation CalculatorBrain

@synthesize programStack = _programStack;

- (NSMutableArray *)programStack {
    if(!_programStack) {
        _programStack = [[NSMutableArray alloc] init];
    }
    return _programStack;
}

- (void)pushOperand:(double)operand {
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)variable; {
    [self.programStack addObject:variable];
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program {
    return [self.programStack copy];
}
+ (BOOL)isOperation:(NSString *)operation {
    BOOL answer = NO;
    NSSet *operationsImplementedInCalculator = 
    [NSSet setWithObjects:@"+", @"*", @"-", @"/", @"sin", @"cos", @"π", @"sqrt",
     @"+/-", nil];
    if ([operationsImplementedInCalculator containsObject:operation]) {
        answer = YES;
    }
    return answer;
}

+ (BOOL)isTwoOperandOperation:(NSString *)operation {
    BOOL answer = NO;
    NSSet *twoOperandOperations = [NSSet setWithObjects:@"+", @"*", @"-", @"/", 
                                   nil];
    if ([twoOperandOperations containsObject:operation]) {
        answer = YES;
    }
    return  answer;
}

+ (BOOL)isSingleOperandOperation:(NSString *)operation {
    BOOL answer = NO;
    NSSet *singleOperandOperations = [NSSet setWithObjects:@"sin", @"cos", @"sqrt", 
                                      nil];
    if ([singleOperandOperations containsObject:operation]) {
        answer = YES;
    }
    return  answer;
}

+ (BOOL)isNoOperandOperation:(NSString *)operation {
    BOOL answer = NO;
    NSSet *noOperandOperations = [NSSet setWithObjects:@"π", @"+/-", nil];
    if ([noOperandOperations containsObject:operation]) {
        answer = YES;
    }
    return  answer;
}

+ (BOOL)isVariable:(NSString *)operation {
    BOOL answer = NO;
    if (![self isOperation:operation]) {
        answer = YES;
    }
    return  answer;
}

+ (NSString *)descriptionOffTopOfStack:(NSMutableArray *)stack {
    
    NSString *result = @"";
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [NSString stringWithFormat:@"%@", topOfStack];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        if ([self isNoOperandOperation:topOfStack]) {
            result = topOfStack;
        } else if ([self isVariable:topOfStack]) {
            result = topOfStack;
        } else if ([self isSingleOperandOperation:topOfStack]) {
            NSString *functionArgument = [self descriptionOffTopOfStack:stack];
            NSRange range = [functionArgument rangeOfString:@"("]; 
            if (range.location == 0) {
                result = [NSString stringWithFormat:@"%@%@", topOfStack,
                          functionArgument];
            } else {
                result = [NSString stringWithFormat:@"%@(%@)", topOfStack,
                          functionArgument];
            }
        } else if ([self isTwoOperandOperation:topOfStack]) {
            id operand2 = [self descriptionOffTopOfStack:stack];
            id operand1 = [self descriptionOffTopOfStack:stack];
            if ([topOfStack isEqual:@"*"]  || [topOfStack isEqual:@"/"]) {
                result = [NSString stringWithFormat:@"%@ %@ %@", operand1,
                          topOfStack, operand2];
            } else {
                
                result = [NSString stringWithFormat:@"(%@ %@ %@)", operand1,
                          topOfStack, operand2];
            }
        }
    }
    
    return result;
}

+ (NSString *)descriptionOfProgram:(id)program {
    NSMutableArray *stack;
    NSString *description = @"";
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    description = [self descriptionOffTopOfStack:stack];
    while ([stack count] > 0) {
        description = [NSString stringWithFormat:@"%@, %@", description,
                       [self descriptionOffTopOfStack:stack]];
    }
    
    return description;
}

+ (double)popOperandOffStack:(NSMutableArray *)stack {
    double result = 0;
    
    id topOfStack = [stack lastObject];
    if (topOfStack) [stack removeLastObject];
    
    if ([topOfStack isKindOfClass:[NSNumber class]]) {
        result = [topOfStack doubleValue];
    }
    else if ([topOfStack isKindOfClass:[NSString class]]) {
        NSString *operation = topOfStack;
        if ([operation isEqualToString:@"+"]) {
            result = [self popOperandOffStack:stack] + 
            [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * 
            [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"-"]) {
            double subtrahend = [self popOperandOffStack:stack];
            result = [self popOperandOffStack:stack] - subtrahend;
        } else if ([operation isEqualToString:@"/"]) {
            double divisor = [self popOperandOffStack:stack];
            if (divisor) result = [self popOperandOffStack:stack] / divisor;
        } else if ([operation isEqualToString:@"sin"]) {
            result = sin([self popOperandOffStack:stack]);
        } else if ([operation isEqualToString:@"cos"]) {
            result = cos([self popOperandOffStack:stack]);
        }  else if ([operation isEqualToString:@"π"]) {
            result = M_PI;
        } else if ([operation isEqualToString:@"sqrt"]) {
            double operand = [self popOperandOffStack:stack];
            if (operand >= 0) result = sqrt(operand);
        } else if ([operation isEqualToString:@"+/-"]) {
            result = -1 * [self popOperandOffStack:stack];
        }
    }
    
    return result;
    
}

+ (NSSet *)variablesUsedInProgram:(id)program 
{
    
    NSSet *_variablesUsedInProgram = [NSSet set];
    NSMutableArray *stack;
    
    if([program isKindOfClass:[NSArray class]]) 
        {
        stack = [program mutableCopy];
        for (id stackObject in stack) 
            {
            // if stackObject is string it must be either a variable or operation
            if ([stackObject isKindOfClass:[NSString class]]) 
                {
                // if stackObject is not an operation it must be a variable
                if (![self isOperation:stackObject]) 
                    {
                    // add stackObject to the set of _variablesUsedInProgram
                    _variablesUsedInProgram = 
                    [_variablesUsedInProgram setByAddingObject:stackObject]; 
                    }
                }
            }
        }
    if ([_variablesUsedInProgram count] > 0) 
        {
        return _variablesUsedInProgram;
        } else {
            return nil;  //return nil if empty set
        }
}

+ (double)runProgram:(id)program 
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) 
        {
        stack = [program mutableCopy];
        }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues
{
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]])
        {
        stack = [program mutableCopy];
        }
    NSSet *variablesInMyStack = [CalculatorBrain variablesUsedInProgram:stack];
    for (int i = 0; i < ([stack count] - 1); i++) 
        {
        id stackObject = [stack objectAtIndex:i];
        if ([variablesInMyStack containsObject:stackObject]) 
            {
            NSNumber *value = [variableValues objectForKey:stackObject];
            //            NSLog(@"value=%@", value);
            if (value) 
                {
                [stack replaceObjectAtIndex:i withObject:value];
                } else 
                    {
                    [stack replaceObjectAtIndex:i withObject:
                     [NSNumber numberWithDouble:0]];
                    }
            }
        }
    return [self popOperandOffStack:stack];
}

- (void)clear 
{
    [self.programStack removeAllObjects];
}


@end
