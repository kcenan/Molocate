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
    
    let Username: UIButton = UIButton()
    let followButton : UIButton = UIButton()
    let placeName : UIButton = UIButton()
    let reportButton: UIButton = UIButton()
    let shareButton:UIButton = UIButton()
    let commentButton : UIButton = UIButton()
    let likeButton : UIButton = UIButton()
    let profilePhoto : UIButton = UIButton()
    let likeCount : UIButton = UIButton()
    let commentCount : UIButton = UIButton()
    let videoComment : ActiveLabel = ActiveLabel()
    let videoTime : UILabel = UILabel()
    let label1 : UILabel = UILabel()
    let label2 : UILabel = UILabel()
    let label3 : UILabel = UILabel()
    let myLabel3: UILabel = UILabel()
    var cellthumbnail = UIImageView()
    let gap : CGFloat = 10
    let labelHeight: CGFloat = 30
    let labelWidth: CGFloat = 140
    var newRect:CGRect!
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
   
    var progressBar: UIProgressView = UIProgressView()
    var resendButton = UIButton()
    var deleteButton = UIButton()
    var blackView = UIView()
    var errorLabel = UILabel()
    
    var tableVideoURL: URL!
    var y:CGFloat!
    var hasPlayer = false
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initUI()
    }
    
    func initUI(){
        let  screenSize = MolocateDevice.size
     
        self.blackView.backgroundColor = UIColor.black
        self.blackView.layer.opacity = 0.8
        self.resendButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        self.resendButton.setImage(UIImage(named: "retry"), for: UIControlState())
        self.resendButton.tintColor = UIColor.white
        self.deleteButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0))
        self.deleteButton.setImage(UIImage(named: "cross"), for: UIControlState())
        self.deleteButton.tintColor = UIColor.white
        self.errorLabel.textAlignment = NSTextAlignment.center
        self.errorLabel.textColor = UIColor.white
        self.errorLabel.font = UIFont(name: "AvenirNext-Regular", size:17)
        self.errorLabel.text = "Videonuz yüklenemedi."
        profilePhoto.frame = CGRect(x: 5, y: 5, width: 44, height: 44)
        let image = UIImage(named: "profile")! as UIImage
        profilePhoto.layer.borderWidth = 0.1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = profileBackgroundColor.cgColor
        profilePhoto.backgroundColor = profileBackgroundColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        profilePhoto.setBackgroundImage(image, for: UIControlState())
        self.contentView.addSubview(profilePhoto)
        
        var reportImage2 : UIImageView
        reportImage2  = UIImageView(frame:CGRect(x: screenSize.width - 32, y: 77.4 + screenSize.width  , width: 27, height: 7.2));
        reportImage2.image = UIImage(named:"points")
        self.contentView.addSubview(reportImage2)
    
        Username.frame = CGRect(x: 59 , y: 5, width: screenSize.width - 100, height: 22)
        Username.titleLabel?.sizeToFit()
        Username.setTitleColor(arkarenk, for: UIControlState())
        Username.contentHorizontalAlignment = .left
        Username.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size:14)
        self.contentView.addSubview(Username)
        
        placeName.frame = CGRect(x: 59 , y: 27, width: screenSize.width - 100, height: 22)
        placeName.setTitleColor(swiftColor2, for: UIControlState())
        placeName.titleLabel?.sizeToFit()
        placeName.contentHorizontalAlignment = .left
        //placeName.setTitle("koç university", forState: .Normal)
        placeName.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 14)
        placeName.titleLabel?.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.contentView.addSubview(placeName)
        
        videoComment.frame = CGRect( x: 10 , y: 103 + screenSize.width , width: screenSize.width - 20 , height: 46)
      
        videoComment.customize { label in
            label.textAlignment = .left
            label.numberOfLines = 3
            label.textColor = arkarenk
            label.font = UIFont(name: "AvenirNext-Medium", size: 12.5)
            label.lineBreakMode = .byWordWrapping
            label.mentionColor = swiftColor
            label.hashtagColor = UIColor(red: 90, green: 200, blue: 250)
            
        }
        
        self.contentView.addSubview(videoComment)
        
        label3.frame = CGRect( x: 12 , y: 104 + screenSize.width , width: screenSize.width - 24 , height: 0.5)
        label3.backgroundColor = UIColor.lightGray
        label3.alpha = 0.2
        label3.text = "  "
        label3.font = UIFont(name: "AvenirNext-Regular", size: 10)
        label3.textAlignment = .center
        self.contentView.addSubview(label3)
        
        videoTime.frame = CGRect( x: screenSize.width - 34  , y: 60 + screenSize.width , width: 28 , height: 10)
        //videoTime.text = "2s"
        videoTime.font = UIFont(name: "AvenirNext-Regular", size: 11)
        videoTime.textAlignment = .right
        videoTime.textColor = UIColor.darkGray
        self.contentView.addSubview(videoTime)
        
        
     
        followButton.frame = CGRect(x: screenSize.width - 45 , y: 9 , width: 39, height: 30)
        followButton.setBackgroundImage(UIImage(named: "follow"), for: UIControlState())
        self.contentView.addSubview(followButton)
        
        
        
        
        
        likeCount.frame = CGRect( x: 26 , y: 62 + screenSize.width , width: 54 , height: 38)
        likeCount.contentHorizontalAlignment = .center
        //likeCount.contentVerticalAlignment = .Bottom
        //likeCount.setTitle("0", forState: .Normal)
        likeCount.setTitleColor(swiftColor, for: UIControlState())
        likeCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        self.contentView.addSubview(likeCount)
        
        likeButton.frame = CGRect( x: 9 , y: 66 + screenSize.width  , width: 30, height: 30)
        let likeImage = UIImage(named: "likeunfilled")! as UIImage
        likeButton.setBackgroundImage(likeImage, for: UIControlState())
        self.contentView.addSubview(likeButton)
        
        commentCount.frame = CGRect( x: 101 , y: 62 + screenSize.width , width: 54 , height: 38)
        commentCount.titleLabel!.font = UIFont(name: "AvenirNext-Medium", size: 14)
        commentCount.contentHorizontalAlignment = .center
        commentCount.setTitleColor(swiftColor, for: UIControlState())
        self.contentView.addSubview(commentCount)
        
        commentButton.frame = CGRect( x: 84 , y: 66 + screenSize.width  , width: 30, height: 30)
        let commentImage = UIImage(named: "comment")! as UIImage
        commentButton.setBackgroundImage(commentImage, for: UIControlState())
        self.contentView.addSubview(commentButton)
        
       
        reportButton.frame = CGRect(x: screenSize.width - 35, y: 64 + screenSize.width  , width: 34, height: 34)
        //let reportImage = UIImage(named: "points")! as UIImage
        //reportButton.setBackgroundImage(reportImage, forState: UIControlState.Normal)
        self.contentView.addSubview(reportButton)
        
        shareButton.frame = CGRect(x: self.commentCount.frame.origin.x+60, y: 66 + screenSize.width  , width: 30, height: 30)
        let shareImage = UIImage(named: "share")! as UIImage
        shareButton.setBackgroundImage(shareImage, for: UIControlState())
        self.contentView.addSubview(shareButton)
        
        newRect = CGRect(x: 0, y: 54, width: screenSize.width, height: screenSize.width)
        cellthumbnail = UIImageView(frame: newRect)
        self.contentView.layer.addSublayer(cellthumbnail.layer)
    
    }
    
    func getStringHeight(_ mytext: String, fontSize: CGFloat, width: CGFloat)->CGFloat {
        
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = CGSize(width: width,height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [NSFontAttributeName:font,
            NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = mytext as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height  
    }
    
    func initialize(_ row: Int , videoInfo: MoleVideoInformation){
        Username.setTitle(videoInfo.username, for: UIControlState())
        Username.tag = row
        
        likeButton.tag = row
        
        likeCount.setTitle("\(likeCount)", for: UIControlState())
        likeCount.tag = row
        
        placeName.setTitle(videoInfo.location, for: UIControlState())
        placeName.tag = row
        
        profilePhoto.tag = row
        
        followButton.tag = row
        
        commentButton.tag = row
        commentCount.tag = row
        commentCount.setTitle("\(commentCount)", for: UIControlState())
       
        reportButton.tag = row
        shareButton.tag = row
     
        self.videoTime.text = videoInfo.dateStr
        
        if(videoInfo.isLiked==1){
            self.likeButton.setBackgroundImage(UIImage(named: "likefilled"), for: UIControlState())
        }
        
        let textstring = videoInfo.caption
        
        videoComment.text = textstring        
        if(videoInfo.userpic?.absoluteString != ""){
            self.profilePhoto.sd_setImage(with: videoInfo.userpic, for: UIControlState.normal)
        }else{
            self.profilePhoto.setImage(UIImage(named: "profile"), for: UIControlState())
        }
        
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = CGPoint(x: newRect.midX, y: newRect.midY)
        activityIndicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        self.contentView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    deinit {
        //DBG: Research about deinit
    }
    
    
    
    
    
    
    
    
    
}
