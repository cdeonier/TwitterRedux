//
//  TwitterClient.swift
//  Twitter
//
//  Created by Christian Deonier on 2/15/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import BDBOAuth1Manager

let twitterBaseUrl = "https://api.twitter.com"
let apiKey = "TycApvGIHMDJjLhHFKPmuhV8c"
let apiSecret = "esAKjMPWVkYpinbhhR9ZdfEt3djSMPlcmQWtXmWj53QUVzAkhN"

class TwitterClient : BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static  {
            static let instance = TwitterClient(baseURL: NSURL(string: twitterBaseUrl), consumerKey: apiKey, consumerSecret: apiSecret)
        }
        
        return Static.instance!
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                completion(tweets: nil, error: error)
        }
    }
    
    func logInWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        self.loginCompletion = completion
        
        requestSerializer.removeAccessToken()
        fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "cptwitterdemo://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            print(requestToken.token)
            let authUrl = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)"
            UIApplication.sharedApplication().openURL(NSURL(string: authUrl)!)
        }) { (error: NSError!) -> Void in
            NSLog("Error requesting token")
        }
    }
    
    func postTweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let params = NSMutableDictionary()
        params["status"] = tweet.text
        if let replyToTweetId = tweet.replyToTweetId {
            params["in_reply_to_status_id"] = replyToTweetId
        }
        
        POST("1.1/statuses/update.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                NSLog("Error posting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func retweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/retweet/\(tweet.id!).json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            print(response["retweet_count"])
            tweet.retweeted = true
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                NSLog("Error posting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func unretweet(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        POST("1.1/statuses/unretweet/\(tweet.id!).json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            print(response["retweet_count"])
            tweet.retweeted = false
            tweet.retweetCount = tweet.retweetCount! - 1
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                NSLog("Error posting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func favorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let params = NSDictionary(dictionary: ["id": tweet.id!])
        POST("1.1/favorites/create.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            tweet.favorited = true
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                NSLog("Error favoriting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func unfavorite(tweet: Tweet, completion: (tweet: Tweet?, error: NSError?) -> ()) {
        let params = NSDictionary(dictionary: ["id": tweet.id!])
        POST("1.1/favorites/destroy.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            tweet.favorited = false
            completion(tweet: tweet, error: nil)
            }) { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                NSLog("Error unfavoriting tweet")
                completion(tweet: nil, error: error)
        }
    }
    
    func getAccessToken(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (credential: BDBOAuth1Credential!) -> Void in
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(credential)
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: AnyObject) -> Void in
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                self.loginCompletion?(user: user, error: nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError) -> Void in
                    self.loginCompletion?(user: nil, error: error)
            })
            
            }) { (error: NSError!) -> Void in
                print("Got an error")
        }
    }

}
