//
//  sideProfilePic.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//
//
//  sideProfilePic.swift
//  Molocate
//
//  Created by Kagan Cenan on 17.05.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//


import UIKit

class sideProfilePic: UITableViewCell {
    
    var profilePhoto: UIImageView!
    var username: UILabel!
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        username = UILabel()
        username.frame = CGRect(x: screenSize.size.width / 14 , y: 40 + screenSize.size.width * 2 / 10 , width: screenSize.size.width * 25.7 / 100  , height: 50)
        username.textColor = UIColor.white
        username.textAlignment = .center
        username.text = "ekinimo"
        username.lineBreakMode = NSLineBreakMode.byCharWrapping
        username.numberOfLines = 2
        username.font = UIFont(name: "AvenirNext-Medium", size:15)
        contentView.addSubview(username)
        
        profilePhoto = UIImageView()
        let image: UIImage = UIImage(named: "profile")!
        profilePhoto = UIImageView(image: image)
        profilePhoto.layer.borderWidth = 0.5
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layoutIfNeeded()
        profilePhoto.layer.borderColor = UIColor.clear.cgColor
        profilePhoto.frame = CGRect (x: screenSize.size.width / 10 , y: 36 , width: screenSize.size.width * 2 / 10 ,  height: screenSize.size.width * 2 / 10)
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        
        
        contentView.addSubview(profilePhoto)
        
    }
    
    
    
}
