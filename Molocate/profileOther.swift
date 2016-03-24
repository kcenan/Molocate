//
//  profileOther.swift
//  Molocate
//
//  Created by Kagan Cenan on 2.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

//post sayısı ve taglenen toplam video sayısı eklenecek(çağatay koymadıysa eklet)


class profileOther: UIViewController , UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    //true ise kendi false başkası
    var who = false
    @IBOutlet var settings: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var username: UILabel!
    @IBOutlet var addedButton: UIButton!
    let AVc :Added =  Added(nibName: "Added", bundle: nil);
    let BVc :Tagged =  Tagged(nibName: "Tagged", bundle: nil);
    @IBOutlet var taggedButton: UIButton!
    
    @IBOutlet var followingsCount: UIButton!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var followersCount: UIButton!
    @IBOutlet var FollowButton: UIBarButtonItem!
    
    @IBAction func FollowButton(sender: AnyObject) {
        
        if(user.username == currentUser.username){
            showTable()
            scrollView.userInteractionEnabled = false
            UIView.animateWithDuration(0.75) { () -> Void in
            }
        }else {
            if !user.isFollowing{
                FollowButton.image = UIImage(named: "tick.png")
                user.isFollowing = true
                Molocate.follow(user.username, completionHandler: { (data, response, error) -> () in
                    print("follow"+data)
                })
            } else {
                FollowButton.image = UIImage(named: "shapes.png")
                user.isFollowing = false
                Molocate.unfollow(user.username, completionHandler: { (data, response, error) -> () in
                    print("unfollow"+data)
                })
            }
            
        }
    }
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    @IBAction func backButton(sender: AnyObject) {
        if(choosedIndex < 3){
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        } else {
            if(sideClicked == false){
                sideClicked = true
                NSNotificationCenter.defaultCenter().postNotificationName("openSideBar", object: nil)
            } else {
                sideClicked = false
                NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil)
            }
        }
        
    }
    
    @IBAction func followersButton(sender: AnyObject) {
        follewersclicked = true
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
        
        
    }
    
    
    
    @IBAction func addedButton(sender: AnyObject) {
        var a :CGRect = AVc.view.frame;
        a.origin.x = 0
        scrollView.setContentOffset(a.origin, animated: true)
    }
    
    @IBAction func taggedButton(sender: AnyObject) {
        let b :CGRect = BVc.view.frame;
        scrollView.setContentOffset(b.origin, animated: true)
    }
    @IBAction func followingsButton(sender: AnyObject) {
        follewersclicked = false
        let controller:Followers = self.storyboard!.instantiateViewControllerWithIdentifier("Followers") as! Followers
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
        
    }
    
    
    @IBOutlet var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.settings.layer.zPosition = 1
        settings.hidden = true
        settings.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.width, self.view.frame.width)
        settings.layer.cornerRadius = 20
        

        
        //       Molocate.follow("kcenan4") { (data, response, error) -> () in
        //
        //            print(data)
        //            Molocate.getFollowings(currentUser.username) { (data, response, error, count, next, previous) -> () in
        //                data[0].printUser()
        //            }
        //        }
        //
        
        addedButton.backgroundColor = swiftColor
        addedButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        taggedButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        taggedButton.backgroundColor = swiftColor3
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
        if who == true{
            FollowButton.enabled = false
        }
        else{
            //eklenebilir
        }
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        scrollView.frame.origin.y = 190
        scrollView.frame.size.height = screenHeight - 190
        
        self.addChildViewController(BVc);
        scrollView.addSubview(BVc.view);
        BVc.didMoveToParentViewController(self)
        
        self.addChildViewController(AVc);
        scrollView.addSubview(AVc.view);
        AVc.didMoveToParentViewController(self)
        
        origin = screenWidth
        scrollWidth = origin*2
        self.scrollView!.contentSize.width = scrollWidth
        
        AVc.view.frame.origin.x = 0
        AVc.view.frame.origin.y = 0
        AVc.view.frame.size.width = screenSize.width + 1
        AVc.view.frame.size.height = scrollView.frame.height
        var adminFrame :CGRect = AVc.view.frame;
        adminFrame.origin.x = screenWidth
        var deneme :CGRect = AVc.view.frame;
        deneme.origin.x = 0
        BVc.view.frame = adminFrame;
        scrollView.setContentOffset(deneme.origin, animated: true)
        
        configureScrollView()
        
        
        
        if(choosedIndex==3){
            user = currentUser
            username.text = user.username
            self.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
            self.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
            self.FollowButton.image = UIImage(named: "shapes.png")
            choosedIndex = 4
        }else{
            
            self.followingsCount.setTitle("\(user.following_count)", forState: .Normal)
            self.followersCount.setTitle("\(user.follower_count)", forState: .Normal)
            if(user.isFollowing){
                self.FollowButton.image = UIImage(named: "tick.png")
            }else{
                self.FollowButton.image = UIImage(named: "shapes.png")
            }
            //choosedIndex = 4
            
            
        }
        
        if(user.profilePic.absoluteString != ""){
            profilePhoto.image = UIImage(named: "profilepic.png")!
            profilePhoto.sd_setImageWithURL(user.profilePic)
//            Molocate.getDataFromUrl(user.profilePic, completion: { (data, response, error) -> Void in
//                dispatch_async(dispatch_get_main_queue()){
//                  self.profilePhoto.image = UIImage(data: data!)!
//                    
//                }
//            })
            //photo.image = UIImage(data: data!)!
        }else{
            profilePhoto.image = UIImage(named: "profilepic.png")!
        }
        
        
    }
    func configureScrollView(){
        scrollView.delegate = self
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        // scrollPosition = !scrollPosition
        if (scrollView.contentOffset.x < BVc.view.frame.origin.x/2){
            
            addedButton.backgroundColor = swiftColor
            taggedButton.backgroundColor = swiftColor3
            addedButton.titleLabel?.textColor = UIColor.whiteColor()
            taggedButton.titleLabel?.textColor = UIColor.blackColor()
        }
        else{
            addedButton.backgroundColor = swiftColor3
            taggedButton.backgroundColor = swiftColor
            taggedButton.titleLabel?.textColor = UIColor.whiteColor()
            addedButton.titleLabel?.textColor = UIColor.blackColor()
            
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(scrollView.contentOffset.x)
        
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            UIView.animateWithDuration(0.75) { () -> Void in
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                self.settings.hidden = true
            }
        }
        if indexPath.row == 1 {
            dispatch_async(dispatch_get_main_queue()) {
                self.scrollView.userInteractionEnabled = true
                self.scrollView.alpha = 1
                
                self.performSegueWithIdentifier("goEditProfile", sender: self)
               
                
                self.settings.hidden = true
            }
        }
        else {
            print("log out yapılacak")
        }
        
        
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return 90
        }
        else{
            return 60
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    var names = ["AYARLAR","PROFİLİ DÜZENLE", "ÇIKIŞ YAP"]
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = optionCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        if indexPath.row == 0 {
            cell.nameOption.frame = CGRectMake(screenSize.width / 2 - 50, 40 , 100, 30)
            cell.nameOption.textAlignment = .Center
            cell.nameOption.textColor = UIColor.blackColor()
            cell.arrow.hidden = true
            
            cell.cancelLabel.hidden = false
            
            
        }
            
        else {
            cell.cancelLabel.hidden = true
        }
        //cell.switchDemo.addTarget(self, action: "switchValueDidChange:", forControlEvents: .ValueChanged)
        //
        cell.nameOption.text = names[indexPath.row]
        cell.backgroundColor = UIColor.whiteColor()
        return cell
        
    }
    //burda notificationları açıp açmadığını kontrol edicez.
    func switchValueDidChange(sender:UISwitch!)
    {
        if (sender.on == true){
            print("on")
            
            
        }
        else{
            print("off")
        }
    }
    func showTable(){
        
        UIView.animateWithDuration(0.25) { () -> Void in
            
            self.settings.hidden = false
            self.settings.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.view.frame.width,self.view.frame.size.width)
            self.scrollView.alpha = 0.4
        }
        
    }
    
}