//
//  sideCell.swift
//  Molocate
//
//  Created by MellonCorp on 3/12/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class sideCell: UITableViewCell {
    
    var label : UILabel!
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        
        
        label = UILabel()
        label.frame = CGRectMake( 2 ,5 , 5, 5)
        //yazı ortalama ekle
        label.textAlignment = .Left
        label.textColor = UIColor.blackColor()
        label.sizeToFit()
        label.backgroundColor = UIColor.greenColor()
        contentView.addSubview(label)
    }

}
