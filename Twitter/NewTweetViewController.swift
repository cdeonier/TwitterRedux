//
//  NewTweetViewController.swift
//  Twitter
//
//  Created by Christian Deonier on 2/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

protocol NewTweetDelegate {
    func newTweetController(tweet: Tweet)
}

class NewTweetViewController: UIViewController, UITextViewDelegate {
    
    var user: User = User.currentUser!
    var delegate: NewTweetDelegate?
    var replyToTweet: Tweet?

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var characterCounterLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self

        setUpNavigationBar()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Tweet", style: .Plain, target: self, action: "tweet")
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 120/255.0, green: 183/255.0, blue: 234/255.0, alpha: 1.0)
        navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem?.tintColor = UIColor.whiteColor()
    }
    
    func setUpView() {
        usernameLabel.text = user.name
        handleLabel.text = user.screenname
        avatarImageView.setImageWithURL(NSURL(string: user.profileImageUrl!)!)
        
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
        
        if let replyToTweet = replyToTweet {
            tweetTextView.text = "@\((replyToTweet.user?.screenname!)!) "
            textViewDidChange(tweetTextView)
        } else {
            tweetTextView.text = ""
        }

        tweetTextView.becomeFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        let currentCount = textView.text.characters.count
        characterCounterLabel.text = "\(currentCount)/140"
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText string: String) -> Bool {
        guard let text = textView.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
        return newLength <= 140
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tweet() {
        let tweet = Tweet()
        let tweetText = tweetTextView.text
        tweet.text = tweetText
        tweet.user = user
        
        delegate?.newTweetController(tweet)
        
        print(tweetText)
    }
    
    func makeTweet(tweetText: String) {
        let tweet = Tweet()
        tweet.user = user
        tweet.text = tweetText
        tweet.createdAt = NSDate()
        
        
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
