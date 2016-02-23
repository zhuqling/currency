//
//  ViewController.swift
//  Currency
//
//  Created by Nuno Coelho Santos on 11/02/2016.
//  Copyright © 2016 Nuno Coelho Santos. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var input = ""
    var inputCurrency = "ja_JP"
    var outputCurrency = "gb_GB"
    var exchangeRate = 0.0061

    @IBOutlet weak var inputCurrencyLabel: UILabel!
    @IBOutlet weak var outputCurrencyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Change status bar color.
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    @IBAction func digitPressed(sender: UIButton) {
        guard let digit = sender.titleLabel?.text else {
            print("Error setting digit value.")
            return
        }
        input = input + digit
        inputCurrencyLabel.text = convertToCurrency(Double(input)!, currency: inputCurrency)
        outputCurrencyLabel.text = convertToCurrency(Double(input)! * exchangeRate, currency: outputCurrency)
    }

    @IBAction func clearPressed(sender: AnyObject) {
        input = "0"
        inputCurrencyLabel.text = "¥0"
        outputCurrencyLabel.text = "£0"
    }
    
    func convertToCurrency(price: Double, currency: String) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        formatter.locale = NSLocale(localeIdentifier: currency)
        formatter.usesGroupingSeparator = true;
        formatter.groupingSeparator = ","
        let formattedPriceString = formatter.stringFromNumber(price)
        return formattedPriceString!
    }
    
}

