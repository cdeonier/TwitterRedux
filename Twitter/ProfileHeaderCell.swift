//
//  ProfileHeaderCell.swift
//  Twitter
//
//  Created by Christian Deonier on 2/28/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class ProfileHeaderCell: UITableViewCell {

    @IBOutlet weak var avatarImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userHandle: UILabel!
    @IBOutlet weak var numberTweets: UILabel!
    @IBOutlet weak var numberFollowing: UILabel!
    @IBOutlet weak var numberFollowers: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
