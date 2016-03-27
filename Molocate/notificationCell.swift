//
//  notificationCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 21.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class notificationCell: UITableViewCell {
    var fotoButton: UIButton!
    var myLabel: UILabel!
    var myButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        
        
        fotoButton = UIButton()
        fotoButton.frame = CGRectMake(5 , 10 , 34 , 34)
        let reportImage = UIImage(named: "elmander.jpg")! as UIImage
        fotoButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        contentView.addSubview(fotoButton)
        
        myButton = UIButton()
        myButton.titleLabel?.numberOfLines = 1
        myButton.setTitle("amertturker123456789", forState: .Normal)
        myButton.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:14)
        let buttonWidth = myButton.intrinsicContentSize().width
        myButton.frame = CGRectMake(44 , 10 , buttonWidth + 5  , 34)
        myButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        myButton.contentHorizontalAlignment = .Left
        myButton.setTitleColor(swiftColor, forState: UIControlState.Normal)
        contentView.addSubview(myButton)
        
        myLabel = UILabel()
        myLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        myLabel.text = "sizi takip etmeye başladı" // sample label text
        let labelWidth = myLabel?.intrinsicContentSize().width
        myLabel.textAlignment = .Left
        myLabel.frame = CGRectMake(buttonWidth + 49 , 10 , screenSize.width - buttonWidth - 52 , 34)
        myLabel.numberOfLines = 1
        contentView.addSubview(myLabel)
        
        
        
        
        
        
    }
}