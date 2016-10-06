//
//  searchVenue.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.04.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class searchVenue: UITableViewCell {

    let profilePhoto: UIButton = UIButton()
    let usernameLabel: UILabel = UILabel()
    let nameLabel: UILabel = UILabel()
    let followButton: UIButton = UIButton()
    let addressNameLabel: UILabel = UILabel()
    let distanceLabel: UILabel = UILabel()
    
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
        
        

        addressNameLabel.frame = CGRect(x: 10 , y: 26 , width: screenSize.width - 100, height: 14)
        addressNameLabel.textColor = UIColor.gray
        addressNameLabel.textAlignment = .left
        addressNameLabel.text = "-"
        addressNameLabel.font = UIFont(name: "AvenirNext-Regular", size:12)
        contentView.addSubview(addressNameLabel)
        
        
        distanceLabel.frame = CGRect(x: 10 , y: 42 , width: screenSize.width - 100, height: 14)
        distanceLabel.textColor = UIColor.gray
        distanceLabel.textAlignment = .left
        distanceLabel.text = "-"
        distanceLabel.font = UIFont(name: "AvenirNext-Regular", size:11)
        contentView.addSubview(distanceLabel)
    
    }
    
    deinit{
        
        
//        profilePhoto = nil
//        usernameLabel = nil
//        nameLabel = nil
//        followButton = nil
        
        
    }

    
}
