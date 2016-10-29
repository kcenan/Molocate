 //  Added.swift
//  Molocate


import UIKit
import Haneke
import SDWebImage
import AVFoundation
import XLActionController
import Photos
import FBSDKShareKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


 class Added: UIViewController, UITableViewDelegate, UITableViewDataSource,PlayerDelegate, FBSDKSharingDelegate {
    
    var lastOffset:CGPoint?
    var lastOffsetCapture:TimeInterval?
    var isScrollingFast:Bool = false
    var pointNow:CGFloat?
    var isSearching = false
    var direction = 0
    var activityIndicator: UIActivityIndicatorView?
    var player1:Player?
    var player2: Player?
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var videoArray: [MoleVideoInformation]?
    let screenSize: CGRect = UIScreen.main.bounds
    var tableView: UITableView?
    var on = true
    var likeHeart: UIImageView?
    var player1Turn = false
    var classUser: MoleUser?
    var isItMyProfile = true
   

    override func viewDidLoad() {
        super.viewDidLoad()
          
                // Do any additional setup after loading the view.
        initGui()
        if classUser != nil {
            getData()
        }
        //print(user.username)

        
    }
    
    func initGui(){
       
        view.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-190)
        likeHeart = UIImageView(image:
            UIImage(named: "favorite"))
        
        likeHeart?.alpha = 1.0
    
        self.player1 = Player()
        self.player1?.delegate = self
        self.player1?.playbackLoops = true
        
        self.player2 = Player()
        self.player2?.delegate = self
        self.player2?.playbackLoops = true
        // tableView.center = CGPointMake(screenSize.width/2,screenSize.height/2)
        tableView =  UITableView(frame:  CGRect(x: 0, y: 0 , width: screenSize.width, height: screenSize.height-80))
            
  
        tableView?.delegate      =   self
        tableView?.dataSource    =   self
        
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView?.allowsSelection = false
        tableView?.tableFooterView = UIView()
        self.view.addSubview(tableView!)
        lastOffset = CGPoint(x: 0, y: 0)
        
        if isItMyProfile {
        
            NotificationCenter.default.addObserver(self, selector: #selector(Added.prepareForRetry), name: NSNotification.Name(rawValue: "prepareForRetry"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(Added.updateProgress), name: NSNotification.Name(rawValue: "updateProgress"), object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(Added.uploadFinished), name: NSNotification.Name(rawValue: "uploadFinished"), object: nil)
        }
   
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Added.scrollToTop), name: "scrollToTop", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Added.prepareForRetry), name: "prepareForRetry", object: nil)

    }
    
    
    
    
    
    func getData(){
        MolocateVideo.getUserVideos((classUser?.username)!, type: "user", completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                if VideoUploadRequests.count == 0{
                    self.videoArray = data!
                }else if self.isItMyProfile{
                    self.videoArray?.removeAll()
                    self.videoArray = [MoleVideoInformation]()
                    for i in 0..<VideoUploadRequests.count{
                        
                        var queu = MoleVideoInformation()
                        let json = (VideoUploadRequests[i].JsonData)
                        let loc = json["location"] as! [[String:AnyObject]]
                        queu.dateStr = "0s"
                        queu.urlSta = (VideoUploadRequests[i].uploadRequest.body)!
                        //print("url:" + queu.urlSta.absoluteString)
                        queu.username = MoleCurrentUser.username
                        queu.userpic = MoleCurrentUser.profilePic!
                        queu.caption = json["caption"] as? String
                        // print(queu.caption                                 )
                        queu.location = loc[0]["name"] as? String
                        queu.locationID = loc[0]["id"] as? String
                        queu.isFollowing = 1
                        queu.thumbnailURL = (VideoUploadRequests[i].thumbUrl)!
                        queu.id = "\(VideoUploadRequests[i].id)"
                        if VideoUploadRequests[i].isFailed {
                            queu.isFailed = VideoUploadRequests[i].isFailed
                            queu.isUploading = false
                        }else{
                            queu.isUploading = true
                        }
                        
                        self.videoArray?.append(queu)
                    }
                    self.videoArray! += data!
                }else{
                    self.videoArray = data!
                }

//                if GlobalVideoUploadRequest == nil{
//                    self.videoArray = data!
//                }else if self.isItMyProfile{
//                    var queu = MoleVideoInformation()
//                    let json = (GlobalVideoUploadRequest?.JsonData)!
//                    let loc = json["location"] as! [[String:AnyObject]]
//                    queu.dateStr = "0s"
//                    queu.urlSta = (GlobalVideoUploadRequest?.uploadRequest.body)!
//                    queu.username = MoleCurrentUser.username
//                    queu.userpic = MoleCurrentUser.profilePic
//                    queu.caption = json["caption"] as! String
//                    queu.location = loc[0]["name"] as! String
//                    queu.locationID = loc[0]["id"] as! String
//                    queu.isFollowing = 1
//                    queu.thumbnailURL = (GlobalVideoUploadRequest?.thumbUrl)!
//                    queu.isUploading = true
//                    self.videoArray.append(queu)
//                    self.videoArray += data!
//                    
//                }else{
//                    self.videoArray = data!
//                }
                self.tableView?.reloadData()
            }
        })
    }
    func scrollToTop() {
        self.tableView?.setContentOffset(CGPoint(x:0,y:0), animated: true)
    }


    
    
    
    
    func playerReady(_ player: Player) {
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) {
        if player == player1 {
            player2?.stop()
        } else {
            player1?.stop()
        }
    }
    
    func playerPlaybackDidEnd(_ player: Player) {
        
        if classUser?.username != MoleCurrentUser.username{
                watch_list.append(player.id)
                if watch_list.count == 10{
                    MolocateVideo.increment_watch(watch_list, completionHandler: { (data, response, error) in
                        DispatchQueue.main.async{
                            watch_list.removeAll()
                            //print("watch incremented")
                        }
                    })
                }
        }
    }
    
    func pressedShare(_ sender: UIButton){
        let Row = sender.tag
        pausePlayers()
        let username = self.videoArray?[Row].username
        var shareURL:URL?
        if dictionary.object(forKey: self.videoArray?[Row].id) != nil {
            shareURL = dictionary.object(forKey: self.videoArray?[Row].id) as? URL
        } else {
            let url = self.videoArray?[Row].urlSta?.absoluteString
            if(url?[(url?.startIndex)!] == "h") {
                shareURL = self.videoArray?[Row].urlSta
            }
        }
        let actionSheet = TwitterActionController()
        // set up a header title
        actionSheet.headerData = "Paylaş"
        // Add some actions, note that the first parameter of `Action` initializer is `ActionData`.
        actionSheet.addAction(Action(ActionData(title: "Facebook", subtitle: "Facebook'da paylaş", image: UIImage(named: "facebookLogo")!), style: .default, handler: { action in
            let videoLayer = CALayer()
            let parentLayer = CALayer()
            parentLayer.frame = videoLayer.frame
            let sticker = UIImage(named: "videoSticker2")
            let string = username
            let tempasset = AVAsset(url: shareURL!)
            let clipVideoTrack = (tempasset.tracks(withMediaType: AVMediaTypeVideo)[0]) as AVAssetTrack
            let composition = AVMutableVideoComposition()
            composition.frameDuration = CMTimeMake(1,30)
            composition.renderSize = CGSize(width:clipVideoTrack.naturalSize.width, height:clipVideoTrack.naturalSize.height)
            let over = UIImageView(frame: CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142,y:10), size: CGSize(width: 142, height: 42.8)))
            over.image = sticker
            let dist = CGFloat((string?.characters.count)!*15)
            let text = CATextLayer()
            text.frame = CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142-dist,y:5), size: CGSize(width: dist, height: 42.8))
            text.alignmentMode = "left"
            text.string = string
            text.fontSize = 25
            text.font = UIFont(name: "AvenirNext-Regular", size:5)!
            parentLayer.frame = CGRect(x:0, y:0,width:composition.renderSize.width, height:composition.renderSize.height)
            videoLayer.frame = CGRect(x:0, y:0,width:composition.renderSize.width, height:composition.renderSize.height)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(over.layer)
            parentLayer.addSublayer(text)
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero,clipVideoTrack.timeRange.duration)
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            transformer.setTransform(clipVideoTrack.preferredTransform, at: kCMTimeZero)
            instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
            composition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
            let documentsPath = (NSTemporaryDirectory() as NSString)
            let exportPath = documentsPath.appendingFormat("fbshare.mp4", documentsPath)
            let exportURL = URL(fileURLWithPath: exportPath as String)
            let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetHighestQuality )
            exporter?.videoComposition = composition
            exporter?.outputURL = exportURL
            exporter?.outputFileType = AVFileTypeMPEG4
            exporter?.exportAsynchronously(completionHandler: { () -> Void in
                DispatchQueue.main.async(execute: {
                    let photoLibrary = PHPhotoLibrary.shared()
                    var videoAssetPlaceholder:PHObjectPlaceholder!
                    photoLibrary.performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL)
                        videoAssetPlaceholder = request!.placeholderForCreatedAsset
                        },
                        completionHandler: { success, error in
                            if success {
                                do {
                                    
                                    try FileManager.default.removeItem(at: exportURL)
                                    
                                } catch _ {
                                }
                                let localID = videoAssetPlaceholder.localIdentifier
                                let assetID =
                                    localID.replacingOccurrences(
                                        of: "/.*", with: "",
                                        options: NSString.CompareOptions.regularExpression, range: nil)
                                let ext = "mp4"
                                let assetURLStr =
                                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                let url = NSURL(string: assetURLStr)
                                let video = FBSDKShareVideo(videoURL: url as URL!)
                                let content = FBSDKShareVideoContent()
                                content.video = video
                                FBSDKShareDialog.show(from: self, with: content, delegate: self)
                                
                            }
                    })
                })
            })
        }))
        
        
        
        actionSheet.addAction(Action(ActionData(title: "Instagram", subtitle: "Instagram'da paylaş", image: UIImage(named: "instagramLogo")!), style: .default, handler: { action in
            let videoLayer = CALayer()
            let parentLayer = CALayer()
            parentLayer.frame = videoLayer.frame
            let sticker = UIImage(named: "videoSticker2")
            let string = username
            let tempasset = AVAsset(url: shareURL!)
            let clipVideoTrack = (tempasset.tracks(withMediaType: AVMediaTypeVideo)[0]) as AVAssetTrack
            let composition = AVMutableVideoComposition()
            composition.frameDuration = CMTimeMake(1,30)
            composition.renderSize = CGSize(width:clipVideoTrack.naturalSize.width, height:clipVideoTrack.naturalSize.height)
            let over = UIImageView(frame: CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142,y:10), size: CGSize(width: 142, height: 42.8)))
            over.image = sticker
            let dist = CGFloat((string?.characters.count)!*15)
            let text = CATextLayer()
            text.frame = CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142-dist,y:5), size: CGSize(width: dist, height: 42.8))
            text.alignmentMode = "left"
            text.string = string
            text.fontSize = 25
            text.font = UIFont(name: "AvenirNext-Regular", size:5)!
            parentLayer.frame = CGRect(x:0, y:0,width:composition.renderSize.width, height:composition.renderSize.height)
            videoLayer.frame = CGRect(x:0, y:0,width:composition.renderSize.width, height:composition.renderSize.height)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(over.layer)
            parentLayer.addSublayer(text)
            composition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
            let instruction = AVMutableVideoCompositionInstruction()
            instruction.timeRange = CMTimeRangeMake(kCMTimeZero,clipVideoTrack.timeRange.duration)
            let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
            transformer.setTransform(clipVideoTrack.preferredTransform, at: kCMTimeZero)
            instruction.layerInstructions = NSArray(object: transformer) as! [AVVideoCompositionLayerInstruction]
            composition.instructions = NSArray(object: instruction) as! [AVVideoCompositionInstructionProtocol]
            let documentsPath = (NSTemporaryDirectory() as NSString)
            let exportPath = documentsPath.appendingFormat("instashare.mp4", documentsPath)
            let exportURL = NSURL(fileURLWithPath: exportPath as String)
            let exporter = AVAssetExportSession(asset: tempasset, presetName:AVAssetExportPresetHighestQuality )
            exporter?.videoComposition = composition
            exporter?.outputURL = exportURL as URL
            exporter?.outputFileType = AVFileTypeMPEG4
            exporter?.exportAsynchronously(completionHandler: { () -> Void in
                DispatchQueue.main.async(execute: {
                    
                    let photoLibrary = PHPhotoLibrary.shared()
                    var videoAssetPlaceholder:PHObjectPlaceholder!
                    photoLibrary.performChanges({
                        let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: exportURL as URL)
                        videoAssetPlaceholder = request!.placeholderForCreatedAsset
                        },
                        completionHandler: { success, error in
                            if success {
                                do {
                                    
                                    try FileManager.default.removeItem(at: exportURL as URL)
                                    
                                } catch _ {
                                }
                                let localID = videoAssetPlaceholder.localIdentifier
                                let assetID =
                                    localID.replacingOccurrences(
                                        of: "/.*", with: "",
                                        options: NSString.CompareOptions.regularExpression, range: nil)
                                let ext = "mp4"
                                let assetURLStr =
                                    "assets-library://asset/asset.\(ext)?id=\(assetID)&ext=\(ext)"
                                let instagramURL = NSURL(string:"instagram://library?AssetPath=\(assetURLStr)")
                                if (UIApplication.shared.canOpenURL(instagramURL! as URL)) {
                                    UIApplication.shared.openURL(instagramURL! as URL)
                                    self.activityIndicator?.stopAnimating()
                                }
                                
                            } else {
                               // print(error)
                            }
                    })
                })
            })        }))
        // present actionSheet like any other view controller
        present(actionSheet, animated: true, completion: nil)
    }


    
    func playTapped(_ sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        //print("like a basıldı at index path: \(row) ")
        if self.tableView?.visibleCells.count < 3 {
            if (row) % 2 == 1{
                
                if self.player1?.playbackState.description != "Playing" {
                    self.player2?.stop()
                    self.player1?.playFromCurrentTime()
                }else{
                    self.player1?.stop()
                }
                
            }else{
                if self.player2?.playbackState.description != "Playing" {
                    self.player1?.stop()
                    self.player2?.playFromCurrentTime()
                }else{
                    self.player2?.stop()
                }
            }
        } else {
            let midrow =  self.tableView?.indexPathsForVisibleRows?[1].row
            if midrow! % 2 == 1 {
                if self.player1?.playbackState.description != "Playing" {
                    self.player2?.stop()
                    self.player1?.playFromCurrentTime()
                }else{
                    self.player1?.stop()
                }
            } else {
                if self.player2?.playbackState.description != "Playing" {
                    self.player1?.stop()
                    self.player2?.playFromCurrentTime()
                }else{
                    self.player2?.stop()
                }
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [IndexPath]()
        for item in (self.tableView?.indexPathsForVisibleRows!)!{
            let cell = self.tableView?.cellForRow(at: item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView?.reloadRows(at: ipArray, with: .none)
        }
        
        
    }
    
    
    func prepareForRetry(_ notification: Notification){
        let userInfo = (notification as NSNotification).userInfo
        if let video_id = userInfo!["id"] as? Int{
            if let i = VideoUploadRequests.index(where: {$0.id == video_id}) {
                VideoUploadRequests[i].isFailed = true
                if isItMyProfile{
                    videoArray?[i].isFailed = true
                    videoArray?[i].isUploading = false
                    if let cell = tableView?.cellForRow(at: IndexPath(row: i,section: 0)) as? videoCell{
                        DispatchQueue.main.async(execute: {
                            //print("prepareforRetry with id:\(video_id) row: \(i)")
                            
                            let rect = cell.newRect
                            cell.blackView.frame = rect!
                            let videoView = UIView(frame: cell.newRect)
                            cell.resendButton.center = CGPoint(x: videoView.center.x-50, y: videoView.center.y)
                            cell.deleteButton.center = CGPoint(x: videoView.center.x+50, y: videoView.center.y)
                            cell.errorLabel.frame = CGRect(x: 0, y: cell.resendButton.frame.maxY+10, width: cell.blackView.frame.width, height: 40)
                            
                            cell.blackView.layer.zPosition = 9000
                            cell.resendButton.layer.zPosition = 9999
                            cell.deleteButton.layer.zPosition = 9999
                            cell.errorLabel.layer.zPosition = 9999
                            
                            cell.contentView.addSubview(cell.blackView)
                            cell.contentView.addSubview(cell.resendButton)
                            cell.contentView.addSubview(cell.deleteButton)
                            cell.contentView.addSubview(cell.errorLabel)
                            cell.resendButton.tag = i
                            cell.deleteButton.tag = i
                            cell.resendButton.isEnabled = true
                            cell.deleteButton.isEnabled = true
                            cell.progressBar.isHidden = true
                        })
                    }
                }
            }
        }
        
    }
    
    func updateProgress(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo
        //print("updateProgress Called")
        if let video_id = userInfo!["id"] as? Int{
            //print("with id: \(video_id)")
            if let i = VideoUploadRequests.index(where: {$0.id == video_id}) {
                if let cell = tableView?.cellForRow(at: IndexPath(row: i,section: 0)) as? videoCell{
                    let progress = userInfo!["progress"] as! Float
                    //print("progressBar updated with: userInfo! \(progress)")
                    DispatchQueue.main.async(execute: {
                        cell.progressBar.setProgress(progress, animated: true)
                    })
                    //                    likeorFollowClicked = true
                    //                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: i,inSection: 0)], withRowAnimation: .None)
                    //                    likeorFollowClicked = false
                    
                }
            }
            
        }
        
    }
    
    func uploadFinished(_ notification:Notification){
        let userInfo = (notification as NSNotification).userInfo
        //print("upload finished")
        if let id = userInfo!["id"] as? Int{
           // print("with row: \(id)")
            if let cell = tableView?.cellForRow(at: IndexPath(row: id,section: 0)) as? videoCell{
                DispatchQueue.main.async(execute: {
                    cell.progressBar.isHidden = true
                    cell.resendButton.isEnabled = false
                    cell.deleteButton.isEnabled = false
                    cell.progressBar.removeFromSuperview()
                    cell.resendButton.removeFromSuperview()
                    cell.blackView.removeFromSuperview()
                    cell.deleteButton.removeFromSuperview()
                })
            }
            
            
        }
        
    }
    func retryRequest(_ sender: UIButton){
        let row = sender.tag
        //app yeni acildiginda s3uploads bos olcak onlari tekrar dan olusturmak lazim
        if let cell = tableView?.cellForRow(at: IndexPath(row: row,section: 0)) as? videoCell{
            
            MyS3Uploads[row].upload(true,id: VideoUploadRequests[row].id, uploadRequest: VideoUploadRequests[row].uploadRequest, fileURL:VideoUploadRequests[row].filePath!, fileID:  VideoUploadRequests[row].fileId!, json: VideoUploadRequests[row].JsonData, thumbnail_image: VideoUploadRequests[row].thumbnail)
            
            DispatchQueue.main.async(execute: {
                cell.resendButton.isEnabled = false
                cell.deleteButton.isEnabled = false
                self.videoArray?[row].isFailed = false
                self.videoArray?[row].isUploading = true
                VideoUploadRequests[row].isFailed = false
                cell.progressBar.progress =  0
                
                cell.progressBar.removeFromSuperview()
                cell.resendButton.removeFromSuperview()
                cell.blackView.removeFromSuperview()
                cell.deleteButton.removeFromSuperview()
                self.tableView?.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            })
            
            //        }else{ cell.t
            //            progressBar?.progress =  0
            //            progressBar?.hidden = true
            //            self.resendButton.removeFromSuperview()
            //            self.blackView.removeFromSuperview()
            //            self.deleteButton.removeFromSuperview()
            //            self.errorLabel.removeFromSuperview()
            //            self.tableView.reloadData()
            //        }
        }
        
    }
    
    
    func deleteVideo(_ sender: UIButton){
        let row = sender.tag
        if let cell = tableView?.cellForRow(at: IndexPath(row: row,section: 0)) as? videoCell{
            DispatchQueue.main.async(execute: {
                cell.resendButton.isEnabled = false
                cell.deleteButton.isEnabled = false
                
                _ = VideoUploadRequests[row].uploadRequest.body
                
                do {
                    try FileManager.default.removeItem(at: VideoUploadRequests[row].uploadRequest.body)
                }catch{
                    //print("Video Silinemedi")
                }
                
                VideoUploadRequests.remove(at: row)
                MyS3Uploads.remove(at: row)
                self.videoArray?.remove(at: row)
                self.tableView?.reloadData()
                MolocateVideo.encodeGlobalVideo()
                
                if VideoUploadRequests.count == 0 {
                    UserDefaults.standard.set(false, forKey: "isStuck")
                }
            })
            
            
        }
        
    }

    func animateLikeButton(){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
            self.likeHeart?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3);
            self.likeHeart?.alpha = 0.8;
        }) { (finished1) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
                self.likeHeart?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
                }, completion: { (finished2) in
                    UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                        self.likeHeart?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3);
                        self.likeHeart?.alpha = 0.0;
                        }, completion: { (finished3) in
                            self.likeHeart?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
                    })
            })
        }
        
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowHeight = screenSize.width + 150
        return rowHeight
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if videoArray != nil {
            return videoArray!.count
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow && indexPath.row < videoArray?.count {
            let cell = videoCell(style: UITableViewCellStyle.value1, reuseIdentifier: "timelineCell")
            cell.initialize(indexPath.row, videoInfo:  (videoArray?[indexPath.row])!)
            
            cell.Username.addTarget(self, action: #selector(Added.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.placeName.addTarget(self, action: #selector(Added.pressedPlace(_:)), for: UIControlEvents.touchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(Added.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.commentCount.addTarget(self, action: #selector(Added.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            
            cell.resendButton.addTarget(self, action: #selector(Added.retryRequest(_:)), for: UIControlEvents.touchUpInside)
            cell.deleteButton.addTarget(self, action: #selector(Added.deleteVideo(_:)), for: UIControlEvents.touchUpInside)
            
            if(videoArray?[indexPath.row].isFollowing==0 && videoArray?[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(Added.pressedFollow(_:)), for: UIControlEvents.touchUpInside)
            }else{
                cell.followButton.isHidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(Added.pressedLike(_:)), for: UIControlEvents.touchUpInside)
            
            //cell.likeCount.setTitle("\(videoArray?[indexPath.row].likeCount)", for: UIControlState())
            //cell.commentCount.setTitle("\(videoArray?[indexPath.row].commentCount)", for: UIControlState())
            cell.commentButton.addTarget(self, action: #selector(Added.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            cell.reportButton.addTarget(self, action: #selector(Added.pressedReport(_:)), for: UIControlEvents.touchUpInside)
            cell.shareButton.addTarget(self, action: #selector(Added.pressedShare(_:)), for: UIControlEvents.touchUpInside)
            cell.likeCount.addTarget(self, action: #selector(Added.pressedLikeCount(_:)), for: UIControlEvents.touchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(Added.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(Added.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            //cell.videoComment.handleMentionTap { userHandle in Added.pressedUsername(userHandle, profilePic: nil, isFollowing: false)}
            
            
            
            playtap.require(toFail: tap)
            
            
            let thumbnailURL = self.videoArray?[indexPath.row].thumbnailURL
            
            if(thumbnailURL?.absoluteString != ""){
                cell.cellthumbnail.sd_setImage(with: thumbnailURL)
                //////print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }
            
            if !isScrollingFast || (self.tableView?.contentOffset.y == 0)  {
                
                var trueURL = URL(string: "")
                if dictionary.object(forKey: self.videoArray?[indexPath.row].id) != nil {
                    trueURL = dictionary.object(forKey: self.videoArray?[indexPath.row].id) as? URL
                } else {
                    let url = self.videoArray?[indexPath.row].urlSta?.absoluteString
                    if(url?.characters.first! == "h") {
                        trueURL = self.videoArray?[indexPath.row].urlSta
                        DispatchQueue.main.async {
                            myCache.fetch(URL:(self.videoArray?[indexPath.row].urlSta!)! ).onSuccess{ NSData in
                                ////print("hop")
                                let url = self.videoArray?[indexPath.row].urlSta?.absoluteString
                                let path = NSURL(string: DiskCache.basePath())!.appendingPathComponent("shared-data/original")
                                let cached = DiskCache(path: (path?.absoluteString)!).path(forKey: url!)
                                let file = URL(fileURLWithPath: cached)
                                dictionary.setObject(file, forKey: self.videoArray?[indexPath.row].id as! NSCopying)
                                
                            }
                        }
                    }else{
                        trueURL = self.videoArray?[indexPath.row].urlSta
                    }
                }
                if !cell.hasPlayer {
                    
                    
                    if indexPath.row % 2 == 1 {
                        
                        self.player1?.setUrl(trueURL!)
                        self.player1?.id = self.videoArray?[indexPath.row].id
                        self.player1?.view.frame = cell.newRect
                        self.player1?.view.layer.zPosition = 1111
                        cell.contentView.addSubview((self.player1?.view)!)
                        cell.hasPlayer = true
                        
                    }else{
                        
                        self.player2?.setUrl(trueURL!)
                        self.player2?.id = self.videoArray?[indexPath.row].id
                        self.player2?.view.frame = cell.newRect
                        self.player2?.view.layer.zPosition = 1111
                        cell.contentView.addSubview((self.player2?.view)!)
                        cell.hasPlayer = true
                    }
                    
                }
                
                //}
                
                //  }
            }
            
            if (videoArray?[indexPath.row].isUploading)! {
                let myprogress = cell.progressBar.progress
                cell.progressBar =  UIProgressView(frame: cell.label3.frame)
                cell.progressBar.progress = myprogress
                cell.contentView.addSubview(cell.progressBar)
            }else if (videoArray?[indexPath.row].isFailed)! {
                
                let rect = cell.newRect
                cell.blackView.frame = rect!
                
                let videoView = UIView(frame: cell.newRect)
                cell.resendButton.center = CGPoint(x: videoView.center.x-50, y: videoView.center.y)
                cell.deleteButton.center = CGPoint(x: videoView.center.x+50, y: videoView.center.y)
                cell.errorLabel.frame = CGRect(x: 0, y: cell.resendButton.frame.maxY+10, width: cell.blackView.frame.width, height: 40)
                
                cell.blackView.layer.zPosition = 9000
                cell.resendButton.layer.zPosition = 9999
                cell.deleteButton.layer.zPosition = 9999
                cell.errorLabel.layer.zPosition = 9999
                cell.contentView.addSubview(cell.blackView)
                cell.contentView.addSubview(cell.resendButton)
                cell.contentView.addSubview(cell.deleteButton)
                cell.contentView.addSubview(cell.errorLabel)
                
                
                
                
                cell.resendButton.tag = indexPath.row
                cell.deleteButton.tag = indexPath.row
                cell.resendButton.isEnabled = true
                cell.deleteButton.isEnabled = true
                cell.progressBar.isHidden = true
            }
            return cell
        }else if indexPath.row < videoArray?.count{
            let cell = tableView.cellForRow(at: indexPath) as! videoCell
            // print("cell created")
            if(videoArray?[indexPath.row].isLiked == 0) {
                cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), for: UIControlState())
            }else{
                cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), for: UIControlState())
                cell.likeButton.tintColor = UIColor.white
            }
            
            cell.likeCount.setTitle("\(videoArray?[indexPath.row].likeCount)", for: UIControlState())
            
            if !cell.followButton.isHidden && videoArray?[indexPath.row].isFollowing == 1{
                //add animation
                cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
            }
            //cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
            cell.commentCount.setTitle("\(videoArray?[indexPath.row].commentCount)", for: UIControlState())
            return cell
            
            
        }else{
            let cell = tableView.cellForRow(at: indexPath) as! videoCell
            return cell
        }

        
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = Date().timeIntervalSinceReferenceDate
     
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
            
            if (scrollView.contentOffset.y<pointNow) {
                direction = 0
            } else if (scrollView.contentOffset.y>pointNow) {
                direction = 1
            }
            
            let currentOffset = scrollView.contentOffset
            let currentTime = Date().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];
            
            let timeDiff = currentTime - lastOffsetCapture!;
            if(timeDiff > 0.1) {
                let distance = currentOffset.y - (lastOffset?.y)!;
                //The multiply by 10, / 1000 isn't really necessary.......
                let scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond
                
                let scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
                if (scrollSpeed > 0.1) {
                    isScrollingFast = true
                    //print("hızlı")
                    
                } else {
                    isScrollingFast = false
                    var ipArray = [IndexPath]()
                    for item in (self.tableView?.indexPathsForVisibleRows!)!{
                        let cell = self.tableView?.cellForRow(at: item) as! videoCell
                        if !cell.hasPlayer {
                            ipArray.append(item)
                        }
                    }
                    if ipArray.count != 0 {
                        self.tableView?.reloadRows(at: ipArray, with: .none)
                    }

                    
                }
                
                lastOffset = currentOffset;
                lastOffsetCapture = currentTime;
            }
            
            if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                )
            {
                
                if self.tableView?.visibleCells.count > 2 {
                    (self.tableView?.visibleCells[0] as! videoCell).hasPlayer = false
                    (self.tableView?.visibleCells[2] as! videoCell).hasPlayer = false
                }
                let longest = scrollView.contentOffset.y + scrollView.frame.height
                if direction == 1 {
                    //////print("down")
                    let cellap = scrollView.contentOffset.y - (self.tableView?.visibleCells[0].center.y)!
                    //////print(cellap)
                    let row = (self.tableView?.indexPathsForVisibleRows![0].row)!+1
                    if cellap > 0 {
                        
                        if (row) % 2 == 1{
                            //self.tableView.visibleCells[1].reloadInputViews()
                            if self.player1?.playbackState.description != "Playing" {
                                self.player2?.stop()
                                if !isScrollingFast {
                                self.player1?.playFromBeginning()
                                }
                                ////print(self.tableView.indexPathsForVisibleRows![0].row)
                                //////print("player1")
                                player1Turn = true
                            }
                        }else{
                            if self.player2?.playbackState.description != "Playing"{
                                self.player1?.stop()
                                if !isScrollingFast {
                                self.player2?.playFromBeginning()
                                }
                                player1Turn = false
                                //////print("player2")
                            }
                        }
                    }
                }
                    
                    
                else {
                    //////print("up")
                    
                    let cellap = longest - (self.tableView?.visibleCells[0].center.y)!-150-self.view.frame.width
                    ////print(cellap)
                    let row = self.tableView?.indexPathsForVisibleRows![0].row
                    if cellap < 0 {
                        
                        if (row)! % 2 == 1{
                            
                            if self.player1?.playbackState.description != "Playing" {
                                self.player2?.stop()
                                if !isScrollingFast {
                                self.player1?.playFromBeginning()
                                }
                                player1Turn = true
                                //////print("player1")
                            }
                        }else{
                            if self.player2?.playbackState.description != "Playing"{
                                self.player1?.stop()
                                if !isScrollingFast {
                                self.player2?.playFromBeginning()
                                }
                                player1Turn = false
                                //////print("player2")
                            }
                        }
                    }
                }
            }
            
            
            
        
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if self.player1?.playbackState.description != "Playing" || self.player2?.playbackState.description != "Playing" {
                isScrollingFast = false
                var ipArray = [IndexPath]()
                for item in (self.tableView?.indexPathsForVisibleRows!)!{
                    let cell = self.tableView?.cellForRow(at: item) as! videoCell
                    if !cell.hasPlayer {
                        ipArray.append(item)
                    }
                }
                if ipArray.count != 0 {
                    self.tableView?.reloadRows(at: ipArray, with: .none)
                }
                if player1Turn {
                    if self.player1?.playbackState.description != "Playing" {
                        player1?.playFromBeginning()
                    }
                } else {
                    if self.player2?.playbackState.description != "Playing" {
                        player2?.playFromBeginning()
                    }
                }
            }
        }
    }
    


    func tableView(_ atableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if atableView == tableView{
            
            if((indexPath.row%10 == 7)&&(AddedNextUserVideos != nil)&&(!IsExploreInProcess)){
                IsExploreInProcess = true
                MolocateVideo.getExploreVideos(AddedNextUserVideos, completionHandler: { (data, response, error,next) -> () in
                    AddedNextUserVideos = next
                    DispatchQueue.main.async{
                        
                        for item in data!{
                            self.videoArray?.append(item)
                            let newIndexPath = IndexPath(row: (self.videoArray?.count)!-1, section: 0)
                            atableView.insertRows(at: [newIndexPath], with: .bottom)
                            
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "changeHeightofScrollView"), object: nil)
                        IsExploreInProcess = false
                    }
                    
                })
                
                
            }
        }
        else {
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    func doubleTapped(_ sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        //print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = IndexPath(row: buttonRow, section: 0)
        let  cell = tableView?.cellForRow(at: indexpath)
        likeHeart?.center = (cell?.contentView.center)!
        likeHeart?.layer.zPosition = 100
        let imageSize = likeHeart?.image?.size.height
        likeHeart?.frame = CGRect(x: (likeHeart?.center.x)!-imageSize!/2 , y: (likeHeart?.center.y)!-imageSize!/2, width: imageSize!, height: imageSize!)
        cell?.addSubview(likeHeart!)
        animateLikeButton()
        var indexes = [IndexPath]()
        indexes.append(indexpath)
        
        if(videoArray?[buttonRow].isLiked == 0){
            
            self.videoArray?[buttonRow].isLiked=1
            self.videoArray?[buttonRow].likeCount+=1
            
            
            self.tableView?.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            MolocateVideo.likeAVideo((videoArray?[buttonRow].id!)!) { (data, response, error) -> () in
                DispatchQueue.main.async{
                    //print(data)
                }
            }
        }else{
            
            
//            self.videoArray[buttonRow].isLiked=0
//            self.videoArray[buttonRow].likeCount-=1
//            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
//            
//            
//            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
//                dispatch_async(dispatch_get_main_queue()){
//                    //print(data)
//                }
//            }
        }
         pressedLike = false
    }
    

    func pressedFollow(_ sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        
        //print("followa basıldı at index path: \(buttonRow) ")
        self.videoArray?[buttonRow].isFollowing = 1
        var indexes = [IndexPath]()
        let index = IndexPath(row: buttonRow, section: 0)
        indexes.append(index)
        self.tableView?.reloadRows(at: indexes, with: .none)
        
        MolocateAccount.follow((videoArray?[buttonRow].username!)!){ (data, response, error) -> () in
                     MoleCurrentUser.following_count += 1
        }
        pressedFollow = false
    }
    

    func pressedLike(_ sender: UIButton) {
        let buttonRow = sender.tag
        //print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = IndexPath(row: buttonRow, section: 0)
        var indexes = [IndexPath]()
        indexes.append(indexpath)
        
        if(videoArray?[buttonRow].isLiked == 0){
            sender.isHighlighted = true
            
            self.videoArray?[buttonRow].isLiked=1
            self.videoArray?[buttonRow].likeCount+=1
            
            
            self.tableView?.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            MolocateVideo.likeAVideo((videoArray?[buttonRow].id!)!) { (data, response, error) -> () in
                DispatchQueue.main.async{
                    //print(data)
                }
            }
        }else{
            sender.isHighlighted = false
            
            self.videoArray?[buttonRow].isLiked=0
            self.videoArray?[buttonRow].likeCount-=1
            self.tableView?.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
            
            
            MolocateVideo.unLikeAVideo((videoArray?[buttonRow].id!)!){ (data, response, error) -> () in
                DispatchQueue.main.async{
                    //print(data)
                }
            }
        }
               pressedLike = false
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [IndexPath]()
        for item in (self.tableView?.indexPathsForVisibleRows!)!{
            let cell = self.tableView?.cellForRow(at: item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView?.reloadRows(at: ipArray, with: .none)
        }
        
    }
    
    

    
    func pressedPlace(_ sender: UIButton) {
        let buttonRow = sender.tag
        
        pausePlayers()
        
        activityIndicator?.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        if navigationController?.isNavigationBarHidden == true {
            //self.navigationcontroller?.setNavigationBarHidden(false, animated: false)
        }
        
        
        let controller:profileVenue = self.parent!.storyboard!.instantiateViewController(withIdentifier: "profileVenue") as! profileVenue
       
        
        self.parent!.navigationController?.pushViewController(controller, animated: true)
        
        
        MolocatePlace.getPlace((videoArray?[buttonRow].locationID!)!) { (data, response, error) -> () in
            DispatchQueue.main.async{
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator?.stopAnimating()
            }
        }
        
    }
    
    
    func pressedLikeCount(_ sender: UIButton) {
        pausePlayers()
        video_id = (videoArray?[sender.tag].id!)!
        videoIndex = sender.tag

        activityIndicator?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        let controller:likeVideo = self.parent!.storyboard!.instantiateViewController(withIdentifier: "likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator?.stopAnimating()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.parent!.navigationController?.pushViewController(controller, animated: true)
    }
    
    func pressedUsername(_ sender: UIButton) {
        
        let buttonRow = sender.tag
        //////////print("username e basıldı at index path: \(buttonRow)")
        pausePlayers()
        activityIndicator?.startAnimating()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        
        
        let controller:profileUser = self.parent!.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        if videoArray?[buttonRow].username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
      
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser((videoArray?[buttonRow].username!)!) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                
                user = data
                controller.classUser = data
                controller.RefreshGuiWithData()
                
                //choosedIndex = 0
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator?.stopAnimating()
            }
        }
    }
    
    func pressedComment(_ sender: UIButton) {
        if navigationController?.isNavigationBarHidden == true {
            //navigationcontroller?.setNavigationBarHidden(false, animated: false)
        }
        let buttonRow = sender.tag
        
        pausePlayers()
        
        videoIndex = buttonRow
        video_id = (videoArray?[videoIndex].id!)!
    
        if isItMyProfile {
            myViewController = "MyAdded"
        }else{
             myViewController = "Added"
        }
        
        
        activityIndicator?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:commentController = self.parent!.storyboard!.instantiateViewController(withIdentifier: "commentController") as! commentController
        comments.removeAll()
        MolocateVideo.getComments((videoArray?[buttonRow].id!)!) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                comments = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator?.stopAnimating()
            }
        }
        self.parent!.navigationController?.pushViewController(controller, animated: true)
        
    }
    

    
    func pressedReport(_ sender: UIButton) {
        let buttonRow = sender.tag
        pausePlayers()
        MolocateVideo.reportAVideo((videoArray?[buttonRow].id!)!) { (data, response, error) -> () in
            //////print(data)
        }
        //////print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if(videoArray?[buttonRow].deletable)!{
            
            let deleteVideo: UIAlertAction = UIAlertAction(title: "Videoyu Sil", style: .default) { action -> Void in
                let index = IndexPath(row: buttonRow, section: 0)
                
                
                MolocateVideo.deleteAVideo((self.videoArray?[buttonRow].id!)!, completionHandler: { (data, response, error) in
                    
                })
                
                self.videoArray?.remove(at: (index as NSIndexPath).row)
                self.tableView?.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                self.tableView?.reloadData()
            }
            
            actionSheetController.addAction(deleteVideo)
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Raporla", style: .default) { action -> Void in
            
            //////print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.present(actionSheetController, animated: true, completion: nil)
        
    }
 
    
    override func viewDidDisappear(_ animated: Bool) {
        //self.tableView.removeFromSuperview()


    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
       // print(results)
    }
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
        
    }
    
    func pausePlayers(){
        player1?.pause()
        player2?.pause()
    }
    
    
    
    
}
