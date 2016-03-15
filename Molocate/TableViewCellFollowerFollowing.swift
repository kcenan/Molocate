//
//  TableViewCellFollowerFollowing.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class TableViewCellFollowerFollowing: UITableViewCell {
    
    var myLabel1: UIImageView!
    var myButton1: UIButton!
    var fotoButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
      
        
        let gap : CGFloat = 10
        let labelHeight: CGFloat = 30
        let labelWidth: CGFloat = 140
        
        let mole = UIImage(named: "sound.png")! as UIImage
        fotoButton = UIButton()
        fotoButton.frame = CGRectMake(gap, gap, 40 , 40)
        fotoButton.setBackgroundImage(mole, forState: .Normal)
        contentView.addSubview(fotoButton)
        
        
        //burda widthini stringin genişliğine göre ayarlanacak
        myButton1 = UIButton()
        myButton1.frame = CGRectMake(60, gap, 200 , 40)
        //myButton1.frame.origin.x = 60
        //myButton1.frame.origin.y = gap
        //myButton1.sizeToFit()
        //myButton1.titleLabel!.numberOfLines = 1
        //myButton1.titleLabel!.adjustsFontSizeToFitWidth = true
        myButton1.setTitleColor(UIColor.blackColor(), forState: .Normal)
        myButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        contentView.addSubview(myButton1)
        
        let tick = UIImage(named: "tick.png")! as UIImage
        myLabel1 = UIImageView(image: tick)
        myLabel1.frame = CGRect(x:UIScreen.mainScreen().bounds.width - 40 , y: gap + 5, width: 30, height: 30)
        contentView.addSubview(myLabel1)
        
        
        
        
        
    }
  
    }



