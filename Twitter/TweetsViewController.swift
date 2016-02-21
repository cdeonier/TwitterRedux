//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NewTweetDelegate, TweetDelegate, TweetCellDelegate {
    
    var tweets: [Tweet]?
    var replyToTweet: Tweet?
    var refreshControl: UIRefreshControl?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTableView()
        setUpRefreshControl()
        setUpNavigationBar()
        
        getTweets()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: "signOut")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New", style: .Plain, target: self, action: "newTweet")
        navigationItem.title = "Home"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 120/255.0, green: 183/255.0, blue: 234/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func setUpRefreshControl() {
        refreshControl = UIRefreshControl()
        let action: Selector = "getTweets"
        refreshControl!.addTarget(self, action: action, forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl!, atIndex: 0)
    }
    
    func getTweets() {
        TwitterClient.sharedInstance.homeTimelineWithParams(nil) { (tweets: [Tweet]?, error: NSError?) -> () in
            if let error = error {
                print(error)
            } else {
                self.tweets = tweets
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }

    func signOut() {
        User.currentUser?.logOut()
    }
    
    func newTweet() {
        self.performSegueWithIdentifier("newTweet", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        configureCell(cell, forRowAtIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: TweetCell, forRowAtIndexPath: NSIndexPath) {
        let tweet = tweets?[forRowAtIndexPath.row]
        if let tweet = tweet {
            cell.tweetLabel.text = tweet.text
            cell.usernameLabel.text = tweet.user?.name
            cell.handleLabel.text = tweet.user?.screenname
            cell.avatarImageView.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            
            if let retweetingUser = tweet.retweetingUser {
                cell.retweetIndicator.hidden = false
                cell.retweetIndicatorHeightConstraint.constant = 18.0
                cell.retweetAuthor.hidden = false
                
                cell.retweetAuthor.text = retweetingUser.name
            } else {
                cell.retweetIndicatorHeightConstraint.constant = 0
                cell.retweetAuthor.hidden = true
                cell.retweetIndicator.hidden = true
            }
            
            cell.retweetButton.selected = tweet.retweeted!
            cell.favoriteButton.selected = tweet.favorited!
            
            setTimeOfCell(cell, tweet: tweet)
            
            cell.delegate = self
        }
    }
    
    func setTimeOfCell(cell: TweetCell, tweet: Tweet) {
        let currentTime = NSDate()
        let difference = currentTime.timeIntervalSinceDate(tweet.createdAt!)
        
        let interval = Int(difference)
        
        if interval / 86400 > 0 {
            let days = interval / 86400
            cell.timeElapsedLabel.text = "\(days)d"
        } else if interval / 3600 > 0 {
            let hours = (interval / 3600)
            cell.timeElapsedLabel.text = "\(hours)h"
        } else if (interval / 60) % 60 > 0 {
            let minutes = (interval / 60) % 60
            cell.timeElapsedLabel.text = "\(minutes)"
        } else {
            let seconds = interval % 60
            cell.timeElapsedLabel.text = "\(seconds)s"
        }
    }
    
    func tweetCell(tweetCell: TweetCell, didFavorite: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        let tweet = tweets![indexPath!.row]
        tweet.favorited = didFavorite
        if didFavorite! {
            tweet.favorite({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.refreshTweet(tweet)
                } else {
                    print(error?.description)
                }
            })
        } else {
            tweet.unfavorite({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.refreshTweet(tweet)
                } else {
                    print(error?.description)
                }
            })
        }
    }
    
    func tweetCell(tweetCell: TweetCell, didRetweet: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        let tweet = tweets![indexPath!.row]
        tweet.retweeted = didRetweet
        if didRetweet! {
            tweet.retweet({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.refreshTweet(tweet)
                } else {
                    print(error?.description)
                }
            })
        } else {
            tweet.unretweet({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.refreshTweet(tweet)
                } else {
                    print(error?.description)
                }
            })
        }
    }
    
    func tweetCell(tweetCell: TweetCell, didReply: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        replyToTweet = tweets![indexPath!.row]
        self.performSegueWithIdentifier("newTweet", sender: self)
    }
    
    func newTweetController(tweet: Tweet) {
        print("adding tweet" + tweet.text!)
    }
    
    func tweetDetailViewController(tweet: Tweet) {
        refreshTweet(tweet)
    }
    
    func tweetDetailViewController(tweet: Tweet, replyTweet: Tweet) {

        
        
    }
    
    func refreshTweet(tweet: Tweet) {
        let index = Tweet.indexForTweetInArray(tweet, array: tweets!)
        if let index = index {
            tweets![index] = tweet
            tableView.reloadData()
        }
    }
    
    func insertNewTweet(tweet: Tweet) {
        tweets!.insert(tweet, atIndex: 0)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "newTweet") {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.topViewController as! NewTweetViewController
            vc.delegate = self
            
            if let replyToTweet = replyToTweet {
                vc.replyToTweet = replyToTweet
                self.replyToTweet = nil
            }
        } else if (segue.identifier == "tweetDetails") {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.topViewController as! TweetDetailViewController
            vc.delegate = self
            
            let cell = sender as! UITableViewCell
            let index = tableView.indexPathForCell(cell)
            let tweet = tweets![index!.row]
            vc.tweet = tweet
        }
    }
}
