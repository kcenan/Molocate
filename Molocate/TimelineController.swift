//
//  TimelineController.swift
//  Molocate
//
//  Created by Ekin Akyürek on 30/05/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Haneke
import SDWebImage
import XLActionController
import AVFoundation
import Photos
import FBSDKShareKit

@objc protocol TimelineControllerDelegate:class {

    func pressedUsername(_ username: String, profilePic: URL?, isFollowing: Bool)

    func pressedPlace(_ placeId: String, Row: Int)

    func pressedLikeCount(_ videoId: String, Row: Int)

    func pressedComment(_ videoId: String, Row: Int)
    
    @objc optional func toggleNavigationBar(_ direction: Bool)
    

}
var watch_list = [String]()

class TimelineController: UITableViewController,PlayerDelegate, FBSDKSharingDelegate {
    /*!
     @abstract Sent to the delegate when the sharer encounters an error.
     @param sharer The FBSDKSharing that completed.
     @param error The error.
     */
    public func sharer(_ sharer: FBSDKSharing!, didFailWithError error: Error!) {
    
    }




    var isRequested:NSMutableDictionary = NSMutableDictionary()
    var lastOffset:CGPoint = CGPoint()
    var lastOffsetCapture:TimeInterval = TimeInterval()
    var isScrollingFast = false
    var pointNow:CGFloat = CGFloat()
    var player1:Player?
    var player2: Player?
    var likeorFollowClicked = false
    var refreshing = false
    var player1Turn = false
    var nextUrl: URL?
    var direction = 0 // 0 is down and 1 is up
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var videoArray = [MoleVideoInformation]()
    var likeHeart = UIImageView()
    var myRefreshControl = UIRefreshControl()
    var isOnView = false
    var requestUrl:URL?
    var isNearby = false
    var classLat = Float()
    var classLon = Float()
    var filter_raw = ""
    weak var delegate: TimelineControllerDelegate?
    var type = ""
    var placeId = ""


    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor.white
    
        
        self.player1 = Player()
        self.player1?.delegate = self
        self.player1?.playbackLoops = true

        self.player2 = Player()
        self.player2?.delegate = self
        self.player2?.playbackLoops = true

        likeHeart.image = UIImage(named: "favorite")
        likeHeart.alpha = 1.0

