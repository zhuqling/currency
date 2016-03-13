//
//  CalculatorResultButton.swift
//  Currency
//
//  Created by Nuno Coelho Santos on 13/03/2016.
//  Copyright © 2016 Nuno Coelho Santos. All rights reserved.
//

import Foundation
import UIKit

class CalculatorResultButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.setBackgroundImage(UIImage(named: "buttonResultBackground.png"), forState: .Highlighted)
        self.setImage(UIImage(named: "buttonResultIconHighlighted.png"), forState: .Highlighted)
    }
    
}