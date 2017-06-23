//
//  UIAlertController+Extension.swift
//  Axiata
//
//  Created by appsynth on 3/7/17.
//  Copyright © 2017 Appsynth. All rights reserved.
//

import Foundation

extension UIAlertController {
    
    static func makeCancelDiscardAlert(title: String, message: String, discardAction: @escaping ()->()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: SystemMessage.ButtonName.Cancel, style: .cancel, handler: nil)
        let discardButton = UIAlertAction(title: SystemMessage.ButtonName.Discard,
                                          style: .destructive,
                                          handler: { (alert) in
                                            discardAction()
        })
        alert.addAction(cancelButton)
        alert.addAction(discardButton)
        return alert
    }
    
    static func presentDiscardAlert(onPresenter presenter: UIViewController, onlyForCondition condition: () -> Bool, lastAction: @escaping () -> ()) {
        if (condition()) {
                let alert = makeCancelDiscardAlert(title: AlertInformation.discardChange.title,
                                                   message: AlertInformation.discardChange.message,
                                                   discardAction: {
                                                    lastAction()
                })
            presenter.present(alert, animated: true, completion: nil)
        } else {
            lastAction()
        }
    }
}
