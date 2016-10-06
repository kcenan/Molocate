//
//  venueInCamera.swift
//  Molocate
//
//  Created by Kagan Cenan on 9.06.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class venueInCamera: UITableViewCell {
    
    let profilePhoto: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let nameLabel: UILabel = UILabel()
    let followButton: UIButton = UIButton()
    let addressNameLabel: UILabel = UILabel()
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize = MolocateDevice.size
        
        
        nameLabel.frame = CGRect(x: 10 , y: 4 , width: screenSize.width - 100, height: 20)
        nameLabel.textColor = UIColor.black
        nameLabel.textAlignment = .left
        nameLabel.text = ""
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:15)
        contentView.addSubview(nameLabel)
        
        
        
        addressNameLabel.frame = CGRect(x: 10 , y: 26 , width: screenSize.width - 20, height: 14)
        addressNameLabel.textColor = UIColor.gray
        addressNameLabel.textAlignment = .left
        addressNameLabel.text = "-"
        addressNameLabel.font = UIFont(name: "AvenirNext-Regular", size:12)
        contentView.addSubview(addressNameLabel)
        
        
        
    }
    
    deinit{
        
        
        //        profilePhoto = nil
        //        usernameLabel = nil
        //        nameLabel = nil
        //        followButton = nil
        
        
}
}