        if(choosedIndex != 0 && profileOn == 1){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeProfile"), object: nil)
        }
        self.myRefreshControl = UIRefreshControl()
        self.myRefreshControl.addTarget(self, action: #selector(TimelineController.refresh), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(myRefreshControl)

        switch type {
            case "HomePage":
                requestUrl = URL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
                self.myRefreshControl.attributedTitle = NSAttributedString(string: "Haber kaynağı güncelleniyor...")
                getExploreData(requestUrl!)
            case "profileVenue":
                getPlaceData(placeId)
            case "filter":
                if !isNearby {
                    requestUrl = URL(string: MolocateBaseUrl+"video/api/filtered_videos/?name="+filter_raw)!
                    getExploreData(requestUrl!)
                } else {
                    getNearbyData(classLat, lon: classLon)
                }
            default:
                requestUrl = URL(string: MolocateBaseUrl + "video/api/news_feed/?category=all")!
        }



        NotificationCenter.default.addObserver(self, selector: #selector(TimelineController.scrollToTop), name: NSNotification.Name(rawValue: "scrollToTop"), object: self)

     
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineController.prepareForRetry), name: NSNotification.Name(rawValue: "prepareForRetry"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(TimelineController.updateProgress), name: NSNotification.Name(rawValue: "updateProgress"), object: nil)
        
          NotificationCenter.default.addObserver(self, selector: #selector(TimelineController.uploadFinished), name: NSNotification.Name(rawValue: "uploadFinished"), object: nil)
    }
    
//    
//    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self)
//    }
//    
    
 


    func getPlaceData(_ placeId: String){
        UIApplication.shared.beginIgnoringInteractionEvents()

        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            DispatchQueue.main.async{
                self.nextUrl = MoleNextPlaceVideos
                self.videoArray = thePlace.videoArray
                self.tableView.reloadData()
                if self.myRefreshControl.isRefreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
    }

    func getExploreData(_ url: URL){
        MolocateVideo.getExploreVideos(url, completionHandler: { (data, response, error,next) -> () in
            self.nextUrl  = next
            DispatchQueue.main.async{
              
                if VideoUploadRequests.count == 0{
                    self.videoArray = data!
                }else if self.type == "HomePage"{
                    self.videoArray.removeAll()
                    
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
             
                        self.videoArray.append(queu)
                    }
                        self.videoArray += data!
                    
                }else{
                    self.videoArray = data!
                }


                self.tableView.reloadData()
              
            if self.type == "HomePage" {
                if self.videoArray.count == 0 {
                    
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "showNoFoll"), object: nil)
                } else {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "hideNoFoll"), object: nil)
                }
                }


                if self.myRefreshControl.isRefreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        })

    }
    
    func getNearbyData(_ lat:Float, lon:Float){
        MolocateVideo.getNearbyVideos(lat, placeLon: lon) { (data, response, error, next) in
            DispatchQueue.main.async{
                if next != nil {
                self.nextUrl = next!
                }
                self.videoArray = data!
                self.tableView.reloadData()
                if self.myRefreshControl.isRefreshing {
                    self.myRefreshControl.endRefreshing()
                }
                self.refreshing = false
                if UIApplication.shared.isIgnoringInteractionEvents {
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }
        }
    }

    func refresh(){
        
        
        refreshing = true
        self.player1?.stop()
        self.player2?.stop()

        switch type {
            case "HomePage":
                getExploreData(requestUrl!)
            case "ProfileVenue":
                getPlaceData(placeId)
            case "filter":
                if !isNearby {
                    getExploreData(requestUrl!)
                } else {
                    getNearbyData(classLat, lon: classLon)
            }
            default:
                print("default")
        }


    }
    
    func toggle(_ direction:Bool){
        delegate?.toggleNavigationBar!(direction)
    }
    func refreshForNearby(_ sender:AnyObject, lat:Float,lon:Float) {
        refreshing = true
        self.player1?.stop()
        self.player2?.stop()
        getNearbyData(lat, lon: lon)
        
    }



    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if !likeorFollowClicked && indexPath.row < videoArray.count {
            let cell = videoCell(style: UITableViewCellStyle.value1, reuseIdentifier: "timelineCell")
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])

            cell.Username.addTarget(self, action: #selector(TimelineController.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.placeName.addTarget(self, action: #selector(TimelineController.pressedPlace(_:)), for: UIControlEvents.touchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(TimelineController.pressedUsername(_:)), for: UIControlEvents.touchUpInside)
            cell.commentCount.addTarget(self, action: #selector(TimelineController.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            
            cell.resendButton.addTarget(self, action: #selector(TimelineController.retryRequest(_:)), for: UIControlEvents.touchUpInside)
            cell.deleteButton.addTarget(self, action: #selector(TimelineController.deleteVideo(_:)), for: UIControlEvents.touchUpInside)

            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != MoleCurrentUser.username){
                cell.followButton.addTarget(self, action: #selector(TimelineController.pressedFollow(_:)), for: UIControlEvents.touchUpInside)
            }else{
                cell.followButton.isHidden = true
            }

            cell.likeButton.addTarget(self, action: #selector(TimelineController.pressedLike(_:)), for: UIControlEvents.touchUpInside)

            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", for: UIControlState())
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", for: UIControlState())
            cell.commentButton.addTarget(self, action: #selector(TimelineController.pressedComment(_:)), for: UIControlEvents.touchUpInside)
            cell.reportButton.addTarget(self, action: #selector(TimelineController.pressedReport(_:)), for: UIControlEvents.touchUpInside)
            cell.shareButton.addTarget(self, action: #selector(TimelineController.pressedShare(_:)), for: UIControlEvents.touchUpInside)
            cell.likeCount.addTarget(self, action: #selector(TimelineController.pressedLikeCount(_:)), for: UIControlEvents.touchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(TimelineController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)

            cell.videoComment.handleMentionTap { userHandle in  self.delegate?.pressedUsername(userHandle, profilePic: nil, isFollowing: false)}

   

            playtap.require(toFail: tap)


            let thumbnailURL = self.videoArray[indexPath.row].thumbnailURL

            if(thumbnailURL?.absoluteString != ""){
                cell.cellthumbnail.sd_setImage(with: thumbnailURL)
                //////print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }

            if !isScrollingFast || (self.tableView.contentOffset.y == 0)  {
               
                var trueURL = URL(string: "")
                if dictionary.object(forKey: self.videoArray[indexPath.row].id) != nil {
                    trueURL = dictionary.object(forKey: self.videoArray[indexPath.row].id) as? URL
                } else {
                    let url = self.videoArray[indexPath.row].urlSta?.absoluteString
                    if(url?.characters.first! == "h") {
                        trueURL = self.videoArray[indexPath.row].urlSta
                        DispatchQueue.main.async {
                            myCache.fetch(URL:self.videoArray[indexPath.row].urlSta! ).onSuccess{ NSData in
                                ////print("hop")
                                let url = self.videoArray[indexPath.row].urlSta?.absoluteString
                                let path = NSURL(string: DiskCache.basePath())!.appendingPathComponent("shared-data/original")
                                let cached = DiskCache(path: (path?.absoluteString)!).path(forKey: url!)
                                let file = URL(fileURLWithPath: cached)
                                dictionary.setObject(file, forKey: self.videoArray[indexPath.row].id as! NSCopying)

                            }
                        }
                    }else{
                        trueURL = self.videoArray[indexPath.row].urlSta
                    }
                }
                if !cell.hasPlayer {


                    if indexPath.row % 2 == 1 {

                        self.player1?.setUrl(trueURL!)
                        self.player1?.id = self.videoArray[indexPath.row].id
                        self.player1?.view.frame = cell.newRect
                        self.player1?.view.layer.zPosition = 1111
                        cell.contentView.addSubview((self.player1?.view)!)
                        cell.hasPlayer = true

                    }else{

                        self.player2?.setUrl(trueURL!)
                        self.player2?.id = self.videoArray[indexPath.row].id
                        self.player2?.view.frame = cell.newRect
                        self.player2?.view.layer.zPosition = 1111
                        cell.contentView.addSubview((self.player2?.view)!)
                        cell.hasPlayer = true
                    }

                }

                //}

                //  }
            }
            
            if videoArray[indexPath.row].isUploading {
                let myprogress = cell.progressBar.progress
                cell.progressBar =  UIProgressView(frame: cell.label3.frame)
                cell.progressBar.progress = myprogress
                cell.contentView.addSubview(cell.progressBar)
            }else if videoArray[indexPath.row].isFailed {
                
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
        }else if indexPath.row < videoArray.count{
            let cell = tableView.cellForRow(at: indexPath) as! videoCell
           // print("cell created")
            if(videoArray[indexPath.row].isLiked == 0) {
                cell.likeButton.setBackgroundImage(UIImage(named: "likeunfilled"), for: UIControlState())
            }else{
                cell.likeButton.setBackgroundImage(UIImage(named: "likefilled"), for: UIControlState())
                cell.likeButton.tintColor = UIColor.white
            }

            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", for: UIControlState())

            if !cell.followButton.isHidden && videoArray[indexPath.row].isFollowing == 1{
                //add animation
                cell.followButton.setBackgroundImage(UIImage(named: "followTicked"), for: UIControlState())
            }
            //cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", for: UIControlState())
            return cell


        }else{
               let cell = tableView.cellForRow(at: indexPath) as! videoCell
                return cell
        }
    }


    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [IndexPath]()
        for item in self.tableView.indexPathsForVisibleRows!{
            let cell = self.tableView.cellForRow(at: item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView.reloadRows(at: ipArray, with: .none)
        }


    }

    func playTheTruth(){
        if (player1?.playbackState.description != "Playing") && (player2?.playbackState.description != "Playing") {
        if player1Turn {
            player1?.playFromBeginning()
        } else {
            player2?.playFromBeginning()
        }
        }
    }

    func scrollToTop() {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        if type == "HomePage" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showNavigation"), object: nil)
        }
        
        if type == "MainController" {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "showNavigationMain"), object: nil)
        }
        
    }

    override func tableView(_ atableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print(nextUrl)

        if((!refreshing)&&(indexPath.row%10 == 7)&&(nextUrl != nil)&&(!IsExploreInProcess)){
            IsExploreInProcess = true
            MolocateVideo.getExploreVideos(nextUrl, completionHandler: { (data, response, error, next) -> () in
                self.nextUrl = next

                DispatchQueue.main.async{

                    for item in data!{
                        self.videoArray.append(item)
                        let newIndexPath = IndexPath(row: self.videoArray.count-1, section: 0)
                        atableView.insertRows(at: [newIndexPath], with: .bottom)

                    }

                    IsExploreInProcess = false
                }

            })


        }
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = Date().timeIntervalSinceReferenceDate
    }

    override func viewWillAppear(_ animated: Bool) {
            isScrollingFast = false
            isOnView = true

    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrollingFast = false
        var ipArray = [IndexPath]()
        for item in self.tableView.indexPathsForVisibleRows!{
            let cell = self.tableView.cellForRow(at: item) as! videoCell
            if !cell.hasPlayer {
                ipArray.append(item)
            }
        }
        if ipArray.count != 0 {
            self.tableView.reloadRows(at: ipArray, with: .none)
        }

    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if self.player1?.playbackState.description != "Playing" || self.player2?.playbackState.description != "Playing" {
                isScrollingFast = false
                var ipArray = [IndexPath]()
                for item in self.tableView.indexPathsForVisibleRows!{
                    let cell = self.tableView.cellForRow(at: item) as! videoCell
                    if !cell.hasPlayer {
                        ipArray.append(item)
                    }
                }
                if ipArray.count != 0 {
                    self.tableView.reloadRows(at: ipArray, with: .none)
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


    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        
        if(!refreshing) {
            if type == "HomePage" {
                if (scrollView.contentOffset.y<pointNow) {
                    direction = 0

                } else if (scrollView.contentOffset.y>pointNow) {
                    direction = 1
                }

                let currentOffset = scrollView.contentOffset
                let currentTime = Date().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];

                let timeDiff = currentTime - lastOffsetCapture;
                if(timeDiff > 0.1) {
                    let distance = currentOffset.y - lastOffset.y;
                    //The multiply by 10, / 1000 isn't really necessary.......
                    let scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond

                    let scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
                    
                    if (scrollSpeed > 0.1
                        ) {
                        isScrollingFast = true
                        //                    player1.stop()
                        //                    player2.stop()

                    } else {
                        isScrollingFast = false
                        var ipArray = [IndexPath]()
                        for item in self.tableView.indexPathsForVisibleRows!{
                            let cell = self.tableView.cellForRow(at: item) as! videoCell
                            if !cell.hasPlayer {
                                ipArray.append(item)
                            }
                        }
                        if ipArray.count != 0 {
                            self.tableView.reloadRows(at: ipArray, with: .none)
                        }


                    }

                    lastOffset = currentOffset;
                    lastOffsetCapture = currentTime;
                }
                if is4s{
                    if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                        )
                    {
                        let longest = scrollView.contentOffset.y + scrollView.frame.height
                        if direction == 1 {
                            //////////print("down")
                            let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                            //////////print(cellap)
                            let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row+1
                            if cellap > 0 {

                                if (row) % 2 == 1{
                                    //self.tableView.visibleCells[1].reloadInputViews()
                                    if self.player1?.playbackState.description != "Playing" {
                                        self.player2?.stop()
                                        if !isScrollingFast {
                                            self.player1?.playFromBeginning()
                                        }
                                        player1Turn = true
                                        //////print(self.tableView.indexPathsForVisibleRows![0].row)
                                        //////////print("player1")
                                    }
                                }else{
                                    if self.player2?.playbackState.description != "Playing"{
                                        self.player1?.stop()
                                        if !isScrollingFast {
                                            self.player2?.playFromBeginning()
                                        }
                                        player1Turn = false
                                        //////////print("player2")
                                    }
                                }
                            }
                        }


                        else {
                            //////////print("up")

                            let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                            ////////print(cellap)
                            let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row
                            if cellap < 0 {

                                if (row) % 2 == 1{

                                    if self.player1?.playbackState.description != "Playing" {
                                        self.player2?.stop()
                                        if !isScrollingFast {
                                            self.player1?.playFromBeginning()
                                        }
                                        player1Turn = true
                                        //////////print("player1")
                                    }
                                }else{
                                    if self.player2?.playbackState.description != "Playing"{
                                        self.player1?.stop()
                                        if !isScrollingFast {
                                            self.player2?.playFromBeginning()
                                        }
                                        player1Turn = false
                                        //////////print("player2")
                                    }
                                }
                            }
                        }
                    }


                } else {
                    if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                        )
                    {

                        if self.tableView.visibleCells.count > 2 {
                            (self.tableView.visibleCells[0] as! videoCell).hasPlayer = false
                            (self.tableView.visibleCells[2] as! videoCell).hasPlayer = false
                        }
                        let longest = scrollView.contentOffset.y + scrollView.frame.height
                        if direction == 1 {
                            //////////print("down")
                            let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                            //////////print(cellap)

                            let row = (self.tableView.indexPathsForVisibleRows![1] as NSIndexPath).row
                            if cellap > 0 {

                                if (row) % 2 == 1{
                                    //self.tableView.visibleCells[1].reloadInputViews()
                                    if self.player1?.playbackState.description != "Playing" {
                                        self.player2?.stop()
                                        if !isScrollingFast {
                                            self.player1?.playFromBeginning()

                                        }
                                        player1Turn = true
                                        //////print(self.tableView.indexPathsForVisibleRows![0].row)
                                        //////////print("player1")
                                    }
                                }else{
                                    if self.player2?.playbackState.description != "Playing"{
                                        self.player1?.stop()
                                        if !isScrollingFast {
                                            self.player2?.playFromBeginning()

                                        }
                                        player1Turn = false
                                        //////////print("player2")
                                    }
                                }
                            }
                        }


                        else {
                            //////////print("up")

                            let cellap = longest - self.tableView.visibleCells[1].center.y
                            //////////print(cellap)
                            let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row
                            if cellap < 0 {

                                if (row) % 2 == 1{

                                    if self.player1?.playbackState.description != "Playing" {
                                        self.player2?.stop()
                                        if !isScrollingFast {
                                            self.player1?.playFromBeginning()
                                        }
                                        player1Turn = true
                                    }
                                }else{
                                    if self.player2?.playbackState.description != "Playing"{
                                        self.player1?.stop()
                                        if !isScrollingFast {
                                            self.player2?.playFromBeginning()
                                        }
                                        player1Turn = false
                                    }
                                }
                            }
                        }
                    }



                }
            }else if type == "profileVenue" {

                if (scrollView.contentOffset.y<pointNow) {
                    direction = 0
                } else if (scrollView.contentOffset.y>pointNow) {
                    direction = 1
                }

                let currentOffset = scrollView.contentOffset
                let currentTime = Date().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];

                let timeDiff = currentTime - lastOffsetCapture;
                if(timeDiff > 0.1) {
                    let distance = currentOffset.y - lastOffset.y;
                    //The multiply by 10, / 1000 isn't really necessary.......
                    let scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond

                    let scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
                    if (scrollSpeed > 0.1) {
                        isScrollingFast = true
                        ////print("hızlı")

                    } else {
                        isScrollingFast = false
                        var ipArray = [IndexPath]()
                        for item in self.tableView.indexPathsForVisibleRows!{
                            let cell = self.tableView.cellForRow(at: item) as! videoCell
                            if !cell.hasPlayer {
                                ipArray.append(item)
                            }
                        }
                        if ipArray.count != 0 {
                            self.tableView.reloadRows(at: ipArray, with: .none)
                        }


                    }

                    lastOffset = currentOffset;
                    lastOffsetCapture = currentTime;
                }

                if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                    )
                {

                    if self.tableView.visibleCells.count > 2 {
                        (self.tableView.visibleCells[0] as! videoCell).hasPlayer = false
                        (self.tableView.visibleCells[2] as! videoCell).hasPlayer = false
                    }
                    let longest = scrollView.contentOffset.y + scrollView.frame.height
                    if direction == 1 {
                        ////////print("down")
                        let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                        ////////print(cellap)
                        let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row+1
                        if cellap > 0 {

                            if (row) % 2 == 1{
                                //self.tableView.visibleCells[1].reloadInputViews()
                                if self.player1?.playbackState.description != "Playing" {
                                    self.player2?.stop()
                                    if !isScrollingFast {
                                        self.player1?.playFromBeginning()
                                    }
                                    player1Turn = true
                                    ////print(self.tableView.indexPathsForVisibleRows![0].row)
                                    ////////print("player1")
                                }
                            }else{
                                if self.player2?.playbackState.description != "Playing"{
                                    self.player1?.stop()
                                    if !isScrollingFast {
                                        self.player2?.playFromBeginning()
                                    }
                                    player1Turn = false
                                    ////////print("player2")
                                }
                            }
                        }
                    }


                    else {
                        ////////print("up")

                        let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                        //////print(cellap)
                        let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row
                        if cellap < 0 {

                            if (row) % 2 == 1{

                                if self.player1?.playbackState.description != "Playing" {
                                    self.player2?.stop()
                                    if !isScrollingFast {
                                        self.player1?.playFromBeginning()
                                    }
                                    player1Turn = true
                                    ////////print("player1")
                                }
                            }else{
                                if self.player2?.playbackState.description != "Playing"{
                                    self.player1?.stop()
                                    if !isScrollingFast {
                                        self.player2?.playFromBeginning()
                                    }
                                    player1Turn = false
                                    ////////print("player2")
                                }
                            }
                        }
                    }
                }



            }else if type == "filter" {
                                              if (scrollView.contentOffset.y<pointNow) {

                    direction = 0
                                                
                    if self.parent is MainController {
                    (self.parent as! MainController).isBarOnView = true
                    toggle(false)
                    viewBool = false
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "changeView"), object: nil)
                    }
                    //self.parentViewController?.navigationController?.setNavigationBarHidden(false, animated: true)
                } else if (scrollView.contentOffset.y>pointNow) {
                    direction = 1
                    if self.parent is MainController {
                    toggle(true)
                    (self.parent as! MainController).isBarOnView = false
                    viewBool = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "changeView"), object: nil)
                            }
                    //self.parentViewController?.navigationController?.setNavigationBarHidden(true, animated: true)

                }
                if scrollView.contentOffset.y > 0 {
                    if self.parent is MainController {
                        let cv = (self.parent as! MainController).collectionView
                    //    let tb = (self.parentViewController as! MainController).tableController.tableView
                        var imp = scrollView.contentOffset.y
                        if imp < 0 {
                            imp = -imp
                        }
                        if (cv?.frame.origin.y)! + 60 > imp {

                        } else {
                            if direction == 1 {
                                let oldY = cv?.frame.origin.y
                                cv?.frame = CGRect(origin: CGPoint(x:0 ,y:oldY!-2) , size: (cv?.contentSize)!)
                                //print("görünmüyor")
                            }
                        }
                    }
                }


                let currentOffset = scrollView.contentOffset
                let currentTime = Date().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];

                let timeDiff = currentTime - lastOffsetCapture;
                if(timeDiff > 0.1) {
                    let distance = currentOffset.y - lastOffset.y;
                    //The multiply by 10, / 1000 isn't really necessary.......
                    let scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond

                    let scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
                    if (scrollSpeed > 0.1) {
                        isScrollingFast = true
                        //////print("hızlı")

                    } else {
                        isScrollingFast = false
                        var ipArray = [IndexPath]()
                        for item in self.tableView.indexPathsForVisibleRows!{
                            let cell = self.tableView.cellForRow(at: item) as! videoCell
                            if !cell.hasPlayer {
                                ipArray.append(item)
                            }
                        }
                        if ipArray.count != 0 {
                            self.tableView.reloadRows(at: ipArray, with: .none)
                        }


                    }

                    lastOffset = currentOffset;
                    lastOffsetCapture = currentTime;
                }

                if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
                    )
                {
                    if self.tableView.visibleCells.count > 2 {
                        (self.tableView.visibleCells[0] as! videoCell).hasPlayer = false
                        (self.tableView.visibleCells[2] as! videoCell).hasPlayer = false
                    }
                    let longest = scrollView.contentOffset.y + scrollView.frame.height
                    if direction == 1 {
                        //////////print("down")
                        let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                        //////////print(cellap)
                        let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row+1
                        if cellap > 0 {

                            if (row) % 2 == 1{
                                
                                if self.player1?.playbackState.description != "Playing" {
                                    self.player2?.stop()
                                    if !isScrollingFast {
                                        self.player1?.playFromBeginning()
                                    }
                                    player1Turn = true

                                }
                            }else{
                                if self.player2?.playbackState.description != "Playing"{
                                    self.player1?.stop()
                                    if !isScrollingFast {
                                        self.player2?.playFromBeginning()
                                    }
                                    player1Turn = false
                                    //////////print("player2")
                                }
                            }
                        }
                    }


                    else {
                        //////////print("up")

                        let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                        ////////print(cellap)
                        let row = (self.tableView.indexPathsForVisibleRows![0] as NSIndexPath).row
                        if cellap < 0 {

                            if (row) % 2 == 1{

                                if self.player1?.playbackState.description != "Playing" {
                                    self.player2?.stop()
                                    if !isScrollingFast {
                                        self.player1?.playFromBeginning()
                                    }
                                    player1Turn = true
                                    //////////print("player1")
                                }
                            }else{
                                if self.player2?.playbackState.description != "Playing"{
                                    self.player1?.stop()
                                    if !isScrollingFast {
                                        self.player2?.playFromBeginning()
                                    }
                                    player1Turn = false

                                    //////////print("player2")
                                }
                            }
                        }
                    }
                }


            }
        }
    }



    func pressedFollow(_ sender: UIButton) {
        //update cells
        let Row = sender.tag

        likeorFollowClicked = true

        self.videoArray[Row].isFollowing = 1


        let user = videoArray[Row].username

        for i in 0..<videoArray.count {
            if  videoArray[i].username == user{
                videoArray[i].isFollowing = 1
            }
        }

        tableView.reloadRows(at: tableView.indexPathsForVisibleRows!, with: .none)

        MolocateAccount.follow(videoArray[Row].username!){ (data, response, error) -> () in
            MoleCurrentUser.following_count += 1
        }
        likeorFollowClicked = false
        
        

    }


    func playTapped(_ sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        //////print("like a basıldı at index path: \(row) ")
        if self.tableView.visibleCells.count < 3 {
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
            let midrow =  (self.tableView.indexPathsForVisibleRows![1] as NSIndexPath).row
            if midrow % 2 == 1 {
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



   
    func prepareForRetry(_ notification: Notification){
        let userInfo = (notification as NSNotification).userInfo
        if let video_id = userInfo!["id"] as? Int{
            if let i = VideoUploadRequests.index(where: {$0.id == video_id}) {
                VideoUploadRequests[i].isFailed = true
                if type == "HomePage"{
                    videoArray[i].isFailed = true
                    videoArray[i].isUploading = false
                    if let cell = tableView.cellForRow(at: IndexPath(row: i,section: 0)) as? videoCell{
                    DispatchQueue.main.async(execute: {
                        print("prepareforRetry with id:\(video_id) row: \(i)")
                            
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
        print("updateProgress Called")
        if let video_id = userInfo!["id"] as? Int{
            print("with id: \(video_id)")
            if let i = VideoUploadRequests.index(where: {$0.id == video_id}) {
                if let cell = tableView.cellForRow(at: IndexPath(row: i,section: 0)) as? videoCell{
                    let progress = userInfo!["progress"] as! Float
                    print("progressBar updated with: userInfo! \(progress)")
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
        print("upload finished")
        if let id = userInfo!["id"] as? Int{
            print("with row: \(id)")
                if let cell = tableView.cellForRow(at: IndexPath(row: id,section: 0)) as? videoCell{
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
          if let cell = tableView.cellForRow(at: IndexPath(row: row,section: 0)) as? videoCell{
            
            MyS3Uploads[row].upload(true,id: VideoUploadRequests[row].id, uploadRequest: VideoUploadRequests[row].uploadRequest, fileURL:VideoUploadRequests[row].filePath!, fileID:  VideoUploadRequests[row].fileId!, json: VideoUploadRequests[row].JsonData, thumbnail_image: VideoUploadRequests[row].thumbnail)
            
             DispatchQueue.main.async(execute: {
                cell.resendButton.isEnabled = false
                cell.deleteButton.isEnabled = false
                self.videoArray[row].isFailed = false
                self.videoArray[row].isUploading = true
                VideoUploadRequests[row].isFailed = false
                cell.progressBar.progress =  0
  
                cell.progressBar.removeFromSuperview()
                cell.resendButton.removeFromSuperview()
                cell.blackView.removeFromSuperview()
                cell.deleteButton.removeFromSuperview()
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
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
        if let cell = tableView.cellForRow(at: IndexPath(row: row,section: 0)) as? videoCell{
            DispatchQueue.main.async(execute: {
                cell.resendButton.isEnabled = false
                cell.deleteButton.isEnabled = false
             
                _ = VideoUploadRequests[row].uploadRequest.body
               
                do {
                    try FileManager.default.removeItem(at: VideoUploadRequests[row].uploadRequest.body)
                }catch{
                    print("Video Silinemedi")
                }

                VideoUploadRequests.remove(at: row)
                MyS3Uploads.remove(at: row)
                self.videoArray.remove(at: row)
                self.tableView.reloadData()
                MolocateVideo.encodeGlobalVideo()
               
                if VideoUploadRequests.count == 0 {
                    UserDefaults.standard.set(false, forKey: "isStuck")
                }
            })
            
           
        }
        
    }
    func doubleTapped(_ sender: UITapGestureRecognizer) {
        //animateLike and updatecells
        let Row = sender.view!.tag

        likeorFollowClicked = true

        let index = IndexPath(row: Row, section: 0)
        let cell = tableView.cellForRow(at: index) as! videoCell

        likeHeart.center = (cell.contentView.center)
        likeHeart.layer.zPosition = 100
        let imageSize = likeHeart.image?.size.height
        likeHeart.frame = CGRect(x: likeHeart.center.x-imageSize!/2 , y: likeHeart.center.y-imageSize!/2, width: imageSize!, height: imageSize!)
        cell.addSubview(likeHeart)
        animateLikeButton()

        if(videoArray[Row].isLiked == 0){

            videoArray[Row].isLiked=1
            videoArray[Row].likeCount+=1


            tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)

            MolocateVideo.likeAVideo(videoArray[Row].id!) { (data, response, error) -> () in
            }
        }else{
            //Do Nothing

        }
        likeorFollowClicked = false
    }

    func pressedUsername(_ sender: UIButton) {
        let Row = sender.tag
        let isFollowing = videoArray[Row].isFollowing == 0 ? false:true
        pausePLayers()
        //stop players

        delegate?.pressedUsername(videoArray[Row].username!, profilePic: videoArray[Row].userpic! as URL, isFollowing: isFollowing)

    }

    func pressedPlace(_ sender: UIButton) {
        let Row = sender.tag
        let placeId = videoArray[Row].locationID
        pausePLayers()
        //stopplayers
        delegate?.pressedPlace(placeId!, Row: Row)
    }

    func pressedLikeCount(_ sender: UIButton) {
        let Row = sender.tag
        let videoId = videoArray[Row].id
        pausePLayers()
        //stopplayers
        delegate?.pressedLikeCount(videoId!,Row: Row)
    }

    func pressedComment(_ sender: UIButton) {
        //stopplayers
        let Row = sender.tag
        let videoId = videoArray[Row].id
        pausePLayers()

        delegate?.pressedComment(videoId!,Row: Row)
    }

    func pressedLike(_ sender: UIButton) {
        let Row = sender.tag

        likeorFollowClicked = true
        let index = IndexPath(row: Row, section: 0)

        if(videoArray[Row].isLiked == 0){
            videoArray[Row].isLiked=1
            videoArray[Row].likeCount+=1

            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)

            MolocateVideo.likeAVideo(videoArray[Row].id!) { (data, response, error) -> () in
            }

        }else{
            sender.isHighlighted = false

            videoArray[Row].isLiked=0
            videoArray[Row].likeCount-=1
            self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.none)

            MolocateVideo.unLikeAVideo(videoArray[Row].id!){ (data, response, error) -> () in
            }
        }
        likeorFollowClicked = false
    }
    
    func pressedShare(_ sender: UIButton) {
        let Row = sender.tag
        pausePLayers()
        let username = self.videoArray[Row].username
        var shareURL: URL?
        if dictionary.object(forKey: self.videoArray[Row].id) != nil {
            shareURL = dictionary.object(forKey: self.videoArray[Row].id) as? URL
        } else {
            let url = self.videoArray[Row].urlSta?.absoluteString
            if(url?[(url?.startIndex)!] == "h") {
                shareURL = self.videoArray[Row].urlSta
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
            composition.renderSize = CGSize(width: clipVideoTrack.naturalSize.width, height: clipVideoTrack.naturalSize.height)
            let over = UIImageView(frame: CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142,y:10), size: CGSize(width: 142, height: 42.8)))
            over.image = sticker
            let dist = CGFloat((string?.characters.count)!*15)
            let text = CATextLayer()
            text.frame = CGRect(origin: CGPoint(x: clipVideoTrack.naturalSize.width-142-dist,y:5), size: CGSize(width: dist, height: 42.8))
            text.alignmentMode = "left"
            text.string = string
            text.fontSize = 25
            text.font = UIFont(name: "AvenirNext-Regular", size:5)!
            parentLayer.frame = CGRect(x: 0, y: 0, width: composition.renderSize.width, height: composition.renderSize.height)
            videoLayer.frame = CGRect(x: 0, y: 0, width: composition.renderSize.width, height: composition.renderSize.height)
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
                                let assetID = localID.replacingOccurrences(
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
                                                self.activityIndicator.stopAnimating()
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

    func pressedReport(_ sender: UIButton) {
        //stop players
        let Row = sender.tag
        pausePLayers()

        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if(videoArray[Row].deletable){

            let deleteVideo: UIAlertAction = UIAlertAction(title: "Videoyu Sil", style: .default) { action -> Void in
                let index = IndexPath(row: Row, section: 0)

                MolocateVideo.deleteAVideo(self.videoArray[Row].id!, completionHandler: { (data, response, error) in

                })

                self.videoArray.remove(at: (index as NSIndexPath).row)

                self.tableView.deleteRows(at: [index], with: UITableViewRowAnimation.automatic)
                self.tableView.reloadData()
            }

            actionSheetController.addAction(deleteVideo)
        }


        let cancelAction: UIAlertAction = UIAlertAction(title: "İptal", style: .cancel) { action -> Void in
        }

        actionSheetController.addAction(cancelAction)

        let reportVideo: UIAlertAction = UIAlertAction(title: "Raporla", style: .default) { action -> Void in
            //DBG::Report
        }
        actionSheetController.addAction(reportVideo)

        self.present(actionSheetController, animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        pausePLayers()
        isOnView = false
        // myCache.removeAll()
        // dictionary.removeAllObjects()
    }

    override func viewDidAppear(_ animated: Bool) {
        playTheTruth()
    }


    func pausePLayers(){
        player1?.pause()
        player2?.pause()
    }
    func playerReady(_ player: Player) {
        //check if it will be played

        if isOnView {
        if player == player1 {
            if player2?.playbackState.description != "Playing"{
                if player1Turn {
            player.playFromBeginning()
                }
            }
        } else {
            if player1?.playbackState.description != "Playing"{
                if !player1Turn {
                    player.playFromBeginning()
                }
            }
        }
    }

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
        watch_list.append(player.id)
        if watch_list.count == 10{
            MolocateVideo.increment_watch(watch_list, completionHandler: { (data, response, error) in
                 DispatchQueue.main.async{
                    watch_list.removeAll()
                   // print("wathc incremented")
                 }
            })
        }
    }
    
    func textToImage(_ drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.white
        let textFont: UIFont = UIFont(name: "AvenirNext-Medium", size:35)!
        
        //Setup the image context using the passed image.
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(inImage.size, false, scale)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.draw(in: CGRect(x: 0, y: 0, width: inImage.size.width, height: inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRect(x: atPoint.x, y: atPoint.y, width: inImage.size.width, height: inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
  func animateLikeButton(){
        
                UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                    self.likeHeart.transform = CGAffineTransform(scaleX: 1.3, y: 1.3);
                    self.likeHeart.alpha = 0.8;
                   }) { (finished1) in
                     UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
                          self.likeHeart.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
                     }, completion: { (finished2) in
                       UIView.animate(withDuration: 0.3, delay: 0, options: .allowUserInteraction, animations: {
                         self.likeHeart.transform = CGAffineTransform(scaleX: 1.3, y: 1.3);
                       self.likeHeart.alpha = 0.0;
                     }, completion: { (finished3) in
                       self.likeHeart.transform = CGAffineTransform(scaleX: 1.0, y: 1.0);
             })
         })
         }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return MolocateDevice.size.width + 150
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sharer(_ sharer: FBSDKSharing!, didCompleteWithResults results: [AnyHashable: Any]!) {
       // print(results)
    }
    func sharerDidCancel(_ sharer: FBSDKSharing!) {
        
    }
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        
    }


}
