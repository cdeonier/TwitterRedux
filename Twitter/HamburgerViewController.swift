//
//  HamburgerViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/24/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var leftMarginConstraint: NSLayoutConstraint!
    
    var originalLeftMargin: CGFloat?
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuViewController.view.frame = menuView.frame
            menuView.addSubview(menuViewController.view)
        }
    }
    var contentViewController: UINavigationController! {
        didSet(oldContentViewController) {
            if oldContentViewController != nil {
                oldContentViewController.willMoveToParentViewController(nil)
                oldContentViewController.view.removeFromSuperview()
                oldContentViewController.didMoveToParentViewController(nil)
            }
            
            contentViewController.willMoveToParentViewController(self)
            contentView.addSubview(contentViewController.view)
            contentViewController.didMoveToParentViewController(self)
            
            UIView.animateWithDuration(0.3) { () -> Void in
                self.leftMarginConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
            
            if (contentViewController.viewControllers.first is TweetsViewController) {
                let vc = contentViewController.viewControllers.first as! TweetsViewController
                if (vc.isHomeTimeline) {
                    setUpHomeNavigationBar()
                } else {
                    setUpMentionsNavigationBar()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //setUpHomeNavigationBar()
    }
    
    func setUpHomeNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "signOut")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newTweet")
        navigationItem.title = "Home"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 120/255.0, green: 183/255.0, blue: 234/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func setUpMentionsNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "signOut")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newTweet")
        navigationItem.title = "Mentions"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 120/255.0, green: 183/255.0, blue: 234/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onPanGesture(sender: UIPanGestureRecognizer) {
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            originalLeftMargin = leftMarginConstraint.constant
        } else if sender.state == UIGestureRecognizerState.Changed {
            if (translation.x > 0) {
                leftMarginConstraint?.constant = originalLeftMargin! + translation.x
            }
        } else if sender.state == UIGestureRecognizerState.Ended {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                if velocity.x > 0 {
                    self.leftMarginConstraint.constant = self.view.frame.size.width - 50
                } else {
                    self.leftMarginConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            })
        }
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
