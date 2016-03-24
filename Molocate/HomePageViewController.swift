//
//  HomePageViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import AVFoundation

class HomePageViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate ,CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var nextURL:NSURL!
    var cache:NSMutableDictionary!
    @IBOutlet var tableView: UITableView!
  
    @IBOutlet var toolBar: UIToolbar!
    //var catDictionary = [0:"All",1:"Fun",2:"Food",3:"Travel",4:"Fashion",5:"Sport", 6:"Beauty",7:"Event",8:"University" ]
    
    
    var videoArray = [videoInf]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    
    //    let ExploreController:ExploreViewController = ExploreViewController(nibName:"ExploreViewController",bundle: nil)
    //    let FollowingController:FollowingViewController = FollowingViewController(nibName:"ExploreViewController",bundle:nil)
    override func viewDidLoad() {
        super.viewDidLoad()

        //dispatch_async(dispatch_get_main_queue()){
//        if(mole.follow("kcenan")){
//            print("followladı")
//        } else {
//            print("hata var dayı")
//    }}
        cache = NSMutableDictionary(capacity: 1000*1024*1024)
        
        
        self.tabBarController?.tabBar.hidden = true
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.view.backgroundColor = swiftColor
       
        do {
            
            
            
            // create post request
            let url = NSURL(string: "http://molocate-py3.hm5xmcabvz.eu-central-1.elasticbeanstalk.com/video/api/explore/all/")!
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            
            // insert json data to the request
            //print(userToken)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("Token "+userToken!, forHTTPHeaderField: "Authorization")
            
            
            //                let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ data, response, error in
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(request){ (data, response, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue(), {
                    //print(response)
                    //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    
                    if error != nil{
                        print("Error -> \(error)")
                        
                        //return
                    }
                    
                    do {
                        let result = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
                        
                        //print("Result -> \(result)")
                        if(result["count"] as! Int != 0){
                        let videos = result["results"] as! NSArray
                        
                        
                        if result["next"] is NSNull {
                            print("next is null")
                            self.nextURL = nil
                        }else {
                            let nextStr = result["next"] as! String
                            //print(nextStr)
                            self.nextURL = NSURL(string: nextStr)
                        }
                        for item in videos {
                            
                            var videoStr = videoInf()
                            let urlString = item["video_url"] as! String
                            let url = NSURL(string: urlString)
                            videoStr.urlSta = url!
                            let username = item["current_username"] as! String
                            videoStr.username = username
                            self.videoArray.append(videoStr)
                            
                            
                        }
                        
                        }else{
                            //videos = [videoInf]()
                        }
                        
                        
                        
                    } catch {
                        print("Error -> \(error)")
                    }
                    self.tableView.reloadData()
                    
                })
                
                
            }
            task.resume()
            
            
            
            
            
        } catch {
            print(error)
            
            
        }

        
        
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
            return  screenSize.width + 138
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4 //videoArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = videoCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")

        if((cache.objectForKey(NSString(format: "key%lu", indexPath.row))) != nil){
            let player = cache.objectForKey(NSString(format: "key%lu", indexPath.row)) as! AVPlayer
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = cell.newRect
            cell.layer.addSublayer(playerLayer)
            //cell.player.play()
            
            
            
            
        }else{
            //            var playerView = AVPlayerViewController()
            //            var player = AVPlayer(URL: videoArray[videoArray.count-indexPath.row-1].urlSta)
            //            playerView.player = player
            //            var y = (cell.gap*2)+cell.labelHeight
            //            var newRect = CGRect(x: 0, y: y, width: cell.screenSize.width, height: cell.screenSize.width)
            //            playerView.view.layer.frame = newRect
            ////            var playerLayer = AVPlayerLayer()
            ////            playerLayer.frame = newRect
            ////            playerLayer.videoGravity = AVLayerVideoGravityResizeAspect
            ////            cell.layer.addSublayer(playerLayer)
            //            cell.addSubview(playerView.view)
            //            player.play()
            cell.reportButton.tag = indexPath.row
            cell.reportButton.addTarget(self, action: "pressedReport:", forControlEvents: UIControlEvents.TouchUpInside)
           // let tableVideoURL = videoArray[indexPath.row].urlSta
          //  let player = AVPlayer(URL: tableVideoURL)
            //let playerLayer = AVPlayerLayer(player: player)
           // playerLayer.frame = cell.newRect
          //  cell.layer.addSublayer(playerLayer)
            //cell.exploreAddView()
            //cell.play()
            //cache.setValue(player, forKey: NSString(format: "key%lu", indexPath.row) as String)
            //cell.Username.setTitle("usernamesi", forState: .Normal)
            //cell.Username.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            cell.Username.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        }


        
            return cell
           }
    
   
    func pressedReport(sender: UIButton) {
        //kaçıncı tableView celli orduğunu tanımladım
        let buttonRow = sender.tag
        print("pressedReport at index path: \(buttonRow)")
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        //Create and add first option action
        let reportVideo: UIAlertAction = UIAlertAction(title: "Report the Video", style: .Default) { action -> Void in
            //Code for launching the camera goes here
            print("reported")
        }
        actionSheetController.addAction(reportVideo)
        
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBarFast", object: nil)
        
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
         if (isUploaded) {
        self.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
        }
    }
    
   
   
    
        
}


