//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

protocol TweetDelegate {
    func tweetDetailViewController(tweet: Tweet)
    func tweetDetailViewController(tweet: Tweet, replyTweet: Tweet)
}

class TweetDetailViewController: UIViewController, NewTweetDelegate {
    
    var tweet: Tweet?
    var delegate: TweetDelegate?
    var replyToTweet: Tweet?

    @IBOutlet weak var retweetIndicator: UIImageView!
    @IBOutlet weak var retweetAuthor: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var numberRetweetsLabel: UILabel!
    @IBOutlet weak var numberFavoritesLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var retweetIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var retweetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Home", style: .Plain, target: self, action: "returnToHome")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reply", style: .Plain, target: self, action: "reply")
        navigationItem.title = "Tweet"
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 120/255.0, green: 183/255.0, blue: 234/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
    }
    
    func setUpView() {
        if let tweet = tweet {
            nameLabel.text = tweet.user!.name
            handleLabel.text = "@\(tweet.user!.screenname!)"
            tweetLabel.text = tweet.text
            timestampLabel.text = tweet.createdAtDisplay
            avatarImage.setImageWithURL(NSURL(string: (tweet.user?.profileImageUrl)!)!)
            numberRetweetsLabel.text = "\(tweet.retweetCount!)"
            numberFavoritesLabel.text = "\(tweet.favoriteCount!)"
            
            if tweet.retweetingUser == nil {
                retweetIndicatorHeightConstraint.constant = 0
                retweetAuthor.hidden = true
            } else {
                retweetAuthor.text = tweet.retweetingUser?.name!
            }
            
            avatarImage.layer.cornerRadius = 5
            avatarImage.clipsToBounds = true
            
            retweetButton.selected = tweet.retweeted!
            favoriteButton.selected = tweet.favorited!
        }
    }
    
    func returnToHome() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func newTweetController(tweet: Tweet) {
        delegate?.tweetDetailViewController(self.tweet!, replyTweet: tweet)
    }
    
    @IBAction func reply(sender: AnyObject) {
        self.performSegueWithIdentifier("replyTweet", sender: self)
    }

    @IBAction func retweet(sender: AnyObject) {
        let didRetweet = !retweetButton.selected
        
        if didRetweet {
            tweet!.retweet({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.retweetButton.selected = true
                    self.numberRetweetsLabel.text = "\(tweet.retweetCount!)"
                    self.delegate?.tweetDetailViewController(tweet)
                } else {
                    print(error?.description)
                }
            })
        } else {
            tweet!.unretweet({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.retweetButton.selected = false
                    self.numberRetweetsLabel.text = "\(tweet.retweetCount!)"
                    self.delegate?.tweetDetailViewController(tweet)
                } else {
                    print(error?.description)
                }
            })
        }
    }
    
    @IBAction func favorite(sender: AnyObject) {
        let didFavorite = !favoriteButton.selected
        
        if didFavorite {
            tweet!.favorite({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.favoriteButton.selected = true
                    self.numberFavoritesLabel.text = "\(tweet.favoriteCount!)"
                    self.delegate?.tweetDetailViewController(tweet)
                } else {
                    print(error?.description)
                }
            })
        } else {
            tweet!.unfavorite({ (tweet, error) -> () in
                if let tweet = tweet {
                    self.favoriteButton.selected = false
                    self.numberFavoritesLabel.text = "\(tweet.favoriteCount!)"
                    self.delegate?.tweetDetailViewController(tweet)
                } else {
                    print(error?.description)
                }
            })
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "replyTweet" {
            let navController = segue.destinationViewController as! UINavigationController
            let vc = navController.topViewController as! NewTweetViewController
            vc.delegate = self
            vc.replyToTweet = tweet
        }
    }
}
