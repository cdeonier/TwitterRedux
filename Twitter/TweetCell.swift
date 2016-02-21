//
//  TweetCell.swift
//  Twitter
//
//  Created by Christian Deonier on 2/19/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

protocol TweetCellDelegate {
    func tweetCell(tweetCell: TweetCell, didReply: Bool?)
    func tweetCell(tweetCell: TweetCell, didRetweet: Bool?)
    func tweetCell(tweetCell: TweetCell, didFavorite: Bool?)
}

class TweetCell: UITableViewCell {
    
    var delegate: TweetCellDelegate?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var retweetIndicator: UIImageView!
    @IBOutlet weak var retweetAuthor: UILabel!
    @IBOutlet weak var retweetIndicatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.clipsToBounds = true
        
        self.selectionStyle = UITableViewCellSelectionStyle.None
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onReply(sender: UIButton) {
        delegate?.tweetCell(self, didReply: true)
    }
    
    @IBAction func onRetweet(sender: UIButton) {
        if retweetButton.selected {
            delegate?.tweetCell(self, didRetweet: false)
        } else {
            delegate?.tweetCell(self, didRetweet: true)
        }
    }
    
    @IBAction func onFavorite(sender: UIButton) {
        if favoriteButton.selected {
            delegate?.tweetCell(self, didFavorite: false)
        } else {
            delegate?.tweetCell(self, didFavorite: true)
        }
    }
    
}
