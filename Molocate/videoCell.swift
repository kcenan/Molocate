//
//  celltryTableViewCell.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
//import AVFoundation
//import AVKit
//import MobileCoreServices


class videoCell: UITableViewCell {
    
    var Username: UIButton!
    var followButton : UIButton!
    var placeName : UIButton!
    var reportButton: UIButton!
    var commentButton : UIButton!
    var likeButton : UIButton!
    var profilePhoto : UIButton!
    var likeCount : UILabel!
    var commentCount : UILabel!
    var videoComment : UILabel!
    
    var myLabel3: UILabel!
    
    var tableVideoURL: NSURL!
    var y:CGFloat!
    var newRect:CGRect!
    let gap : CGFloat = 10
    let labelHeight: CGFloat = 30
    let labelWidth: CGFloat = 140
    var screenSize:CGRect!
    //var player: Videos!
    
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //player = Videos()
        screenSize = UIScreen.mainScreen().bounds
        
        profilePhoto = UIButton()
        profilePhoto.frame = CGRectMake(10, 5, 44, 44)
        //photo ata
        let image = UIImage(named: "elmander.jpg")! as UIImage
        profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        contentView.addSubview(profilePhoto)
        
        Username = UIButton()
        Username.frame = CGRectMake(59 , 5, screenSize.width - 100, 22)
        Username.titleLabel?.sizeToFit()
        Username.setTitleColor(swiftColor, forState: .Normal)
        Username.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        Username.setTitle("kcenan", forState: .Normal)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        contentView.addSubview(Username)
        
        placeName = UIButton()
        placeName.frame = CGRectMake(59 , 27, screenSize.width - 100, 22)
        placeName.setTitleColor(swiftColor2, forState: .Normal)
        placeName.titleLabel?.sizeToFit()
        placeName.titleLabel?.textAlignment = .Left
        placeName.setTitle("koç university", forState: .Normal)
        contentView.addSubview(placeName)
        
        videoComment = UILabel()
        videoComment.frame = CGRectMake( 5 , 59 + screenSize.width , 30 , screenSize.width - 10)
        //yazı ortalama ekle
        videoComment.text = "Molocate süper gelsenize @aturker "
        videoComment.textAlignment = .Left
        videoComment.textColor = UIColor.blackColor()
        videoComment.sizeToFit()
        contentView.addSubview(videoComment)
        
        followButton = UIButton()
        followButton.frame = CGRectMake(screenSize.width - 41 , 9 , 36 , 36)
        let followImage = UIImage(named: "follow1.png")! as UIImage
        followButton.setBackgroundImage(followImage, forState: UIControlState.Normal)
        //followButton.setTitleColor(swiftColor2, forState: .Normal)
        //followButton.setTitle("follow", forState: .Normal)
        contentView.addSubview(followButton)
        
        likeButton = UIButton()
        likeButton.frame = CGRectMake( 5 , 93 + screenSize.width , 36 , 36)
        let likeImage = UIImage(named: "like1.png")! as UIImage
        likeButton.setBackgroundImage(likeImage, forState: UIControlState.Normal)
        // likeButton.setTitleColor(swiftColor, forState: .Normal)
        //likeButton.setTitle("like", forState: .Normal)
        contentView.addSubview(likeButton)
        
        likeCount = UILabel()
        likeCount.frame = CGRectMake( 43 , 89 + screenSize.width , 44 , 44)
        //yazı ortalama ekle
        likeCount.text = "0"
        likeCount.textAlignment = .Center
        likeCount.textColor = swiftColor2
        contentView.addSubview(likeCount)
        
        commentButton = UIButton()
        commentButton.frame = CGRectMake( 93 , 93 + screenSize.width , 36 , 36)
        let commentImage = UIImage(named: "comment2.png")! as UIImage
        commentButton.setBackgroundImage(commentImage, forState: UIControlState.Normal)
        //commentButton.setTitleColor(swiftColor, forState: .Normal)
        //commentButton.setTitle("comment", forState: .Normal)
        contentView.addSubview(commentButton)
        
        
        commentCount = UILabel()
        commentCount.frame = CGRectMake( 137 , 89 + screenSize.width , 44 , 44)
        //yazı ortalama
        commentCount.text = "0"
        commentCount.textAlignment = .Center
        commentCount.textColor = swiftColor2
        contentView.addSubview(commentCount)
        
        reportButton = UIButton()
        reportButton.frame = CGRectMake(screenSize.width - 49, 89 + screenSize.width  , 44, 44)
        let reportImage = UIImage(named: "report1.png")! as UIImage
        reportButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        //reportButton.setTitle("Report", forState: .Normal)
        //image ata
        //reportButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
        contentView.addSubview(reportButton)
        
        newRect = CGRectMake(0, 54, screenSize.width, screenSize.width)
        
    }
    
    func initialize(row: Int , username: String, location: String, likeCount: Int, commentCount: Int, caption: String){
        self.Username.tag = row
        self.Username.setTitle(username, forState: .Normal)
        self.placeName.tag = row
        self.placeName.setTitle(location, forState: .Normal)
        //placeDictionary.setValue(videoArray[indexPath.row].locationID, forKey: placename)
        self.profilePhoto.tag = row
        self.followButton.tag = row
        self.likeButton.tag = row
        self.likeCount.text = "\(likeCount)"
        self.commentButton.tag = row
        self.commentCount.text = "\(commentCount)"
        self.reportButton.tag = row
        self.videoComment.text = caption
    }
    
    
    deinit {
        //player.layer.removeFromSuperlayer()
        //player.layer.player = nil
        //player.player.pause()
        //NSNotificationCenter.defaultCenter().removeObserver(self)
        //self.removeFromSuperview()
        //sself.contentView.removeFromSuperview()
        
    }
    
    
    
    
    
    
    
    
    
}