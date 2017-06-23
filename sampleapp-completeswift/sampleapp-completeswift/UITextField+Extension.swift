//
//  UITextField+Extension.swift
//  Axiata
//
//  Created by appsynth on 1/30/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation

extension UITextField {

    func trimmedWhitespaceText() -> String {
        if let text = self.text {
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
}
