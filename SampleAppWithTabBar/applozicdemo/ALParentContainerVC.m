
//
//  ALParentContainerVC.m
//  applozicsample
//
//  Created by devashish on 06/08/2016.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

#import "ALParentContainerVC.h"
@import Applozic;

@interface ALParentContainerVC ()

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property(strong, nonatomic) UIBarButtonItem *barButtonItem;

@end

@implementation ALParentContainerVC

- (void)viewDidLoad {

    [super viewDidLoad];
    
     self.barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self setCustomBackButton:[ALApplozicSettings getTitleForBackButtonMsgVC]]];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.title = [ALApplozicSettings getTitleForConversationScreen];
    [self.navigationItem setLeftBarButtonItem:self.barButtonItem];
    
    NSBundle *bundle = [NSBundle bundleWithIdentifier:@"com.applozic.framework"];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Applozic" bundle:bundle];
    ALMessagesViewController *msgView = (ALMessagesViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"ALViewController"];
    
//    ALNewContactsViewController *contactView = (ALNewContactsViewController *)
//                                [storyBoard instantiateViewControllerWithIdentifier:@"ALNewContactsViewController"];
    
    [self showViewControllerInContainerView: msgView];
}

-(void) showViewControllerInContainerView:(UIViewController *)viewController
{
    for(UIViewController * vc in self.childViewControllers)
    {
        [vc willMoveToParentViewController:nil];
        [vc.view removeFromSuperview];
        [vc removeFromParentViewController];
    }
    
    [self addChildViewController:viewController];
    viewController.view.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    
    NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem : [viewController view]
                                                                         attribute : NSLayoutAttributeLeading
                                                                         relatedBy : NSLayoutRelationEqual
                                                                            toItem : self.containerView
                                                                          attribute: NSLayoutAttributeLeading
                                                                         multiplier: 1
                                                                          constant : 0];
    
    [self.containerView addConstraint:constraintLeading];
    
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem : [viewController view]
                                                                     attribute : NSLayoutAttributeTop
                                                                     relatedBy : NSLayoutRelationEqual
                                                                        toItem : self.containerView
                                                                      attribute: NSLayoutAttributeTop
                                                                     multiplier: 1
                                                                      constant : 0];
    
    [self.containerView addConstraint:constraintTop];
    
    NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem : [viewController view]
                                                                        attribute : NSLayoutAttributeBottom
                                                                        relatedBy : NSLayoutRelationEqual
                                                                           toItem : self.containerView
                                                                         attribute: NSLayoutAttributeBottom
                                                                        multiplier: 1
                                                                         constant : 0];
    
    [self.containerView addConstraint:constraintBottom];
    
    NSLayoutConstraint *constraintTrailing = [NSLayoutConstraint constraintWithItem : [viewController view]
                                                                          attribute : NSLayoutAttributeTrailing
                                                                          relatedBy : NSLayoutRelationEqual
                                                                             toItem : self.containerView
                                                                           attribute: NSLayoutAttributeTrailing
                                                                          multiplier: 1
                                                                           constant : 0];
    
    [self.containerView addConstraint:constraintTrailing];
    
    [self.containerView setNeedsUpdateConstraints];

}

-(UIView *)setCustomBackButton:(NSString *)text
{
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: [ALUtilityClass getImageFromFramworkBundle:@"bbb.png"]];
    [imageView setFrame:CGRectMake(-10, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(imageView.frame.origin.x + imageView.frame.size.width - 5, imageView.frame.origin.y + 5 , 20, 15)];
    [label setTextColor: [ALApplozicSettings getColorForNavigationItem]];
    [label setText:text];
    [label sizeToFit];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, imageView.frame.size.width + label.frame.size.width, imageView.frame.size.height)];
    view.bounds=CGRectMake(view.bounds.origin.x+8, view.bounds.origin.y-1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    
    UITapGestureRecognizer * backTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(back:)];
    backTap.numberOfTapsRequired = 1;
    [view addGestureRecognizer:backTap];
    return view;
    
}

-(void)back:(id)sender {
    
    UIViewController *  uiController = [self.navigationController popViewControllerAnimated:YES];
    
    if(!uiController){
        [self  dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
