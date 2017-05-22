//
//  DateSectionHeaderView.swift
//  Axiata
//
//  Created by Atikom Tancharoen on 3/8/2560 BE.
//  Copyright © 2560 Appsynth. All rights reserved.
//

import UIKit

class DateSectionHeaderView: UIView {

    // MARK: - Variables and Types
    // MARK: ChatDate
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var dateView: UIView! {
        didSet {
            dateView.layer.cornerRadius = dateView.frame.size.height / 2.0
        }
    }
    
    // MARK: - Lifecycle
    class func instanceFromNib() -> DateSectionHeaderView {
        guard let view = UINib(nibName: DateSectionHeaderView.nibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as? DateSectionHeaderView else {
            fatalError("\(DateSectionHeaderView.nibName) don't existing")
        }
        
        return view
    }
    
    // MARK: - Methods of class
    // MARK: ChatDate
    func setupDate(withDateFormat date: String) {
        self.dateLabel.text = date
    }

}
