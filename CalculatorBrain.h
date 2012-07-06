//
//  CalculatorBrain.h
//  Calculator
//
//  Created by Mike Pullen on 7/1/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalculatorBrain : NSObject

- (void)pushOperand:(double)operand;

- (void)pushVariable:(NSString *)variable;

- (double)performOperation:(NSString *)operation;

- (void)clear;

@property (readonly) id program;

+ (double)runProgram:(id)program;

+ (double)runProgram:(id)program usingVariableValues:(NSDictionary *)variableValues;

+ (NSSet *)variablesUsedInProgram:(id)program;

+ (NSString *)descriptionOfProgram:(id)program;

@end
