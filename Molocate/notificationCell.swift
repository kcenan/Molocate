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
        
        let gap : CGFloat = 5
        fotoButton = UIButton()
        fotoButton.frame = CGRectMake(gap, gap, 40 , 40)
        contentView.addSubview(fotoButton)
        
       
        myButton = UIButton()
        myButton.frame = CGRectMake(50, gap, 100 , 40)
        myButton.titleLabel?.adjustsFontSizeToFitWidth = true
        myButton.titleLabel?.numberOfLines = 1
        myButton.setTitle("@alimertturker", forState: .Normal)
        myButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        contentView.addSubview(myButton)
        
        myLabel = UILabel()
        myLabel.frame = CGRectMake(160, gap , screenSize.size.width - 165, 40)
        myLabel.text = "Sizi takip etti."
        myLabel.adjustsFontSizeToFitWidth = true
        myLabel.numberOfLines = 1
        contentView.addSubview(myLabel)
    }
}
