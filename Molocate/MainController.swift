import UIKit
import Foundation
import CoreLocation
//import AVFoundation
//import AVKit
//import MobileCoreServices
//import ObjectiveC

//struct Videos{
//    var Asset : AVURLAsset
//    var playerItem: AVPlayerItem
//    var player: AVPlayer
//    var layer: AVPlayerLayer
//
//    init(){
//        self.Asset = AVURLAsset(URL: NSURL(string: "")!)
//        self.playerItem = AVPlayerItem(asset: self.Asset);
//        self.player = AVPlayer(playerItem: self.playerItem);
//        self.layer = AVPlayerLayer(player: self.player)
//    }
//
//    init(url: String){
//        self.Asset = AVURLAsset(URL: NSURL(string: url)!)
//        self.playerItem = AVPlayerItem(asset: self.Asset);
//        self.player = AVPlayer(playerItem: self.playerItem);
//        self.layer = AVPlayerLayer(player: self.player)
//
//    }
//
//    func Play(){
//        self.player.play()
//    }
//    func Pause(){
//        self.player.pause()
//    }
//    func getLayer() -> AVPlayerLayer{
//        return AVPlayerLayer(player: self.player)
//    }
//
//    func isSet() -> Bool{
//        if self.Asset.URL.absoluteString == "" {
//            //print("false")
//            return false
//        }
//        return true
//    }
//}

var sideClicked = false
var profileOn = 0
var category = "All"
let swiftColor = UIColor(netHex: 0xEB2B5D)
let swiftColor2 = UIColor(netHex: 0xC92451)
let swiftColor3 = UIColor(red: 249/255, green: 223/255, blue: 230/255, alpha: 1)

class MainController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate {
    
    var locationManager: CLLocationManager!
    
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var videoArray = [videoInf]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var players = ["Didier Drogba", "Elmander", "Harry Kewell", "Milan Baros", "Wesley Sneijder"]
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    var numbers = ["11", "9","19", "15", "10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.tableView = UITableView()
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
        
        let index = NSIndexPath(forRow: 0, inSection: 0)
        self.collectionView.selectItemAtIndexPath(index, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
        collectionView.contentSize.width = screenSize.size.width * 2
        collectionView.backgroundColor = swiftColor3
        
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 3 && profileOn == 1){
            NSNotificationCenter.defaultCenter().postNotificationName("closeProfile", object: nil)
        }
        
        switch(choosedIndex){
        case 0:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        case 1:
            collectionView.hidden = false
            tableView.frame = CGRectMake(0, 88, screenSize.width, screenSize.height - 88)
            videoArray.removeAll()
            let url = NSURL(string: "http://molocate.elasticbeanstalk.com/video/api/explore/all/")!
            self.videoArray.removeAll()
            Molocate.getExploreVideos(url, completionHandler: { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    self.videoArray = data!
                    self.tableView.reloadData()
                }
            })
            break
        case 2:
            tableView.reloadData()
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            
            break
        case 3:
            
            //NSNotificationCenter.defaultCenter().postNotificationName("openProfile", object: nil)
            profileOn = 1
            NSNotificationCenter.defaultCenter().postNotificationName("goProfile",object:nil)
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        default:
            collectionView.hidden = true
            tableView.frame = CGRectMake(0, 44, screenSize.width, screenSize.height - 44)
            break
        }
        
        
        
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
        
        //        let rowHeight = screenSize.width + 138
        //        let y = scrollView.contentOffset.y
        //        let front = ceil(y/rowHeight)
        //        if front * rowHeight - y > rowHeight/3 {
        //            if (ceil(y) - 1 ) % 2 == 1{
        //                player1.playFromBeginning()
        //                print("player1")
        //            }else{
        //                player2.playFromBeginning()
        //                 print("player2")
        //            }
        //        }
        
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 0
        
