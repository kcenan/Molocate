//
//  likeVideo.swift
//  Molocate
//
//  Created by Kagan Cenan on 18.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class likeVideo: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet var toolBar: UIToolbar!
    let cellIdentifier = "cell5"
    var users = [User]()
    
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBAction func backButton(sender: AnyObject) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toolBar.barTintColor = swiftColor
        toolBar.translucent = false
        toolBar.clipsToBounds = true
        
        self.navigationController?.navigationBar.hidden = false
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        
        print(video_id)
        Molocate.getLikes(video_id) { (data, response, error, count, next, previous) -> () in
            
            self.users.removeAll()
            dispatch_async(dispatch_get_main_queue()){
                for thing in data{
                    self.users.append(thing)
                    thing.printUser()
                }
                self.tableView.reloadData()
            }
            
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! likeVideoCell
        
        cell.username.setTitle("\(self.users[indexPath.row].username)", forState: .Normal)
        cell.username.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        
        if(!users[indexPath.row].isFollowing && users[indexPath.row].username != currentUser.username){
            
        }else{
            cell.followLike.hidden = true
        }
        cell.profileImage.layer.borderWidth = 0.1
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        
        
        if(users[indexPath.row].profilePic.absoluteString != ""){
            cell.profileImage.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
            print(users[indexPath.row].profilePic.absoluteString)
            Molocate.getDataFromUrl(users[indexPath.row].profilePic, completion: { (data, response, error) -> Void in
                dispatch_async(dispatch_get_main_queue()){
                    
                    cell.profileImage.setBackgroundImage(UIImage(data: data!)!, forState:
                        UIControlState.Normal)
                    
                }
            })
            //photo.image = UIImage(data: data!)!
        }else{
            cell.profileImage.setBackgroundImage(UIImage(named: "profilepic.png")!, forState:
                UIControlState.Normal)
        }
        cell.username.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        cell.profileImage.addTarget(self, action: #selector(likeVideo.pressedProfile(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        //burda follow ediyosa buttonu hidden etmesi lazım
        cell.followLike.addTarget(self, action: #selector(likeVideo.pressedFollow(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
        
        
    }
    func pressedProfile(sender: UIButton) {
        let buttonRow = sender.tag
        print("pressed profile")
        
        Molocate.getUser(users[buttonRow].username) { (data, response, error) -> () in
            dispatch_async(dispatch_get_main_queue()){
                user = data
                let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
                controller.view.frame = self.view.bounds;
                controller.willMoveToParentViewController(self)
                controller.username.text = user.username
                
                self.view.addSubview(controller.view)
                
                self.addChildViewController(controller)
                controller.didMoveToParentViewController(self)
            }
        }
    }
    
    func pressedFollow(sender: UIButton) {
        print("pressedfollow")
        
    }
    //
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
