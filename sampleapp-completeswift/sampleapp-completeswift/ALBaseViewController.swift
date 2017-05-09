//
//  ALBaseViewController.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 05/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit

class ALBaseViewController: UIViewController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        NSLog("🐸 \(#function) 🍀🍀 \(self) 🐥🐥🐥🐥")
        self.addObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.navigationController?.viewControllers.first != self {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "icon_back"), style: .plain, target: self , action: #selector(backTapped))
        }
    }
    
    func backTapped() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSLog("🐸 \(#function) 🍀🍀 \(self) 🐥🐥🐥🐥")
        self.addObserver()
    }
    
    func addObserver() {
        
    }
    
    func removeObserver() {
        
    }
    
    deinit {
        
        removeObserver()
        NSLog("💩 \(#function) ❌❌ \(self)‼️‼️‼️‼️")
    }
    
}
