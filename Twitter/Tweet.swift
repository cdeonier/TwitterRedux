//
//  Tweet.swift
//  Twitter
//
//  Created by Christian Deonier on 2/18/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class Tweet {
    
    var id: Int?
    var user: User?
    var retweetingUser: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var createdAtDisplay: String?
    var dictionary: NSDictionary?
    var favorited: Bool?
    var retweetCount: Int?
    var favoriteCount: Int?
    var replyToTweetId: Int?
    var retweeted: Bool?
    
    init() {
        createdAt = NSDate()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAtString = formatter.stringFromDate(createdAt!)
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        createdAtDisplay = formatter.stringFromDate(createdAt!)
        
        favoriteCount = 0
        retweetCount = 0
        favorited = false
    }
    
    init(dictionary: NSDictionary) {
        var tweetDictionary: NSDictionary
        if dictionary["retweeted_status"] != nil {
            retweetingUser = User(dictionary: dictionary["user"] as! NSDictionary)
            tweetDictionary = dictionary["retweeted_status"] as! NSDictionary
        } else {
            tweetDictionary = dictionary
        }
        
        id = tweetDictionary["id"] as? Int
        user = User(dictionary: tweetDictionary["user"] as! NSDictionary)
        text = tweetDictionary["text"] as? String
        createdAtString  = tweetDictionary["created_at"] as? String
        favorited = tweetDictionary["favorited"] as? Bool
        retweetCount = tweetDictionary["retweet_count"] as? Int
        favoriteCount = tweetDictionary["favorite_count"] as? Int
        retweeted = tweetDictionary["retweeted"] as? Bool
        replyToTweetId = tweetDictionary["in_reply_to_status_id_str"] as? Int
        self.dictionary = dictionary as NSDictionary
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        createdAtDisplay = formatter.stringFromDate(createdAt!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }
    
    class func indexForTweetInArray(tweet: Tweet, array: [Tweet]) -> Int? {
        for (index, possibleTweet) in array.enumerate() {
            if possibleTweet.id == tweet.id {
                return index
            }
        }
        return nil
    }
    
    class func mergeTweets(originalTweets: [Tweet], additionalTweets: [Tweet]) -> [Tweet] {
        var combinedTweets: [Tweet] = originalTweets
        for additionalTweet in additionalTweets {
            if !originalTweets.contains({ $0.id == additionalTweet.id }) {
                combinedTweets.append(additionalTweet)
            }
        }
        return combinedTweets
    }
    
    func tweet(completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.postTweet(self, completion: completion)
    }
    
    func retweet(completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.retweet(self, completion: completion)
    }
    
    func unretweet(completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.unretweet(self, completion: completion)
    }
    
    func favorite(completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.favorite(self, completion: completion)
    }
    
    func unfavorite(completion: (tweet: Tweet?, error: NSError?) -> ()) {
        TwitterClient.sharedInstance.unfavorite(self, completion: completion)
    }
}
