//
//  HomePageViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Foundation
import SDWebImage
import CoreLocation
import QuadratTouch
import MapKit
import SDWebImage
import Haneke

class HomePageViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate, UITextFieldDelegate {
//    
//    var isSearching = false
//    var locationManager: CLLocationManager!
    
    // @IBOutlet var venueTable: UITableView!
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var pressedLike: Bool = false
    var pressedFollow: Bool = false
    var refreshing: Bool = false
    var myCache = Shared.dataCache
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    var refreshControl:UIRefreshControl!
    @IBOutlet var searchText: UITextField!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet var collectionView: UICollectionView!
    
    var videoArray = [videoInf]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        session = Session.sharedSession()
//        session.logger = ConsoleLogger()
        
       // venueTable.hidden = true
        //searchText.delegate = self
        NSUserDefaults.standardUserDefaults().setObject(userToken, forKey: "userToken")
        self.player1 = Player()
        self.player1.delegate = self
        self.player1.playbackLoops = true
        
        self.player2 = Player()
        self.player2.delegate = self
        self.player2.playbackLoops = true
        
        self.tabBarController?.tabBar.hidden = true
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        
        tableView.allowsSelection = false
        let index = NSIndexPath(forRow: 0, inSection: 0)
//        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
//        collectionView.contentSize.width = screenSize.size.width * 2
//        collectionView.backgroundColor = swiftColor3
//        
//        
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        location = locationManager.location
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 3 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        
      
        
           // collectionView.hidden = false
            tableView.frame = CGRectMake(0, 88, screenSize.width, screenSize.height - 88)
            videoArray.removeAll()
            let url = NSURL(string: baseUrl + "video/api/news_feed/?category=all")!
            self.videoArray.removeAll()
            Molocate.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    self.videoArray = data!
                    self.tableView.reloadData()
                }
            })
        print("refresh")
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
    }
    
    func refresh(sender:AnyObject){
        
        refreshing = true
        let url = NSURL(string: baseUrl  + "video/api/news_feed/?category=all")
        self.player1.stop()
        self.player2.stop()
   
        SDImageCache.sharedImageCache().clearMemory()
        // tableView.hidden = true
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        //tableView.hidden = true
                Molocate.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                self.tableView.hidden = true
                self.videoArray.removeAll()
                self.videoArray = data!
                self.refreshControl.endRefreshing()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                self.tableView.hidden = false
                self.activityIndicator.removeFromSuperview()
                self.refreshing = false
                            }
            self.tableView.reloadData()

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
    
    func scrollViewEndDecelerating(scrollView: UIScrollView) {

        
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if(!refreshing) {
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
    }
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if atableView == tableView {
                return screenSize.width + 150
      
        } else {
            return 44
        }
    }
    
    
    func tableView(atableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if atableView == tableView{
        
            if( (indexPath.row%8 == 0)&&(nextU != nil)){
                
                Molocate.getExploreVideos(nextU, completionHandler: { (data, response, error) -> () in
                    dispatch_async(dispatch_get_main_queue()){
                        for item in data!{
                            self.videoArray.append(item)
                        }
                        self.tableView.reloadData()
                    }
                    
                })
            }
        }
        else {
            
        }
        
        
    }
    
    func tableView(atableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return videoArray.count
        
    }
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       // if atableView == tableView {
            
            if !pressedLike && !pressedFollow {
                let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
                let index = indexPath.row
                
                cell.initialize(indexPath.row, videoInfo:  videoArray[indexPath.row])
                
                cell.Username.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.placeName.addTarget(self, action: "pressedPlace:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.profilePhoto.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
                
                if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != currentUser.username){
                    cell.followButton.addTarget(self, action: "pressedFollow:", forControlEvents: UIControlEvents.TouchUpInside)
                }else{
                    cell.followButton.hidden = true
                }
                
                cell.likeButton.addTarget(self, action: "pressedLike:", forControlEvents: UIControlEvents.TouchUpInside)
                
                cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
                cell.commentCount.text = "\(videoArray[indexPath.row].commentCount)"
                cell.commentButton.addTarget(self, action: "pressedComment:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.reportButton.addTarget(self, action: "pressedReport:", forControlEvents: UIControlEvents.TouchUpInside)
                cell.likeCount.addTarget(self, action: "pressedLikeCount:", forControlEvents: UIControlEvents.TouchUpInside)
                
                
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
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        
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
            }
        }
        
    }
    
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        print("place e basıldı at index path: \(buttonRow) ")
        Molocate.getPlace(videoArray[buttonRow].locationID) { (data, response, error) -> () in
            
        }
        let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
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
        video_id = videoArray[sender.tag].id
        videoIndex = sender.tag
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
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        videoIndex = buttonRow
        video_id = videoArray[videoIndex].id
        
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        SDImageCache.sharedImageCache().clearMemory()
    }
    
    override func viewDidAppear(animated: Bool) {
        //print("bom")
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
        
    }
    
    @IBAction func sideBar(sender: AnyObject) {
        if(sideClicked == false){
            sideClicked = true
            NSNotificationCenter.defaultCenter().postNotificationName("openSideBar", object: nil)
        } else {
            sideClicked = false
            NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
        }
    }
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(sender: AnyObject) {
        
        if (isUploaded) {
            CaptionText = ""
//            if isSearching != true {
                self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
//            }
//            else {
//                self.cameraButton.image = UIImage(named: "technology3.png")
//                self.cameraButton.title = nil
//                self.isSearching = false
//                self.venueTable.hidden = true
//                self.searchText.resignFirstResponder()
//            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return  CGSize.init(width: screenSize.width * 2 / 9, height: 44)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : myCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! myCollectionViewCell
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = swiftColor2
        
        myCell.selectedBackgroundView = backgroundView
        myCell.layer.borderWidth = 0
        myCell.backgroundColor = swiftColor3
        myCell.myLabel?.text = categories[indexPath.row]
        myCell.frame.size.width = screenSize.width / 5
        myCell.myLabel.textAlignment = .Center
        
        return myCell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        //print(indexPath.row)
        
    }
    func changeFrame() {
        
        switch(choosedIndex){
        case 1:
            self.tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            self.collectionView.hidden = true
            
            break;
        default:
            self.tableView.frame = CGRectMake(0, 100, screenSize.width, screenSize.height - 100)
            self.collectionView.hidden = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
    }
    override func viewDidDisappear(animated: Bool) {
        SDImageCache.sharedImageCache().cleanDisk()
        SDImageCache.sharedImageCache().clearMemory()
        player1.stop()
        player1.removeFromParentViewController()
        player2.stop()
        player2.removeFromParentViewController()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //isSearching = true
        cameraButton.image = nil
        cameraButton.title = "Cancel"
//        venueTable.hidden = false
//        self.view.layer.addSublayer(venueTable.layer)
        
    }
    
//    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
//    {        venueTable.hidden = false
//        let whitespaceCharacterSet = NSCharacterSet.symbolCharacterSet()
//        let strippedString = searchText.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
//        
//        if self.location == nil {
//            return true
//        }
//        
//        currentTask?.cancel()
//        var parameters = [Parameter.query:strippedString]
//        parameters += self.location.parameters()
//        currentTask = session.venues.search(parameters) {
//            (result) -> Void in
//            if let response = result.response {
//                self.venues = response["venues"] as? [JSONParameters]
//                //print(self.venues)
//                self.venueTable.reloadData()
//            }
//        }
//        currentTask?.start()
//        
//        
//        return true
//    }
//    
    
    
}