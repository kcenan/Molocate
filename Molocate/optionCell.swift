//
//  optionCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 7.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class optionCell: UITableViewCell {
    
    
    var nameOption : UILabel!
    var arrow : UIImageView!
    var cancelLabel: UILabel!
    var switchDemo : UISwitch!

    var screenSize = UIScreen.mainScreen().bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        nameOption = UILabel()
        nameOption.frame = CGRectMake( 10 , 15 , screenSize.width - 50 , 30 )
        nameOption.textAlignment = .Left
        nameOption.textColor = swiftColor
        nameOption.text = "deneme"
        contentView.addSubview(nameOption)
        
        switchDemo = UISwitch()
        var a : CGFloat = screenSize.width - 30
        switchDemo.center.x = a
        var b : CGFloat = 30
        switchDemo.center.y = b
        //switchDemo.transform = CGAffineTransformMakeScale( screenHeight / 667 , screenHeight / 667 )
        switchDemo.on = true
        switchDemo.setOn(true, animated: false)
        
        contentView.addSubview(switchDemo)
        
        arrow = UIImageView()
        let image: UIImage = UIImage(named: "right-chevron.png")!
        arrow = UIImageView(image: image)
        arrow.frame = CGRectMake (screenSize.width - 40, 20 , 20 , 20)
        
        contentView.addSubview(arrow)
       
        
        cancelLabel = UILabel()
        cancelLabel.frame = CGRectMake( screenSize.width - 70, 40 , 60 , 30 )
        cancelLabel.textAlignment = .Left
        cancelLabel.textColor = swiftColor
        cancelLabel.text = "Cancel"
        contentView.addSubview(cancelLabel)
        
        
        
    }

//    func switchValueDidChange(sender:UISwitch!)
//    {
//        if (sender.on == true){
//            print("on")
//            
//        }
//        else{
//            print("off")
//        }
//    }
    
}
