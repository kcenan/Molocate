//
//  FilterController.swift
//  Molocate
//
//  Created by Kagan Cenan on 16.09.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class FilterController: UIViewController,TimelineControllerDelegate  {
    
    var tableController: TimelineController!
    var activityIndicator = UIActivityIndicatorView()
    var filter_name = ""
    var filter_raw = ""
    var classLat = Float()
    var classLon = Float()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = true
        
        tableController = self.storyboard?.instantiateViewController(withIdentifier: "timelineController") as! TimelineController
        tableController.filter_raw = self.filter_raw
        tableController.type = "filter"
        if filter_raw == "nearby" {
            tableController.isNearby = true
            tableController.classLon = classLon
            tableController.classLat = classLat
        } else {
            tableController.isNearby = false
        }
        tableController.view.frame = self.view.frame
        tableController.view.layer.zPosition = 0
        self.view.addSubview(tableController.view)
        self.addChildViewController(tableController);
        tableController.didMove(toParentViewController: self)
        tableController.delegate = self
        self.navigationItem.title = self.filter_name
        self.navigationController?.hidesBarsOnSwipe = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
