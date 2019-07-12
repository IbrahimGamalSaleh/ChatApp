//
//  CustomMessageCell.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/9/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    
    @IBOutlet var messageBackground: UIView!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var senderUsername: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
