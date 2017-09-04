//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by anna on 01.07.17.
//  Copyright © 2017 anna. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation, {symbol + "(" + $0 + ")"})
    }
    private var accumulator: (Double, String)? // number + description
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String)
        case random
        case equals
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unaryOperation(sqrt, {"√(" + $0 + ")"}),
        "cos": Operation.unaryOperation(cos, {"cos(" + $0 + ")"}),
        "±": Operation.unaryOperation({-$0}, {"-(" + $0 + ")"}),
        "×": Operation.binaryOperation({ $0 * $1 }, {$0 + "*" + $1}),
        "÷": Operation.binaryOperation({ $0 / $1 }, {$0 + "/" + $1}),
        "+": Operation.binaryOperation({ $0 + $1 }, {$0 + "+" + $1}),
        "-": Operation.binaryOperation({ $0 - $1 }, {$0 + "-" + $1}),
        "=": Operation.equals,
        "sin": Operation.unaryOperation(sin, {"sin(" + $0 + ")"}),
        "tan": Operation.unaryOperation(tan, {"tan(" + $0 + ")"}),
        "ln": Operation.unaryOperation(log, {"log(" + $0 + ")"}),
        "log": Operation.unaryOperation(log10, {"log10(" + $0 + ")"}),
        "Random": Operation.random
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = (value, symbol)
            case .unaryOperation(let function, let description):
                if accumulator != nil {
                    accumulator = (function(accumulator!.0), description(accumulator!.1))
                }
            case .binaryOperation(let function, let description):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!, description: description)
                    accumulator = nil
                }
            case .equals:
                performPendingBinaryOperation()
            case .random:
                accumulator = (Double(arc4random())/Double(UINT32_MAX), "random()")
            }
        }
    }
    
    private mutating func performPendingBinaryOperation() {
        if pendingBinaryOperation != nil && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: (Double, String)
        let description: (String, String) -> String
        
        func perform(with secondOperand: (Double, String)) -> (Double, String) {
            return (function(firstOperand.0, secondOperand.0), description(firstOperand.1, secondOperand.1))
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = (operand, String(operand.formatNumber()))
    }
    
    var result: Double? {
        get {
            if accumulator != nil {
                return accumulator!.0
            }
            return nil
        }
    }
    
    var resultIsPending: Bool {
        get {
            if pendingBinaryOperation == nil {
                return false
            } else {
                return true
            }
        }
    }
    
    var description: String? {
        get {
            if resultIsPending {
                return pendingBinaryOperation!.description(pendingBinaryOperation!.firstOperand.1, accumulator?.1 ?? String())
            } else {
                return accumulator?.1
            }
        }
    }
    
    mutating func clearEverything() {
        pendingBinaryOperation = nil
        accumulator = nil
    }
}

extension Double {
    func formatNumber() -> String {
        let formatter = NumberFormatter()
        if self.truncatingRemainder(dividingBy: 1) == 0 { //format for integers
            formatter.maximumFractionDigits = 0
        } else {    //format for decimals
            formatter.maximumFractionDigits = 4
            formatter.minimumIntegerDigits = 1
        }
        return formatter.string(from: self as NSNumber)!
    }
}
