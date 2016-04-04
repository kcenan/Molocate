//
//  oneVideo.swift
//  Molocate
//
//  Created by Kagan Cenan on 22.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class oneVideo: UIViewController,PlayerDelegate {
    var player = Player()
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        self.player = Player()
        self.player.delegate = self
        self.player.playbackLoops = true
        // Do any additional setup after loading the view.
    }
    
    
    
    func playerReady(player: Player) {
        self.player.playFromBeginning()
    }
    
    func playerPlaybackStateDidChange(player: Player) {
    }
    
    func playerBufferingStateDidChange(player: Player) {
    }
    
    func playerPlaybackWillStartFromBeginning(player: Player) {
    }
    
    func playerPlaybackDidEnd(player: Player) {
    }
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        
        cell.initialize(indexPath.row, videoInfo:  theVideo)
        
        cell.Username.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.placeName.addTarget(self, action: #selector(oneVideo.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.profilePhoto.addTarget(self, action: #selector(oneVideo.pressedUsername(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.commentCount.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        if(theVideo.isFollowing==0 && theVideo.username != currentUser.username){
            cell.followButton.addTarget(self, action: #selector(oneVideo.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            cell.followButton.hidden = true
        }
        
        cell.likeButton.addTarget(self, action: #selector(oneVideo.pressedLike(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        cell.likeCount.setTitle("\(theVideo.likeCount)", forState: .Normal)
        cell.commentCount.setTitle("\(theVideo.commentCount)", forState: .Normal)
        cell.commentButton.addTarget(self, action: #selector(oneVideo.pressedComment(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.reportButton.addTarget(self, action: #selector(oneVideo.pressedReport(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.likeCount.addTarget(self, action: #selector(oneVideo.pressedLikeCount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let tap = UITapGestureRecognizer(target: self, action:#selector(oneVideo.doubleTapped(_:) ));
        tap.numberOfTapsRequired = 2
        cell.contentView.addGestureRecognizer(tap)
        cell.contentView.tag = indexPath.row
        
        
        
        self.player.setUrl(theVideo.urlSta)
        
        self.player.view.frame = cell.newRect
        
        cell.contentView.addSubview(self.player.view)


        
        return cell
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        player.stop()
        
        Molocate.getUser(theVideo.username) { (data, response, error) -> () in
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
                choosedIndex = 0
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        player.stop()
        
        print("place e basıldı at index path: \(buttonRow) ")
        print("================================" )
        Molocate.getPlace(theVideo.locationID) { (data, response, error) -> () in
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
        theVideo.isFollowing = 1
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        Molocate.follow(theVideo.username){ (data, response, error) -> () in
            //print(data)
        }
        pressedFollow = false
    }
    
    
    func pressedLikeCount(sender: UIButton) {
        player.stop()
        
        video_id = theVideo.id
        videoIndex = sender.tag
        let controller:likeVideo = self.storyboard!.instantiateViewControllerWithIdentifier("likeVideo") as! likeVideo
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
    func doubleTapped(sender: UITapGestureRecognizer) {
        let buttonRow = sender.view!.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(theVideo.isLiked == 0){
            
            theVideo.isLiked=1
            theVideo.likeCount+=1
            
            
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            Molocate.likeAVideo(theVideo.id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            
            
            theVideo.isLiked=0
            theVideo.likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            Molocate.unLikeAVideo(theVideo.id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        print("like a basıldı at index path: \(buttonRow) ")
        pressedLike = true
        let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
        var indexes = [NSIndexPath]()
        indexes.append(indexpath)
        
        if(theVideo.isLiked == 0){
            sender.highlighted = true
            
            theVideo.isLiked=1
            theVideo.likeCount+=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            Molocate.likeAVideo(theVideo.id) { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }else{
            sender.highlighted = false
            
            theVideo.isLiked=0
            theVideo.likeCount-=1
            self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            
            
            Molocate.unLikeAVideo(theVideo.id){ (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                }
            }
        }
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        player.stop()
        
        videoIndex = buttonRow
        video_id = theVideo.id
        myViewController = "HomeController"
        Molocate.getComments(theVideo.id) { (data, response, error, count, next, previous) -> () in
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
        player.stop()
        
        Molocate.reportAVideo(theVideo.id) { (data, response, error) -> () in
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



}
