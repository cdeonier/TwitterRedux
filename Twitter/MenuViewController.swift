//
//  MenuViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/24/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var hamburgerViewController: HamburgerViewController?
    var viewControllers: [UINavigationController] = []
    
    var profileViewController: UINavigationController?
    var timelineViewController: UINavigationController?
    var mentionsViewController: UINavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        populateViewControllers()
        
        hamburgerViewController?.contentViewController = profileViewController

        // Do any additional setup after loading the view.
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func populateViewControllers() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        profileViewController = UINavigationController(rootViewController: storyboard.instantiateViewControllerWithIdentifier("ProfileViewController"))
        timelineViewController = UINavigationController(rootViewController: storyboard.instantiateViewControllerWithIdentifier("TweetsViewController"))
        mentionsViewController = UINavigationController(rootViewController: storyboard.instantiateViewControllerWithIdentifier("TweetsViewController"))
        
        var vc = mentionsViewController?.viewControllers.first as! TweetsViewController
        vc.isHomeTimeline = false
        vc.hamburgerViewController = hamburgerViewController
        
        vc = timelineViewController?.viewControllers.first as! TweetsViewController
        vc.isHomeTimeline = true
        vc.hamburgerViewController = hamburgerViewController
        
        viewControllers.append(profileViewController!)
        viewControllers.append(timelineViewController!)
        viewControllers.append(mentionsViewController!)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        hamburgerViewController?.contentViewController = self.viewControllers[indexPath.row]
    }
    
    func configureCell(cell: MenuCell, forRowAtIndexPath: NSIndexPath) {
        switch forRowAtIndexPath.row {
        case 0:
            cell.menuItemTitle.text = "Profile"
        case 1:
            cell.menuItemTitle.text = "Timeline"
        case 2:
            cell.menuItemTitle.text = "Mentions"
        default:
            print("Unexpected view controller")
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
