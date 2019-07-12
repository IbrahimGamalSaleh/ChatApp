//
//  MessagPhotoViewCell.swift
//  ChatApp
//
//  Created by IbrahimGamal on 7/9/19.
//  Copyright © 2019 IbrahimGamal. All rights reserved.
//

import UIKit

class MessagPhotoViewCell: UITableViewCell {

    @IBOutlet weak var userPhoto: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var messagePhoto: UIImageView!
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
