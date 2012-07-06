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

+ (NSSet *)operationsUsedInCalculator {
    return [NSSet setWithObjects:@"+", @"*", @"-", @"/", @"sin", @"cos", @"π", 
            @"sqrt", @"+/-", nil];
}

- (void)pushOperand:(double)operand {
    NSNumber *operandObject = [NSNumber numberWithDouble:operand];
    [self.programStack addObject:operandObject];
}

- (void)pushVariable:(NSString *)variable; {
    if (![[CalculatorBrain operationsUsedInCalculator] containsObject:variable]) {
        [self.programStack addObject:variable];
    }
}

- (double)performOperation:(NSString *)operation {
    [self.programStack addObject:operation];
    return [CalculatorBrain runProgram:self.program];
}

- (id)program {
    return [self.programStack copy];
}

+ (NSString *)descriptionOfProgram:(id)program {
    return @"Implement this in Assignment 2";
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
            result = [self popOperandOffStack:stack] + [self popOperandOffStack:stack];
        } else if ([operation isEqualToString:@"*"]) {
            result = [self popOperandOffStack:stack] * [self popOperandOffStack:stack];
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
            result = - [self popOperandOffStack:stack];
        }
    }
    
    return result;
        
}

+ (NSSet *)variablesUsedInProgram:(id)program {
    NSSet *_variablesUsedInProgram;
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = program;
        for (id stackObject in stack) {
            // if stackObject is string it must be either a variable or operation
            if ([stackObject isKindOfClass:[NSString class]]) {
                // if stackObject is not an operation it must be a variable
                if (![[self operationsUsedInCalculator] containsObject:stackObject]) {
                    // add stackObject to the set of _variablesUsedInProgram
                    _variablesUsedInProgram = 
                    [_variablesUsedInProgram setByAddingObject:stackObject]; 
                }
            }
        }
    }
    if ([_variablesUsedInProgram count] > 0) {
        return _variablesUsedInProgram;
    } else {
        return nil;  //return nil if empty set
    }
}

+ (double)runProgram:(id)program {
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    return [self popOperandOffStack:stack];
}

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues {
    NSMutableArray *stack;
    if([program isKindOfClass:[NSArray class]]) {
        stack = [program mutableCopy];
    }
    
    return 0; //TODO
    
    
}
    
- (void)clear {
    [self.programStack removeAllObjects];
}


@end
