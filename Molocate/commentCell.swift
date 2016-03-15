//
//  commentCell.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentCell: UITableViewCell {

    var screenSize = UIScreen.mainScreen().bounds
    
      var commentUser: UIButton!
      var profileImage:  UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")}
    
    
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

        commentUser = UIButton()
        commentUser.frame = CGRectMake(50 ,4, screenSize.width - 50 , 16)
        //commentUser.setBackgroundImage(mole, forState: .Normal)
        commentUser.setTitleColor(swiftColor , forState: UIControlState.Normal)
        commentUser.setTitle("ddasasdd", forState: .Normal)
        commentUser.titleLabel!.font =  UIFont(name: "Late-Light.tff", size: 10)
        commentUser.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        contentView.addSubview(commentUser)
        
        let image = UIImage(named: "change.png") as UIImage?
        profileImage = UIButton()
        profileImage.frame = CGRectMake(4 ,4, 36 , 36)
        profileImage.setBackgroundImage(image, forState: .Normal)
        profileImage.titleLabel?.textColor = swiftColor
        //profileImage.titleLabel?.text = "dsalkaasl"
        contentView.addSubview(profileImage)
    }
    
    
    
    
        
    
}
