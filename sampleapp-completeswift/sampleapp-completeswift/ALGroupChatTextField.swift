//
//  AXGroupChatTextField.swift
//  Axiata
//
//  Created by appsynth on 1/29/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import UIKit

final class ALGroupChatTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds)
        return bounds.insetBy(dx: 14, dy: 9);
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 14, dy: 9)
    }
}
