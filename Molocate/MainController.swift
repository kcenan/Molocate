import UIKit
import Foundation
import CoreLocation
import QuadratTouch
import MapKit



//video caption ve süre eklenecek, report send edilecek
var sideClicked = false
var profileOn = 0
var category = "All"
let swiftColor = UIColor(netHex: 0xEB2B5D)
let swiftColor2 = UIColor(netHex: 0xC92451)
let swiftColor3 = UIColor(red: 249/255, green: 223/255, blue: 230/255, alpha: 1)

class MainController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate,PlayerDelegate, UITextFieldDelegate {
    var isSearching = false
    var locationManager: CLLocationManager!
    
    @IBOutlet var venueTable: UITableView!
    var videoData:NSMutableData!
    var connection:NSURLConnection!
    var response:NSHTTPURLResponse!
    var pendingRequests:NSMutableArray!
    var player1:Player!
    var player2: Player!
    var session: Session!
    var location: CLLocation!
    var venues: [JSONParameters]!
    let distanceFormatter = MKDistanceFormatter()
    var currentTask: Task?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var searchText: UITextField!
    
    @IBOutlet var collectionView: UICollectionView!
    
    var videoArray = [videoInf]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var players = ["Didier Drogba", "Elmander", "Harry Kewell", "Milan Baros", "Wesley Sneijder"]
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    var numbers = ["11", "9","19", "15", "10"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = Session.sharedSession()
        session.logger = ConsoleLogger()
        
        venueTable.hidden = true
        searchText.delegate = self
       
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
        locationManager.startUpdatingLocation()
        location = locationManager.location
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
            let url = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/all/")!
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
    
    func tableView(atableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if atableView == tableView {
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
        if atableView == tableView {
        return videoArray.count
        } else {
            if let venues = self.venues {
                return venues.count
            }
            return 0
        }
    }
    
    func tableView(atableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if atableView == tableView {
        let index = indexPath.row
        let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "customCell")

        cell.initialize(indexPath.row, username: videoArray[index].username, location: videoArray[index].location , likeCount: videoArray[index].likeCount, commentCount: videoArray[index].commentCount
            , caption: videoArray[index].caption, profilePic:  videoArray[index].userpic
        )
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
        cell.likeCount.setTitle("\(videoArray[indexPath.row].likeCount)", forState: .Normal)
        cell.commentCount.text = "\(videoArray[indexPath.row].commentCount)"
        cell.commentButton.addTarget(self, action: "pressedComment:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.reportButton.addTarget(self, action: "pressedReport:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.likeCount.addTarget(self, action: "pressedLikeCount:", forControlEvents: UIControlEvents.TouchUpInside)

        
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
            
        } else {
            let cell = venueTable.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            let venue = venues[indexPath.row]
            if let venueLocation = venue["location"] as? JSONParameters {
                var detailText = ""
                if let distance = venueLocation["distance"] as? CLLocationDistance {
                    detailText = distanceFormatter.stringFromDistance(distance)
                }
                if let address = venueLocation["address"] as? String {
                    detailText = detailText +  " - " + address
                }
                cell.detailTextLabel?.text = detailText
            }
            cell.textLabel?.text = venue["name"] as? String
            return cell
        }
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
    
    func pressedLikeCount(sender: UIButton) {
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
        let controller:commentController = self.storyboard!.instantiateViewControllerWithIdentifier("commentController") as! commentController
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
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
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(sender: AnyObject) {
        if isSearching != true {
        self.parentViewController!.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
        } else {
            self.cameraButton.image = UIImage(named: "technology3.png")
            self.cameraButton.title = nil
            self.isSearching = false
            self.venueTable.layer.removeFromSuperlayer()
            //self.searchText.resignFirstResponder()
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
//        if isSearching == true {
//            self.cameraButton.image = UIImage(named: "technology3.png")
//            self.cameraButton.title = nil
//            self.isSearching = false
//            self.venueTable.layer.removeFromSuperlayer()
//            self.searchText.resignFirstResponder()
//        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        isSearching = true
        cameraButton.image = nil
        cameraButton.title = "Cancel"
        venueTable.hidden = false
        self.view.layer.addSublayer(venueTable.layer)
        
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        venueTable.hidden = false
        let whitespaceCharacterSet = NSCharacterSet.whitespaceCharacterSet()
        let strippedString = searchText.text!.stringByTrimmingCharactersInSet(whitespaceCharacterSet)
        
        if self.location == nil {
            return true
        }
        
        currentTask?.cancel()
        var parameters = [Parameter.query:strippedString]
        parameters += self.location.parameters()
        currentTask = session.venues.search(parameters) {
            (result) -> Void in
            if let response = result.response {
                self.venues = response["venues"] as? [JSONParameters]
                //print(self.venues)
                self.venueTable.reloadData()
            }
        }
        currentTask?.start()
        
        
        return true
    }

}