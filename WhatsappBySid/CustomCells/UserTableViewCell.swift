//
//  UserTableViewCell.swift
//  WhatsappBySid
//
//  Created by mac on 23/04/20.
//  Copyright © 2020 mac. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var indexPath: IndexPath!
    
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGestureRecognizer)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func  generateCellWith(fUser: FUser, indexpath: IndexPath) {
        self.indexPath = indexpath
        self.fullNameLabel.text = fUser.fullname
        if fUser.avatar != "" {
            imageFromData(pictureData: fUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
       }
    }
    
    @objc func avatarTap(){
        print("avatar tap at \(indexPath)")
    }
}
