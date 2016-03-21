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
    var likeCount : UIButton!
    var commentCount : UILabel!
    var videoComment : UILabel!
    var videoTime : UILabel!
    
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
        
        let image = UIImage(named: "profilepic.png")! as UIImage
        profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
        contentView.addSubview(profilePhoto)
        
        Username = UIButton()
        Username.frame = CGRectMake(59 , 5, screenSize.width - 100, 22)
        Username.titleLabel?.sizeToFit()
        Username.setTitleColor(swiftColor, forState: .Normal)
        Username.contentHorizontalAlignment = .Left
        Username.setTitle("kcenan", forState: .Normal)
        Username.titleLabel?.font = UIFont(name: "LatoTR-Bold", size:14)
        //Username.addTarget(self, action: "pressedUsername:", forControlEvents:UIControlEvents.TouchUpInside)
        contentView.addSubview(Username)
        
        placeName = UIButton()
        placeName.frame = CGRectMake(59 , 27, screenSize.width - 100, 22)
        placeName.setTitleColor(swiftColor2, forState: .Normal)
        placeName.titleLabel?.sizeToFit()
        placeName.contentHorizontalAlignment = .Left
        placeName.setTitle("koç university", forState: .Normal)
        placeName.titleLabel?.font = UIFont(name: "LatoTR-Regular", size: 16)
        contentView.addSubview(placeName)
        
        videoComment = UILabel()
        videoComment.frame = CGRectMake( 10 , 59 + screenSize.width , screenSize.width - 50 , 50)
        //yazı ortalama ekle
        videoComment.font = UIFont(name: "LatoTR-Light", size: 14)
        videoComment.textAlignment = .Left
        
        videoComment.textColor = UIColor.blackColor()
        //videoComment.sizeToFit()
        contentView.addSubview(videoComment)
        
        videoTime = UILabel()
        videoTime.frame = CGRectMake( screenSize.width - 30  , 59 + screenSize.width , 25 , 25)
        //yazı ortalama ekle
        videoTime.text = "2s"
        videoTime.font = UIFont(name: "LatoTR-Light", size: 14)
        videoTime.textAlignment = .Right
        videoTime.textColor = UIColor.blackColor()
        videoTime.sizeToFit()
        contentView.addSubview(videoTime)
        
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
        
        
        likeCount = UIButton()
        likeCount.frame = CGRectMake( 43 , 89 + screenSize.width , 44 , 44)
        likeCount.setTitle("0", forState: .Normal)
        likeCount.setTitleColor(swiftColor, forState: .Normal)
        likeButton.setBackgroundImage(likeImage, forState: UIControlState.Normal)
        // likeButton.setTitleColor(swiftColor, forState: .Normal)
        //likeButton.setTitle("like", forState: .Normal)
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
    
    func initialize(row: Int , username: String, location: String, likeCount: Int, commentCount: Int, caption: String, profilePic:NSURL, dateStr: String){
        self.Username.tag = row
        self.Username.setTitle(username, forState: .Normal)
        self.placeName.tag = row
        self.placeName.setTitle(location, forState: .Normal)
        //placeDictionary.setValue(videoArray[indexPath.row].locationID, forKey: placename)
        self.profilePhoto.tag = row
        self.followButton.tag = row
        self.likeButton.tag = row
        self.likeCount.setTitle("\(likeCount)", forState: .Normal)
        self.likeCount.tag = row
        self.commentButton.tag = row
        self.commentCount.text = "\(commentCount)"
        self.reportButton.tag = row
        self.videoComment.text = caption
        self.videoTime.text = dateStr
        print(profilePic.absoluteString)
        if(profilePic.absoluteString != ""){
            Molocate.getDataFromUrl(profilePic, completion: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue()){
                    let image = UIImage(data: data!)!
                    self.profilePhoto.setBackgroundImage(image, forState: UIControlState.Normal)
                    
                }
            })
            //photo.image = UIImage(data: data!)!
        }
       
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