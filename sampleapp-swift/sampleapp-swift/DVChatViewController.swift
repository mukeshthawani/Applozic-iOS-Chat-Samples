//
//  DVChatViewController.swift
//  sampleapp-swift
//
//  Created by Divjyot Singh on 15/04/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

import UIKit

class DVChatViewController: UIViewController {
 
    @IBOutlet weak var containerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        setTabBarNavigationTitle("Chat")
        
        let frameworkBundle = NSBundle(identifier:"com.applozic.framework")
        let storyboard = UIStoryboard(name: "Applozic", bundle: frameworkBundle)
        let chatController = storyboard.instantiateViewControllerWithIdentifier("ALViewController")
        showViewControllerInContainerView(chatController)
//        showViewController(chatController, sender: self)
    }
    
    private func showViewControllerInContainerView(viewController: UIViewController){
        
        for vc in self.childViewControllers{
            
            vc.willMoveToParentViewController(nil)
            vc.view.removeFromSuperview()
            vc.removeFromParentViewController()
        }
        self.addChildViewController(viewController)
        viewController.view.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        containerView.addSubview(viewController.view)
        viewController.didMoveToParentViewController(self)
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0 ) );
        containerView.addConstraint( NSLayoutConstraint(item: viewController.view,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: containerView,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1,
            constant: 0 ) );
        
        containerView.setNeedsUpdateConstraints();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
