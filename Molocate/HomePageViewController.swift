//  HomePageViewController.swift
//  Molocate
import UIKit
import Foundation
import SDWebImage
import CoreLocation
import QuadratTouch
import MapKit
import Haneke
import AVFoundation
var dictionary = NSMutableDictionary()
var myCache = Shared.dataCache
var progressBar: UIProgressView?

class HomePageViewController: UIViewController, UITextFieldDelegate, TimelineControllerDelegate {
   
 
    var tableController: TimelineController!
    var bestEffortAtLocation:CLLocation!
    @IBOutlet var nofollowings: UILabel!
    var direction = 0 // 0 is down and 1 is up
    var location:CLLocation!
    var activityIndicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        
        tableController = self.storyboard?.instantiateViewController(withIdentifier: "timelineController") as! TimelineController
        tableController.type = "HomePage"
        tableController.view.frame = self.view.frame
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);
        tableController.didMove(toParentViewController: self)
        tableController.delegate = self
        
    
        self.navigationItem.titleView = UIImageView(image:  UIImage(named: "molocate"))
        self.navigationItem.titleView?.tintColor = UIColor.white
        
        

        
     
        self.view.addSubview(nofollowings)
        self.nofollowings.isHidden = true
        
        self.view.backgroundColor = swiftColor
        
        if(choosedIndex != 0 && profileOn == 1){
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeProfile"), object: nil)
        }
       NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.showNavigation), name: NSNotification.Name(rawValue: "showNavigation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.showNoFoll), name: NSNotification.Name(rawValue: "showNoFoll"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomePageViewController.hideNoFoll), name: NSNotification.Name(rawValue: "hideNoFoll"), object: nil)
        
        if UIApplication.shared.isIgnoringInteractionEvents {
            UIApplication.shared.endIgnoringInteractionEvents()
            
        }
        
       
     
    }

   
    func pressedUsername(_ username: String, profilePic: URL, isFollowing: Bool) {
        
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
                    
                    //buraya bak
                    controller.RefreshGuiWithData()
                }
                
                //choosedIndex = 0
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
            }
        }
        
    }
    
    func pressedPlace(_ placeId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        let controller:profileVenue = self.storyboard!.instantiateViewController(withIdentifier: "profileVenue") as! profileVenue
        self.navigationController?.pushViewController(controller, animated: true)
        
        MolocatePlace.getPlace(placeId) { (data, response, error) -> () in
            DispatchQueue.main.async{
                thePlace = data
                controller.classPlace = data
                controller.RefreshGuiWithData()
                
                UIApplication.shared.endIgnoringInteractionEvents()
                self.activityIndicator.stopAnimating()
            }
        }
        
        
        
        
    }
    
    func showNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func pressedComment(_ videoId: String, Row: Int) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        video_id = videoId
        videoIndex = Row
      
        myViewController = "HomeController"
        
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

    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "closeSideBar"), object: nil)

    }
    
    
    @IBAction func sideBar(_ sender: AnyObject) {
        if(sideClicked == false){
            sideClicked = true
            NotificationCenter.default.post(name: Notification.Name(rawValue: "openSideBar"), object: nil)
        } else {
            sideClicked = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: "closeSideBar"), object: nil)
        }
    }
    
    func showNoFoll(){
        self.nofollowings.isHidden = false
    }
    func hideNoFoll(){
        self.nofollowings.isHidden = true
    }
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBAction func openCamera(_ sender: AnyObject) {
        
        self.tableController.player1?.stop()
        self.tableController.player2?.stop()
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                let message = NSLocalizedString("Molocate'in konum servislerini kullanmasına izin vermediniz. Lütfen ayarları değiştiriniz.", comment: "" )
                let alertController = UIAlertController(title: "Molocate Konum", message: message, preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: UIAlertActionStyle.cancel, handler: nil)
                alertController.addAction(cancelAction)
                let settingsAction = UIAlertAction(title: NSLocalizedString("Ayarlar", comment: "Alert button to open Settings"), style: UIAlertActionStyle.default) {action in
                    UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
                }
                alertController.addAction(settingsAction)
                self.present(alertController, animated: true, completion: nil)
                
            case .authorizedAlways, .authorizedWhenInUse:
                activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                activityIndicator.center = self.view.center
                activityIndicator.hidesWhenStopped = true
                activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                view.addSubview(activityIndicator)
                activityIndicator.startAnimating()
                UIApplication.shared.beginIgnoringInteractionEvents()
                self.parent!.parent!.performSegue(withIdentifier: "goToCamera", sender: self.parent)
                
            }
        } else {
            displayAlert("Dikkat", message: "Konum servisleriniz aktif değil.")
        }
    

    }


    override func viewWillAppear(_ animated: Bool) {
        (self.parent?.parent!.parent as! ContainerController).scrollView.isScrollEnabled = true
         navigationController?.hidesBarsOnSwipe = true
         tabBarController?.tabBar.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cameraButton.image = nil
        cameraButton.title = "Cancel"
        
    }
    func displayAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction((UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //self.dismissViewControllerAnimated(true, completion: nil)
        })))
        self.present(alert, animated: true, completion: nil)
    }
}
