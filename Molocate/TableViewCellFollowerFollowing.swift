//
//  TableViewCellFollowerFollowing.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class TableViewCellFollowerFollowing: UITableViewCell {
    
    let myLabel1: UIButton = UIButton()
    let myButton1: UIButton = UIButton()
    let fotoButton: UIButton = UIButton()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        let gap : CGFloat = 10
       // fotoButton = UIButton()
        fotoButton.frame = CGRect(x: gap, y: gap, width: 40 , height: 40)
        fotoButton.layer.borderWidth = 0.1
        fotoButton.layer.masksToBounds = false
        fotoButton.layer.borderColor = UIColor.lightGray.cgColor
        fotoButton.backgroundColor = profileBackgroundColor
        fotoButton.layer.cornerRadius = fotoButton.frame.height/2
        fotoButton.clipsToBounds = true
        contentView.addSubview(fotoButton)
        
        //myButton1 = UIButton()
        myButton1.frame = CGRect(x: 60, y: gap, width: 200 , height: 40)
        myButton1.setTitleColor(UIColor.black, for: UIControlState())
        myButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.left
        contentView.addSubview(myButton1)
   
        //myLabel1 = UIButton()
        myLabel1.frame = CGRect(x: UIScreen.main.bounds.width - 37 , y: 9, width: 39, height: 30)
        myLabel1.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
        myLabel1.isHidden = true
        myLabel1.isEnabled = false
        contentView.addSubview(myLabel1)
    }
  
    deinit{
//        fotoButton = nil
//        myButton1 = nil
//        myButton1 = nil
    }
}


