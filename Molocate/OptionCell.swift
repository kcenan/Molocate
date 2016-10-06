//
//  optionCell.swift
//  Molocate


import UIKit

class optionCell: UITableViewCell {
    
    
    let nameOption : UILabel = UILabel()
    let arrow : UIImageView = UIImageView()
    let cancelLabel: UILabel = UILabel()
    
    
    var screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
        nameOption.frame = CGRect( x: 10 , y: 15 , width: screenSize.width - 50 , height: 30 )
        nameOption.textAlignment = .left
        nameOption.textColor = swiftColor
        nameOption.text = "deneme"
        self.contentView.addSubview(nameOption)
        
        
        

        let image: UIImage = UIImage(named: "right-chevron.png")!
        arrow.image = image
        arrow.frame = CGRect (x: screenSize.width - 40, y: 20 , width: 20 , height: 20)
        
        self.contentView.addSubview(arrow)
        
        
       
        cancelLabel.frame = CGRect( x: screenSize.width - 70, y: 40 , width: 60 , height: 30 )
        cancelLabel.textAlignment = .left
        cancelLabel.textColor = swiftColor
        cancelLabel.text = "Cancel"
        self.contentView.addSubview(cancelLabel)
        
        
        
    }
   
    deinit{
        //nameOption = nil
        //arrow = nil
        //cancelLabel = nil
    }
    
}
