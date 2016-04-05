//
//  profileLocation.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import SDWebImage
import Haneke
import AVFoundation
class profileLocation: UIViewController,UITableViewDelegate , UITableViewDataSource , UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate {
    
    var lastOffset:CGPoint!
    var lastOffsetCapture:NSTimeInterval!
    var isScrollingFast:Bool = false
    var pointNow:CGFloat!
    var isSearching = false
    var direction = 0
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var LocationTitle: UILabel!

    @IBOutlet var videosTitle: UILabel!
    @IBOutlet var address: UILabel!
    @IBOutlet var locationName: UILabel!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var videoCount: UILabel!
    var videoArray = [videoInf]()
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var followButton: UIBarButtonItem!
   
    @IBOutlet var toolBar: UIToolbar!
    @IBAction func followButton(sender: AnyObject) {
        
        if(thePlace.is_following == 0){
            thePlace.is_following = 1
            followButton.image = UIImage(named: "unfollow");
            Molocate.followAPlace(thePlace.id) { (data, response, error) in
                currentUser.following_count += 1
            }
        }else{
            followButton.image = UIImage(named: "follow");
            thePlace.is_following = 0
            Molocate.unfollowAPlace(thePlace.id) { (data, response, error) in
                currentUser.following_count -= 1
            }
        }
        
    }
    @IBOutlet var followerCount: UIButton!
    
    @IBAction func followersButton(sender: AnyObject) {
    }
    
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var refreshing: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var refreshControl:UIRefreshControl!
    
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         try!  AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        self.view.backgroundColor = swiftColor3
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        self.followerCount.setTitle("\(thePlace.following_count)", forState: UIControlState.Normal)
        self.locationName.text = thePlace.name
        self.LocationTitle.text = thePlace.name
        self.address.text = thePlace.address
        self.videoCount.text = "Videos(\(thePlace.video_count))"
        self.videoArray = thePlace.videoArray
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true
        
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
        if(thePlace.picture_url.absoluteString != ""){
            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
        }else{
            profilePhoto.image = UIImage(named: "pin")!
        }
        
