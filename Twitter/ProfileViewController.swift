//
//  ProfileViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/24/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TweetCellDelegate, NewTweetDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var user: User?
    var userTweets: [Tweet]?
    var replyToTweet: Tweet?
    var hamburgerViewController: HamburgerViewController?
    var headerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if user == nil {
            user = User.currentUser
        }
        
        setUpTableView()
        getTweets()
    }
    
    func getTweets() {
        TwitterClient.sharedInstance.userTimeline(user!) { (tweets: [Tweet]?, error: NSError?) -> () in
            if let error = error {
                print(error)
            } else {
                self.userTweets = tweets
                self.tableView.reloadData()
            }
        }
    }

    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 160
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier("Header") as! ProfileHeaderCell
        
        if let user = user {
            header.avatarImage.setImageWithURL(NSURL(string: (user.profileImageUrl!))!)
            header.userName.text = user.name!
            header.userHandle.text = "@\(user.screenname!)"
            header.numberFollowing.text = "\(user.numberFollowing!)"
            header.numberFollowers.text = "\(user.numberOfFollowers!)"
            header.numberTweets.text = "\(user.numberOfTweets!)"
        }
        
        return header
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 199
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let userTweets = userTweets {
            return userTweets.count
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
        let tweet = userTweets?[forRowAtIndexPath.row]
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
    
    func tweetCell(tweetCell: TweetCell, didReply: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        replyToTweet = userTweets![indexPath!.row]
        self.performSegueWithIdentifier("newTweet", sender: self)
    }
    
    func tweetCell(tweetCell: TweetCell, didTapAvatar: Bool?) {
    }
    
    func tweetCell(tweetCell: TweetCell, didRetweet: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        let tweet = userTweets![indexPath!.row]
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
    
    func tweetCell(tweetCell: TweetCell, didFavorite: Bool?) {
        let indexPath = tableView.indexPathForCell(tweetCell)
        let tweet = userTweets![indexPath!.row]
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
    
    func refreshTweet(tweet: Tweet) {
        let index = Tweet.indexForTweetInArray(tweet, array: userTweets!)
        if let index = index {
            userTweets![index] = tweet
            tableView.reloadData()
        }
    }
    
    func newTweetController(tweet: Tweet) {
        insertNewTweet(tweet)
    }
    
    func insertNewTweet(tweet: Tweet) {
        userTweets!.insert(tweet, atIndex: 0)
        tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "newTweet") {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.topViewController as! NewTweetViewController
            vc.delegate = self
            
            if let replyToTweet = replyToTweet {
                vc.replyToTweet = replyToTweet
                self.replyToTweet = nil
            }
        }
    }


}
