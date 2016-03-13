//
//  sideCell.swift
//  Molocate
//
//  Created by MellonCorp on 3/12/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class sideCell: UITableViewCell {
    
    
    @IBOutlet var imageFrame: UIImageView!
    @IBOutlet var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

        
//        label = UILabel()
//        label.frame = CGRectMake( 0 ,0 , 20, 25)
//        //yazı ortalama ekle
//        label.textAlignment = .Left
//        label.textColor = UIColor.blackColor()
//        label.backgroundColor = UIColor.greenColor()
//        label.text = "ddee"
//        contentView.addSubview(label)


}
