//
//  profileVenue.swift
//  
//
//  Created by Kagan Cenan on 28.07.2016.
//
//

import UIKit
import SDWebImage
import Haneke
import AVFoundation
import MapKit

class profileVenue: UIViewController, UICollectionViewDelegateFlowLayout,NSURLConnectionDataDelegate, TimelineControllerDelegate, UIGestureRecognizerDelegate{

    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var classPlace = MolePlace()
    var tableController: TimelineController!
    var page = 1
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var followButton: UIBarButtonItem!
    @IBOutlet var titleToolbar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        thePlace = MolePlace()
        tableView.estimatedRowHeight = 250
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.allowsSelection = false
        //tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.clear
        tableView.isPagingEnabled = true
        titleToolbar.title = thePlace.name
        tableController = self.storyboard?.instantiateViewController(withIdentifier: "timelineController") as! TimelineController
        tableController.type = "profileVenue"
        tableController.placeId = thePlace.id
        tableController.videoArray = thePlace.videoArray
        tableController.delegate = self
        tableController.view.layer.zPosition = 0
        self.navigationController?.hidesBarsOnSwipe = true
        //self.view.addSubview(tableController.view)
        //self.addChildViewController(tableController);
        tableController.tableView.isScrollEnabled = false
        tableController.tableView.bounces = false 
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(profileUser.adjustTable))
        gesture.delegate = self
        gesture.direction = .down
        self.view.addGestureRecognizer(gesture)
        
        initGui()
        
        
        UIApplication.shared.endIgnoringInteractionEvents()
     
        // Do any additional setup after loading the view.
    }
    
    func adjustTable() {
        
        if page == 2 {
            
                if tableController.tableView.contentOffset.y == 0 {
                    tableController.tableView.isScrollEnabled = false
                    self.tableView.isPagingEnabled = true
                    self.navigationController?.setNavigationBarHidden(false, animated: true)
                    if classPlace.video_count > 1 {
                    self.tableView.setContentOffset(CGPoint(x: 0,y:0), animated: true)
                    }
                }
            
            
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    func initGui(){
      
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func followButton(_ sender: AnyObject) {
        let indexPath = IndexPath(row: 1, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! profileVenue2ndCell
        if(thePlace.is_following == 0){
            thePlace.is_following = 1
            followButton.image = UIImage(named: "unfollow");
            MolocatePlace.followAPlace(thePlace.id) { (data, response, error) in
                MoleCurrentUser.following_count += 1
                DispatchQueue.main.async {
                    thePlace.follower_count += 1
                    cell.numberFollower.text = "\(thePlace.follower_count)"
                    
                }
            }
            
        }else{ let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Takibi bırakmak istediğine emin misin?", preferredStyle: .actionSheet)
            
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            //Create and add first option action
            let takePictureAction: UIAlertAction = UIAlertAction(title: "Takibi Bırak", style: .default)
            { action -> Void in
                self.followButton.image = UIImage(named: "follow");
                thePlace.is_following = 0
                MoleCurrentUser.following_count -= 1
                MolocatePlace.unfollowAPlace(thePlace.id) { (data, response, error) in
                    DispatchQueue.main.async {
                        thePlace.follower_count -= 1
                        cell.numberFollower.text = "\(thePlace.follower_count)"
                    }
                    
                }
                
            }
            actionSheetController.addAction(takePictureAction)
            //We need to provide a popover sourceView when using it on iPad
            actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
            
            //Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
            
        }
        

    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView == self.tableView {
            
            if (scrollView.contentSize.height-scrollView.contentOffset.y < MolocateDevice.size.height+70) {
                tableController.tableView.isScrollEnabled = true
                tableView.isPagingEnabled = false
                page = 2
            } else {
                tableController.tableView.isScrollEnabled = false
                tableView.isPagingEnabled = true
                page = 1
            }
        }
        
        
    }

   
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
//        if tableView == tableController{
//            return 200
//        }
//        else{
        if indexPath.row == 0{
            return UITableViewAutomaticDimension
        }
        else {
            if indexPath.row == 1 {
            return 76
                
            } else {
                return MolocateDevice.size.height-25
            }
        }
 //       }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! profileVenue1stCell
           
            let longitude :CLLocationDegrees = thePlace.lon
            let latitude :CLLocationDegrees = thePlace.lat
            let span = MKCoordinateSpanMake(0.005, 0.005)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
             cell.mapView.setRegion(region, animated: false)
             cell.mapView.isUserInteractionEnabled = false
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
             cell.mapView.addAnnotation(annotation)
            cell.goMapButton.addTarget(self, action: #selector(profileVenue.launchMap(_:)), for: .touchUpInside)
            cell.nameVenue.text = thePlace.name
            self.navigationController!.topViewController!.title = thePlace.name
            //LocationTitle.text = thePlace.name
            cell.adressVenue.text = thePlace.address
            
            return cell
        }
            
        else  {
            if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! profileVenue2ndCell
            cell.numberVideo.text = "\(thePlace.video_count)"
            cell.numberFollower.text = "\(thePlace.follower_count)"
            
        
            return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath) as! profileVenue3rdCell
                cell.backgroundColor = UIColor.black
                tableController.view.frame = cell.contentView.frame
                cell.addSubview(tableController.view)
                return cell
            }
            
        }
    }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 3
        }
    
    func launchMap(_ sender: UIButton) {
        
        let controller:oneMap = self.storyboard!.instantiateViewController(withIdentifier: "oneMap") as! oneMap
        controller.classPlace = classPlace
        navigationController?.pushViewController(controller, animated: true)
        
//        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        
//        
//        let cancelAction: UIAlertAction = UIAlertAction(title: "Vazgeç", style: .Cancel) { action -> Void in
//            //Just dismiss the action sheet
//        }
//        actionSheetController.addAction(cancelAction)
//        //Create and add first option action
//        let takePictureAction: UIAlertAction = UIAlertAction(title: "Haritaya Yönlendir", style: .Default)
//        { action -> Void in
//            
//            self.openMapForPlace()
//            
//        }
//        actionSheetController.addAction(takePictureAction)
//        //We need to provide a popover sourceView when using it on iPad
//        actionSheetController.popoverPresentationController?.sourceView = sender as? UIView
//        
//        //Present the AlertController
//        self.presentViewController(actionSheetController, animated: true, completion: nil)
 
    }

    
  
    
    
    func RefreshGuiWithData(){
        
        if(thePlace.is_following==0 ){
            
        }else{
            followButton.image = UIImage(named: "unfollow");
        }
//        followerCount.setTitle("\(thePlace.follower_count)", forState: UIControlState.Normal)
//        locationName.text = thePlace.name
//        self.navigationController!.topViewController!.title = thePlace.name
//        address.text = thePlace.address
//        videoCount.text = "Videos(\(thePlace.video_count))"
        
//        if(thePlace.is_following==0 ){
//            
//        }else{
//            followButton.image = UIImage(named: "unfollow");
//        }
//        //        if(thePlace.picture_url.absoluteString != ""){
//        //            profilePhoto.sd_setImageWithURL(thePlace.picture_url)
//        //        }else{
//        //            profilePhoto.image = UIImage(named: "pin")!
//        //        }
//        
//        if self.tableController.videoArray.count == 0 {
//            self.tableController.tableView.hidden = true
//            followButton.tintColor = UIColor.clearColor()
//            followButton.enabled = false
//        }else{
//            followButton.tintColor = UIColor.whiteColor()
//            followButton.enabled = true
//            self.tableController.tableView.hidden = false
//        }
//
//        //mekanın koordinatları eklenecek
//        let longitude :CLLocationDegrees = thePlace.lon
//        let latitude :CLLocationDegrees = thePlace.lat
//        let span = MKCoordinateSpanMake(0.005, 0.005)
//        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
//        map.setRegion(region, animated: false)
//        map.userInteractionEnabled = false
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = location
//        map.addAnnotation(annotation)
        //                let searchTask = Session.sharedSession().venues.get(classPlace.id) {
        //                    (result) -> Void in
        //                    dispatch_async(dispatch_get_main_queue(), {
        //                        if let response = result.response {
        //
        //                            let venue = response["venue"]
        //                            let hereNow = venue!["hereNow"]!
        //                            //self.hereNowCount =
        //                            print(venue)
        //                            ///self.tableView.reloadData()
        //
        //                        }
        //                        })
        //                }
        //                searchTask.start()

        tableController.videoArray = thePlace.videoArray
        self.tableController.tableView.reloadData()
        self.tableView.reloadData()
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = false
        (self.parent?.parent?.parent as! ContainerController).scrollView.isScrollEnabled = false
        
    }
    
    
    func pressedUsername(_ username: String, profilePic: URL?, isFollowing: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let controller:profileUser = self.storyboard!.instantiateViewController(withIdentifier: "profileUser") as! profileUser
        
        if username != MoleCurrentUser.username{
            controller.isItMyProfile = false
        }else{
            controller.isItMyProfile = true
        }
        
        controller.classUser.username = username
        controller.classUser.profilePic = profilePic
        controller.classUser.isFollowing = isFollowing
        
        
        self.navigationController?.pushViewController(controller, animated: true)
        MolocateAccount.getUser(username) { (data, response, error) -> () in
            DispatchQueue.main.async{
                //DBG: If it is mine profile?
                if data.username != "" {
                    user = data
                    controller.classUser = data
                    controller.RefreshGuiWithData()
                }
                
                //choosedIndex = 0
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    
    func pressedPlace(_ placeId: String, Row: Int) {
        
        //Empty it isnot logical
    }
    
    func pressedComment(_ videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        video_id = videoId
        videoIndex = Row
        myViewController = "MainController"
        
        
        let controller:commentController = self.storyboard!.instantiateViewController(withIdentifier: "commentController") as! commentController
        
        comments.removeAll()
        MolocateVideo.getComments(videoId) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                comments = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.removeFromSuperview()
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
        
    }
    
    func pressedLikeCount(_ videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        video_id = videoId
        videoIndex = Row
        
        let controller:likeVideo = self.storyboard!.instantiateViewController(withIdentifier: "likeVideo") as! likeVideo
        
        MolocateVideo.getLikes(videoId) { (data, response, error, count, next, previous) -> () in
            DispatchQueue.main.async{
                controller.users = data
                controller.tableView.reloadData()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
            
        }
        
        //DBG: Burda  likeları çağır,
        //Her gectigimiz ekranda activity indicatorı goster
        self.navigationController?.pushViewController(controller, animated: true)
        
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


