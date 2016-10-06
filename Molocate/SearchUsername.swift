//
//  searchUsername.swift
//  Molocate
//
//  Created by Kagan Cenan on 24.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class searchUsername: UITableViewCell {
    
    let profilePhoto: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let nameLabel: UILabel = UILabel()
    let followButton: UIButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.main.bounds
               profilePhoto.frame = CGRect(x: 10, y: 8 , width: 44, height: 44)
        //let image = UIImage(named: "profile")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        // profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        self.contentView.addSubview(profilePhoto)
        
        usernameLabel.frame = CGRect(x: 66 , y: 8 , width: screenSize.width - 100, height: 25)
        usernameLabel.textColor = UIColor.black
        usernameLabel.textAlignment = .left
        //usernameLabel.text = "@kcenan"
        usernameLabel.font = UIFont(name: "AvenirNext-Regular", size:15)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        self.contentView.addSubview(usernameLabel)
  
        nameLabel.frame = CGRect(x: 66 , y: 27 , width: screenSize.width - 100, height: 22)
        nameLabel.textColor = UIColor.gray
        nameLabel.textAlignment = .left
        //nameLabel.text = "Kağan Cenan"
        nameLabel.font = UIFont(name: "AvenirNext-Regular", size:12)
        self.contentView.addSubview(nameLabel)
        
        //followButton = UIButton()
        followButton.frame = CGRect(x: UIScreen.main.bounds.width - 44 , y: 15 , width: 39, height: 30)
        followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
        self.contentView.addSubview(followButton)
    }
    
    deinit{
        
        
//        profilePhoto = nil
//        usernameLabel = nil
//        nameLabel = nil
//        followButton = nil
        
        
    }
    


    
}
