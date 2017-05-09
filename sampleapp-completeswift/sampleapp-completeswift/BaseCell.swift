//
//  BaseCell.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 08/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit

class BaseCell<T>: UITableViewCell {
    
    var viewModel: T?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupStyle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        
    }
    
    func setupStyle(){
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    func update(viewModel: T) {
        self.viewModel = viewModel
    }
    
    class func rowHeigh(viewModel: T,width: CGFloat) -> CGFloat {
        return 44
    }
    
}
