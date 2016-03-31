//  Added.swift
//  Molocate


import UIKit
import Haneke
import SDWebImage

class Tagged: UIViewController, UITableViewDelegate, UITableViewDataSource,PlayerDelegate {
    
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var myCache = Shared.dataCache
    var videoArray = [videoInf]()
    var username = ""
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-190)
        
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true
        // tableView.center = CGPointMake(screenSize.width/2,screenSize.height/2)
        tableView.frame         =   CGRectMake(0, 0 , screenSize.width, screenSize.height - 190);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
        
        print(self.username)
        Molocate.getUserVideos(user.username, type: "tagged", completionHandler: { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.videoArray = data!
                self.tableView.reloadData()
            }
        })
        
        
        
        
        
        
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
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = screenSize.width + 150
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if !pressedLike && !pressedFollow {
            let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
            
            cell.initialize(indexPath.row, videoInfo: videoArray[indexPath.row])
            
            cell.Username.addTarget(self, action: #selector(Tagged.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.placeName.addTarget(self, action: #selector(Tagged.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.profilePhoto.addTarget(self, action: #selector(Tagged.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != currentUser.username){
                cell.followButton.addTarget(self, action: #selector(Tagged.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }else{
                cell.followButton.hidden = true
            }
            
            cell.likeButton.addTarget(self, action: #selector(Tagged.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
            cell.commentCount.text = "\(videoArray[indexPath.row].commentCount)"
            cell.commentButton.addTarget(self, action: #selector(Tagged.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.reportButton.addTarget(self, action: #selector(Tagged.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.likeCount.addTarget(self, action: #selector(Tagged.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            let tap = UITapGestureRecognizer(target: self, action:#selector(MainController.doubleTapped(_:) ));
            tap.numberOfTapsRequired = 2
            cell.contentView.addGestureRecognizer(tap)
            cell.contentView.tag = indexPath.row
            
            myCache.fetch(URL:self.videoArray[indexPath.row].urlSta ).onSuccess{ NSData in
                dispatch_async(dispatch_get_main_queue()){
                    
                    
                    let url = self.videoArray[indexPath.row].urlSta.absoluteString
                    
                    let path = NSURL(string: DiskCache.basePath())!.URLByAppendingPathComponent("shared-data/original")
                    let cached = DiskCache(path: path.absoluteString).pathForKey(url)
                    let file = NSURL(fileURLWithPath: cached)
                    if indexPath.row % 2 == 1 {
                        //self.player1.stop()
                        self.player1.setUrl(file)
                        
                        self.player1.view.frame = cell.newRect
                        
                        cell.contentView.addSubview(self.player1.view)
                        //self.player1.playFromBeginning()
                    }else{
                        //self.player2.stop()
                        self.player2.setUrl(file)
                        self.player2.view.frame = cell.newRect
                        cell.contentView.addSubview(self.player2.view)
                        //self.player2.playFromBeginning()
                    }
                }
                
            }
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let rowHeight = screenSize.width + 138
        let y = scrollView.contentOffset.y
        
        let front = ceil(y/rowHeight)
        //print(front * rowHeight/2 - y)
        dispatch_async(dispatch_get_main_queue()){
            if front * rowHeight-rowHeight/2 - y < 0 {
                if (front) % 2 == 1{
                    
                    if self.player1.playbackState.description != "Playing" {
                        self.player2.stop()
                        self.player1.playFromBeginning()
                        //print("player1")
                    }
                }else{
                    if self.player2.playbackState.description != "Playing"{
                        self.player1.stop()
                        self.player2.playFromBeginning()
                        //print("player2")
                    }
                }
            }
        }
        
    }
    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
            
            if((indexPath.row%8 == 0)&&(nextU != nil)){
                
                Molocate.getExploreVideos(nextU, completionHandler: { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()){
                        for item in data!{
                            self.videoArray.append(item)
                            let newIndexPath = NSIndexPath(forRow: self.videoArray.count-1, inSection: 0)
                            self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                        }
                        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
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
                let controller:profileLocation = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.parentViewController!.view.bounds;
                controller.willMoveToParentViewController(self.parentViewController!)
                self.parentViewController!.view.addSubview(controller.view)
                self.parentViewController!.addChildViewController(controller)
                controller.didMoveToParentViewController(self.parentViewController!)
            }
        }
        
    }
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        pressedFollow = true
        print("followa basıldı at index path: \(buttonRow) ")
        
        Molocate.follow (videoArray[buttonRow].username){ (data, response, error) -> () in
            //print(data)
        }
    }
    
    func pressedLikeCount(sender: UIButton) {
        //print("____________________________--------------")
        //print(sender.tag)
        player1.stop()
        player2.stop()
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
        let controller:likeVideo = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.parentViewController!.view.bounds;
        controller.willMoveToParentViewController(self.parentViewController!)
        self.parentViewController!.view.addSubview(controller.view)
        self.parentViewController!.addChildViewController(controller)
        controller.didMoveToParentViewController(self.parentViewController!)
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
            
            
            self.videoArray[buttonRow].isLiked=0
            self.videoArray[buttonRow].likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            Molocate.unLikeAVideo(videoArray[buttonRow].id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
    }
    
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        videoIndex = buttonRow
        player1.stop()
        player2.stop()
        video_id = videoArray[videoIndex].id
        myViewController = "Tagged"
        
        Molocate.getComments(videoArray[buttonRow].id) { (data, response, error, count, next, previous) -> () in
            dispatch_async(dispatch_get_main_queue()){
                comments = data
                let controller:commentController = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
                controller.view.frame = self.parentViewController!.view.bounds;
                controller.willMoveToParentViewController(self.parentViewController!)
                self.parentViewController!.view.addSubview(controller.view)
                self.parentViewController!.addChildViewController(controller)
                controller.didMoveToParentViewController(self.parentViewController!)
                
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
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        player1.stop()
        player2.stop()
        Molocate.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.parentViewController!.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.parentViewController!.view.bounds;
                controller.willMoveToParentViewController(self.parentViewController!)
                self.parentViewController!.view.addSubview(controller.view)
                self.parentViewController!.addChildViewController(controller)
                controller.didMoveToParentViewController(self.parentViewController!)
                controller.username.text = user.username
                controller.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
                controller.AVc.username = user.username
                //controller.BVc.username = user.username
            }
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        //self.tableView.removeFromSuperview()
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }
    
    
    
    
    
}
