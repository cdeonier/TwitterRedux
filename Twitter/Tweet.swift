//
//  Tweet.swift
//  Twitter
//
//  Created by Christian Deonier on 2/18/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class Tweet {
    
    var user: User?
    var retweetingUser: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var dictionary: NSDictionary?
    var favorited: Bool?
    var retweetCount: Int?
    var favoriteCount: Int?
    
    init() {
        createdAt = NSDate()
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAtString = formatter.stringFromDate(createdAt!)
        
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
        
        user = User(dictionary: tweetDictionary["user"] as! NSDictionary)
        text = tweetDictionary["text"] as? String
        createdAtString  = tweetDictionary["created_at"] as? String
        favorited = tweetDictionary["favorited"] as? Bool
        retweetCount = tweetDictionary["retweet_count"] as? Int
        favoriteCount = tweetDictionary["favorite_count"] as? Int
        self.dictionary = dictionary as NSDictionary
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        
        return tweets
    }

}