        if self.videoArray.count == 0 {
            tableView.hidden = true
            followButton.tintColor = UIColor.clearColor()
            followButton.enabled = false
        }
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        lastOffset = CGPoint(x: 0, y: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])
            
            cell.Username.addTarget(self, action: #selector(profileLocation.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(profileLocation.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(profileLocation.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != currentUser.username){
                cell.followButton.addTarget(self, action: #selector(profileLocation.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(profileLocation.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.addTarget(self, action: #selector(profileLocation.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.commentCount.setTitle("\(videoArray[indexPath.row].commentCount)", forState: .Normal)
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            
            cell.commentButton.addTarget(self, action: #selector(profileLocation.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(profileLocation.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(profileLocation.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            let playtap = UITapGestureRecognizer(target: self, action:#selector(MainController.playTapped(_:) ));
            playtap.numberOfTapsRequired = 1
            cell.contentView.addGestureRecognizer(playtap)
            
            let thumbnailURL = self.videoArray[indexPath.row].thumbnailURL
            if(thumbnailURL.absoluteString != ""){
                cell.cellthumbnail.sd_setImageWithURL(thumbnailURL)
                print("burda")
            }else{
                cell.cellthumbnail.image = UIImage(named: "Mole")!
            }
            
            var trueURL = NSURL()
            if !isScrollingFast {
                cell.hasPlayer = true
            if dictionary.objectForKey(self.videoArray[indexPath.row].id) != nil {
                trueURL = dictionary.objectForKey(self.videoArray[indexPath.row].id) as! NSURL
            } else {
                trueURL = self.videoArray[indexPath.row].urlSta
                dispatch_async(dispatch_get_main_queue()) {
                        myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                        let url = self.videoArray[indexPath.row].urlSta.absoluteString
                        let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                        let cached = DiskCache(path: path.absoluteString).pathForKey(url)
                        let file = NSURL(fileURLWithPath: cached)
                        dictionary.setObject(file, forKey: self.videoArray[indexPath.row].id)
                    }
                }
            }
            
            if indexPath.row % 2 == 1 {
                
                self.player1.setUrl(trueURL)
                self.player1.view.frame = cell.newRect
                cell.contentView.addSubview(self.player1.view)
                
            }else{
                
                self.player2.setUrl(trueURL)
                self.player2.view.frame = cell.newRect
                cell.contentView.addSubview(self.player2.view)
            }
            
            }
//            }
            return cell
        }else{
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! videoCell
            if pressedLike {
                pressedLike = false
                cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
                
                if(videoArray[indexPath.row].isLiked == 0) {
                    cell.likeButton.setBackgroundImage(UIImage(named: "Like.png"), forState: UIControlState.Normal)
                }else{
                    cell.likeButton.setBackgroundImage(UIImage(named: "LikeFilled.png"), forState: UIControlState.Normal)
                    cell.likeButton.tintColor = UIColor.whiteColor()
                }
            }else if pressedFollow{
                pressedFollow = true
                
                cell.followButton.hidden = videoArray[indexPath.row].isFollowing == 1 ? true:false
                
            }
            return cell
        }
        

    }
    
    func playTapped(sender: UITapGestureRecognizer) {
        let row = sender.view!.tag
        print("like a basıldı at index path: \(row) ")
        if (row) % 2 == 1{
            
            if self.player1.playbackState.description != "Playing" {
                self.player1.playFromCurrentTime()
            }else{
                self.player1.stop()
            }
            
        }else{
            if self.player2.playbackState.description != "Playing" {
                self.player2.playFromCurrentTime()
            }else{
                self.player2.stop()
            }
        }
    }
    

    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        player1.stop()
        player2.stop()
        Molocate.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                controller.username.text = user.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
                controller.AVc.username = user.username
                controller.BVc.username = user.username
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        print("place e basıldı at index path: \(buttonRow) ")
        print("================================" )
        Molocate.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
        
    }
  
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        print("followa basıldı at index path: \(buttonRow) ")
        self.videoArray[buttonRow].isFollowing = 1
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        Molocate.follow(videoArray[buttonRow].username){ (data, response, error) -> () in
            currentUser.following_count += 1
        }
        pressedFollow = false
    }
    
    
    func pressedLikeCount(sender: UIButton) {
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        player1.stop()
        player2.stop()
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(videoArray[buttonRow].isLiked == 0){
            sender.highlighted = true
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            Molocate.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
               pressedLike = false
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
        myViewController = "HomeController"
        Molocate.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                
                print("comment e basıldı at index path: \(buttonRow)")
            }
        }
        
        
        
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
        player1.stop()
        player2.stop()
        Molocate.reportAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            print(data)
        }
        print("pressedReport at index path: \(buttonRow)")
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            
        }
        
        actionSheetController.addAction(cancelAction)
        
        let reportVideo: UIAlertAction = UIAlertAction(title: "Report the Video", style: .Default) { action -> Void in
            
            print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }

    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }
    
    func playerReady(player: Player) {
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
    override func viewDidAppear(animated: Bool) {
        self.player2.playFromBeginning()
    }
    
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        pointNow = scrollView.contentOffset.y
        lastOffsetCapture = NSDate().timeIntervalSinceReferenceDate
        
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        
        
        if (scrollView.contentOffset.y<pointNow) {
            direction = 0
        } else if (scrollView.contentOffset.y>pointNow) {
            direction = 1
        }
        
        var currentOffset = scrollView.contentOffset
        var currentTime = NSDate().timeIntervalSinceReferenceDate   // [NSDate timeIntervalSinceReferenceDate];
        
        var timeDiff = currentTime - lastOffsetCapture;
        if(timeDiff > 0.1) {
            var distance = currentOffset.y - lastOffset.y;
            //The multiply by 10, / 1000 isn't really necessary.......
            var scrollSpeedNotAbs = (distance * 10) / 1000 //in pixels per millisecond
            
            var scrollSpeed = fabsf(Float(scrollSpeedNotAbs));
            if (scrollSpeed > 0.5) {
                isScrollingFast = true
                print("hızlı")
                
            } else {
                isScrollingFast = false
                var ipArray = [NSIndexPath]()
                for item in self.tableView.indexPathsForVisibleRows!{
                    let cell = self.tableView.cellForRowAtIndexPath(item) as! videoCell
                    if !cell.hasPlayer {
                        ipArray.append(item)
                    }
                }
                if ipArray.count != 0 {
                    self.tableView.reloadRowsAtIndexPaths(ipArray, withRowAnimation: .None)
                }

                
            }
            
            lastOffset = currentOffset;
            lastOffsetCapture = currentTime;
        }
        
        if (scrollView.contentOffset.y > 10) && (scrollView.contentOffset.y+scrollView.frame.height < scrollView.contentSize.height
            ) && !isScrollingFast
        {
            let longest = scrollView.contentOffset.y + scrollView.frame.height
            if direction == 1 {
                ////print("down")
                let cellap = scrollView.contentOffset.y - self.tableView.visibleCells[0].center.y
                ////print(cellap)
                let row = self.tableView.indexPathsForVisibleRows![0].row+1
                if cellap > 0 {
                    
                    if (row) % 2 == 1{
                        //self.tableView.visibleCells[1].reloadInputViews()
                        if self.player1.playbackState.description != "Playing" {
                            self.player2.stop()
                            self.player1.playFromBeginning()
                            print(self.tableView.indexPathsForVisibleRows![0].row)
                            ////print("player1")
                        }
                    }else{
                        if self.player2.playbackState.description != "Playing"{
                            self.player1.stop()
                            self.player2.playFromBeginning()
                            ////print("player2")
                        }
                    }
                }
            }
                
                
            else {
                ////print("up")
                
                let cellap = longest - self.tableView.visibleCells[0].center.y-150-self.view.frame.width
                //print(cellap)
                let row = self.tableView.indexPathsForVisibleRows![0].row
                if cellap < 0 {
                    
                    if (row) % 2 == 1{
                        
                        if self.player1.playbackState.description != "Playing" {
                            self.player2.stop()
                            self.player1.playFromBeginning()
                            ////print("player1")
                        }
                    }else{
                        if self.player2.playbackState.description != "Playing"{
                            self.player1.stop()
                            self.player2.playFromBeginning()
                            ////print("player2")
                        }
                    }
                }
            }
        }
        
        
        
        
        
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(videoArray[buttonRow].isLiked == 0){
            
            self.videoArray[buttonRow].isLiked=1
            self.videoArray[buttonRow].likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            Molocate.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            
              pressedLike = false
//            self.videoArray[buttonRow].isLiked=0
//            self.videoArray[buttonRow].likeCount-=1
//            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
//            
//            
//            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
//                dispatch_async(dispatch_get_main_queue()){
//                    print(data)
//                }
//            }
        }
    }

    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            
            if((indexPath.row%8 == 0)&&(nextU != nil)&&(!exploreInProcess)){
                
                Molocate.getExploreVideos(nextU, completionHandler: { (data, response, error) -> () in
                    exploreInProcess = true
                    dispatch_async(dispatch_get_main_queue()){
                        
                        for item in data!{
                            self.videoArray.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.videoArray.count-1, inSection: 0)
                            atableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                            
                        }
                        
                        exploreInProcess = false
                    }
                    
                })
                
                
            }
        }
        else {
            
        }
        
        
    }

    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
