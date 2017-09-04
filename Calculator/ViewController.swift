//
//  ViewController.swift
//  Calculator
//
//  Created by anna on 30.06.17.
//  Copyright © 2017 anna. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var operationsLabel: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    private let initialDisplayValue: String = "0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(named: "✅") { [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt($0)
        }
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit == "." && textCurrentlyInDisplay.contains(".") {
                return
            }
            display.text = textCurrentlyInDisplay + digit
        } else {
            if digit == "." {
                display.text = initialDisplayValue + digit
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = newValue.formatNumber()
        }
    }

    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            if let description = brain.description {
                operationsLabel.text = description + "..."
            }
        }
        if let result = brain.result {
            displayValue = result
            if let description = brain.description {
                operationsLabel.text = description + "="
            }
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        brain.clearEverything()
        userIsInTheMiddleOfTyping = false
        display.text = initialDisplayValue
        operationsLabel.text = display.text
    }
    
    @IBAction func deleteDigit(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            display.text?.remove(at: display.text!.index(before:display.text!.endIndex))
            if display.text!.isEmpty {
                userIsInTheMiddleOfTyping = false
                display.text = initialDisplayValue
            }
        }
    }
}

