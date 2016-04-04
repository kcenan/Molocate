//
//  Followers.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit

var follewersclicked: Bool = true

class Followers: UIViewController ,  UITableViewDataSource, UITableViewDelegate{
    
    var activityIndicator = UIActivityIndicatorView()
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    
    @IBOutlet var toolBar: UINavigationBar!
    

    var classUser = User()
    var users = [User]()
    var followings = [following]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var myTable: UITableView!
    var follower = true
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        //toolBar.
        //self.navigationController?.navigationBarHidden = false
        myTable =   UITableView()
        self.navigationController?.navigationBar.hidden = false
        self.myTable.delegate      =   self
        self.myTable.dataSource    =   self
        self.view.addSubview(myTable)
        myTable.tableFooterView = UIView()
        
        myTable.allowsSelection = false
        self.myTable.frame         =   CGRectMake(0, 60, self.screenSize.width, self.screenSize.height-60);
        if(follewersclicked){
            self.TitleLabel.text = "Takipçi"
            self.TitleLabel.textColor = UIColor.whiteColor()
            self.TitleLabel.font = UIFont(name: "AvenirNext-Regular", size: (self.TitleLabel.font?.pointSize)!)
            Molocate.getFollowers(classUser.username) { (data, response, error, count, next, previous) -> () in
            
                for thing in data{
                self.users.append(thing)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.myTable.reloadData()
                }
            
        }}else{
                follower = false
                self.TitleLabel.text = "Takip"
                self.TitleLabel.textColor = UIColor.whiteColor()
                self.TitleLabel.font = UIFont(name: "AvenirNext-Regular", size: (self.TitleLabel.font?.pointSize)!)
            Molocate.getFollowings(classUser.username) { (data, response, error, count, next, previous) -> () in
                
                for thing in data{
                    self.followings.append(thing)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.myTable.reloadData()
                }
                
            }
            
        }
       
            
        
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight : CGFloat = 60
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count+followings.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")

        if follower {
            cell.myButton1.setTitle("\(users[indexPath.row].username)", forState: .Normal)
            if(users[indexPath.row].profilePic.absoluteString != ""){
                cell.fotoButton.sd_setImageWithURL(users[indexPath.row].profilePic, forState: UIControlState.Normal)
            }
        cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            cell.myButton1.setTitle("\(followings[indexPath.row].username)", forState: .Normal)
            if(followings[indexPath.row].picture_url.absoluteString != ""){
                cell.fotoButton.sd_setImageWithURL(followings[indexPath.row].picture_url, forState: UIControlState.Normal)
            }
            if followings[indexPath.row].type == "place" {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedPlace(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            } else {
                cell.myButton1.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.fotoButton.addTarget(self, action: #selector(Followers.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
        cell.myButton1.tag = indexPath.row
        cell.fotoButton.tag = indexPath.row
        //print(users[indexPath.row].isFollowing)
        cell.myLabel1.hidden = true
        cell.myLabel1.enabled = false
//        if(follewersclicked && user.username == currentUser.username && !users[indexPath.row].isFollowing){
//         cell.myLabel1.hidden = false
//         cell.myLabel1.tag = indexPath.row
//         cell.myLabel1.addTarget(self, action: #selector(Followers.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//          
//        }else{
//            cell.myLabel1.hidden = true
//        }
        return cell

    }
    
    func pressedFollow(sender: UIButton) {
        let buttonRow = sender.tag
        print("followa basıldı at index path: \(buttonRow) ")
        self.users[buttonRow].isFollowing = true
        var indexes = [NSIndexPath]()
        let index = NSIndexPath(forRow: buttonRow, inSection: 0)
        indexes.append(index)
        self.myTable.reloadRowsAtIndexPaths(indexes, withRowAnimation: .None)
        
        Molocate.follow(users[buttonRow].username){ (data, response, error) -> () in
            print(data)
        }
        
    }
    
    func pressedProfile(sender: UIButton) {
        //print("pressedProfile")
        let buttonRow = sender.tag
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        var username = ""
        if follower {
            username = users[buttonRow].username
        } else {
            username = followings[buttonRow].username
        }
        Molocate.getUser(username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        controller.username.text = user.username
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        self.activityIndicator.removeFromSuperview()
            }
    }
    }
    
    func pressedPlace(sender: UIButton) {
        let buttonRow = sender.tag
//        print("place e basıldı at index path: \(buttonRow) ")
//        print("================================" )
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        Molocate.getPlace(followings[buttonRow].place_id) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                thePlace = data
                let controller:profileLocation = self.storyboard!.instantiateViewControllerWithIdentifier("profileLocation") as! profileLocation
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                self.view.addSubview(controller.view)
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
                self.activityIndicator.removeFromSuperview()
            }
        }
        
    }

   
    
    @IBAction func back(sender: AnyObject) {
         dispatch_async(dispatch_get_main_queue()) {
       
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        users.removeAll()
        followings.removeAll()
    }
    
    
    
    


}
