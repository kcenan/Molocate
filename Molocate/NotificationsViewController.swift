//  NotificationsViewController.swift
//  Molocate


import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate  {
    var locationManager: CLLocationManager!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    var notificationArray = [notifications]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.separatorColor = UIColor.blackColor()
        Molocate.getNotifications(NSURL()) { (data, response, error) -> () in
            
            dispatch_async(dispatch_get_main_queue()){
                for item in data!{
                   self.notificationArray.append(item)
                   
                }
                self.tableView.reloadData()
            }
            
        }
        self.tabBarController?.tabBar.hidden = true
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        self.view.backgroundColor = swiftColor
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 54
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notificationArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = notificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        cell.myButton.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
     
        cell.myButton.setTitle(notificationArray[indexPath.row].actor, forState: UIControlState.Normal)
        let buttonWidth = cell.myButton.intrinsicContentSize().width
        cell.myButton.frame = CGRectMake(44 , 10 , buttonWidth + 5  , 34)
        cell.myButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        cell.myButton.contentHorizontalAlignment = .Left
        cell.myButton.setTitleColor(swiftColor, forState: UIControlState.Normal)
        if(notificationArray[indexPath.row].picture_url.absoluteString != ""){
        cell.fotoButton.sd_setImageWithURL(notificationArray[indexPath.row].picture_url, forState: UIControlState.Normal)
        }
        cell.contentView.addSubview(cell.myButton)
        
        cell.myLabel = UILabel()
        cell.myLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell.myLabel.text = notificationArray[indexPath.row].sentence // sample label text
        cell.myLabel.textAlignment = .Left
        cell.myLabel.frame = CGRectMake(buttonWidth + 49 , 10 , screenSize.width - buttonWidth - 52 , 34)
        cell.myLabel.numberOfLines = 1
        cell.contentView.addSubview(cell.myLabel)
        
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
        let controller:oneVideo = self.storyboard!.instantiateViewControllerWithIdentifier("oneVideo") as! oneVideo
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
    
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        controller.view.frame = self.view.bounds
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
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
         if (isUploaded) {
        self.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
        }
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    
}