        switch(choosedIndex)
        {
        case 0:
            rowHeight = screenSize.width + 138
            return rowHeight
            
        case 1:
            
            rowHeight = screenSize.width + 138 //screenSize.width + 90
            return rowHeight
            
        case 2:
            rowHeight = 44
            return rowHeight
            
        default:
            rowHeight = 44
            return rowHeight
        }
    }
    
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //let videocell = cell as! videoCell
        
        //NSNotificationCenter.defaultCenter().removeObserver(videocell)
        //        if(videocell.player.isSet()){
        //            videocell.player.Pause()
        //            videocell.player.layer.removeFromSuperlayer()
        //
        //            //videocell.player = Videos()
        //            videocell.player.layer.removeFromSuperlayer()
        //        }
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")
        cell.initialize(indexPath.row, username: videoArray[index].username, location: videoArray[index].location , likeCount: videoArray[index].likeCount, commentCount: videoArray[index].commentCount
            , caption: videoArray[index].caption)
        cell.Username.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.placeName.addTarget(self, action: "pressedPlace:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.profilePhoto.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        if(videoArray[indexPath.row].isFollowing==0 && videoArray[indexPath.row].username != currentUser.username){
            cell.followButton.addTarget(self, action: "pressedFollow:", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            cell.followButton.hidden = true
        }
        cell.likeButton.addTarget(self, action: "pressedLike:", forControlEvents: UIControlEvents.TouchUpInside)

        if(videoArray[indexPath.row].isLiked == 0) {
            //different symbols
        }else{
            cell.likeButton.backgroundColor = UIColor.whiteColor()
        }
        cell.likeCount.text = "\(videoArray[indexPath.row].likeCount)"
        cell.commentCount.text = "\(videoArray[indexPath.row].commentCount)"
        cell.commentButton.addTarget(self, action: "pressedComment:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.reportButton.addTarget(self, action: "pressedReport:", forControlEvents: UIControlEvents.TouchUpInside)
        

        
        dispatch_async(dispatch_get_main_queue()){
        if indexPath.row % 2 == 1 {
            //self.player1.stop()
            self.player1.setUrl(self.videoArray[indexPath.row].urlSta)
            self.player1.view.frame = cell.newRect
            cell.contentView.addSubview(self.player1.view)
            //self.player1.playFromBeginning()
        }else{
            //self.player2.stop()
            self.player2.setUrl(self.videoArray[indexPath.row].urlSta)
            self.player2.view.frame = cell.newRect
            cell.contentView.addSubview(self.player2.view)
            //self.player2.playFromBeginning()
        }
        }
        
        //        if(!cell.player.isSet()){
        //            cell.player = Videos(url: videoArray[indexPath.row].urlSta.absoluteString)
        //            cell.player.layer.frame = cell.newRect
        //            cell.layer.addSublayer(cell.player.layer)
        //            cell.player.Play()
        //        }
        return cell
    }
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        Molocate.getUser(videoArray[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                controller.username.text = data.username
                controller.followingsCount.setTitle("\(data.following_count)", forState: .Normal)
                controller.followersCount.setTitle("\(data.follower_count)", forState: .Normal)
                controller.user = data
            }
        }
        
    }
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
        print("place e basıldı at index path: \(buttonRow) ")
        let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        print("followa basıldı at index path: \(buttonRow) ")
        
        Molocate.follow (videoArray[buttonRow].username){ (data, response, error) -> () in
            print(data)
        }
    }
    func pressedLike(sender: UIButton) {
        let buttonRow = sender.tag
        print("like a basıldı at index path: \(buttonRow) ")
        if(videoArray[buttonRow].isLiked == 0){
            sender.highlighted = true
            Molocate.likeAVideo(videoArray[buttonRow].id) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                print(data)
                self.videoArray[buttonRow].likeCount+=1
                self.videoArray[buttonRow].isLiked=1
                let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
                var indexes = [NSIndexPath]()
                indexes.append(indexpath)
                self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)
            }
        }
        }else{
            sender.highlighted = false
            Molocate.unLikeAVideo(videoArray[buttonRow].id, completionHandler: { (data, response, error) -> () in
                dispatch_async(dispatch_get_main_queue()){
                    print(data)
                    
                    self.videoArray[buttonRow].likeCount-=1
                    self.videoArray[buttonRow].isLiked=0
                    let indexpath = NSIndexPath(forRow: buttonRow, inSection: 0)
                    var indexes = [NSIndexPath]()
                    indexes.append(indexpath)
                    self.tableView.reloadRowsAtIndexPaths(indexes, withRowAnimation: UITableViewRowAnimation.None)

                }
            })
        }
    }
    func pressedComment(sender: UIButton) {
        let buttonRow = sender.tag
        print("comment e basıldı at index path: \(buttonRow)")
    }
    
    
    func pressedReport(sender: UIButton) {
        let buttonRow = sender.tag
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
    }
    
    override func viewDidAppear(animated: Bool) {
        print("bom")
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
    
    
    @IBAction func openCamera(sender: AnyObject) {
        self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
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
        
        print(indexPath.row)
        
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
        //self.tableView.removeFromSuperview()
    }
}