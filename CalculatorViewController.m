//
//  CalculatorViewController.m
//  Calculator
//
//  Created by Mike Pullen on 7/1/12.
//  Copyright (c) 2012. All rights reserved.
//
#import "CalculatorViewController.h"
#import "CalculatorBrain.h"

@interface CalculatorViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic, strong) CalculatorBrain *brain;
@end

@implementation CalculatorViewController

@synthesize display = _display;
@synthesize brainHistory = _brainHistory;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize brain = _brain;

- (CalculatorBrain *)brain {
    if (!_brain) _brain = [[CalculatorBrain alloc] init];
    return _brain;
}

- (IBAction)digitPressed:(UIButton *)sender {
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([digit isEqualToString:@"."]) {
            //check to see if a decimal point is already in the display
            NSRange range = [self.display.text rangeOfString:@"."]; 
            if (range.location == NSNotFound) //if no decimal point then append it
                self.display.text = [self.display.text 
                                     stringByAppendingString:digit];
        } else { // decimal point not pressed
            self.display.text = [self.display.text 
                                 stringByAppendingString:digit];
        }
    } else { //not in the middle of entering a number
        self.brainHistory.text = [self.brainHistory.text 
                                  stringByReplacingOccurrencesOfString:@"=" 
                                  withString:@""];
        if (![digit isEqualToString:@"0"]) {
            if ([digit isEqualToString:@"."]) {
                self.display.text = @"0.";
            } else {
                self.display.text = digit;
            }
            self.userIsInTheMiddleOfEnteringANumber = YES;
        }
    }
}

- (IBAction)enterPressed {
    [self.brain pushOperand:[self.display.text doubleValue]];
    self.brainHistory.text = [self.brainHistory.text 
                              stringByAppendingFormat:@" %@",self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)operationPressed:(UIButton *)sender {
    NSString *operation = sender.currentTitle;
    if ([operation isEqualToString:@"+/-"] && 
        self.userIsInTheMiddleOfEnteringANumber) {
        double operand = - [self.display.text doubleValue];
        self.display.text = [NSString stringWithFormat:@"%g", operand];
    } else {
        if (self.userIsInTheMiddleOfEnteringANumber) {
            [self enterPressed];
        }
        double result = [self.brain performOperation:operation];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        self.brainHistory.text = [[self.brainHistory.text 
                                  stringByReplacingOccurrencesOfString:@"=" withString:@""]
                                  stringByAppendingFormat:@" %@ =", operation];
    }
    
}
- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    if (self.userIsInTheMiddleOfEnteringANumber) [self enterPressed];
    self.display.text = variable;
    [self.brain pushVariable:variable];
    self.brainHistory.text = [self.brainHistory.text 
                              stringByAppendingFormat:@" %@",self.display.text];
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)clearPressed {
    [self.brain clear];
    self.brainHistory.text = @" ";
    self.display.text = @"0";
    self.userIsInTheMiddleOfEnteringANumber = NO;
}

- (IBAction)backspacePressed {
    if (self.userIsInTheMiddleOfEnteringANumber) {
        if ([self.display.text length] > 0) {
            self.display.text = [self.display.text substringToIndex:
                                 [self.display.text length] - 1];
        }
        if ([self.display.text length] == 0) {
            self.display.text = @"0";
            self.userIsInTheMiddleOfEnteringANumber = NO;
        }
    }
}

@end
