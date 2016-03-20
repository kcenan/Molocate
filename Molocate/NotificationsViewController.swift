//  NotificationsViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate  {
    var locationManager: CLLocationManager!
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var toolBar: UIToolbar!
    
    var videoArray = [NSURL]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = notificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        cell.myButton.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: "pressedUsername:", forControlEvents: UIControlEvents.TouchUpInside)
        if indexPath.row == 2 {
            cell.myLabel.text = "bir videonuza yorum yazdı"
        }
        if indexPath.row == 3 {
            cell.myLabel.text = "bir videonuzu beğendi"
        }
        if indexPath.row == 4 {
            cell.myLabel.text = "sizi bir videoda ekledi"
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(indexPath.row)
    }
    
    
    func pressedUsername(sender: UIButton) {
        let buttonRow = sender.tag
        print("username e basıldı at index path: \(buttonRow)")
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
        self.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
    }
    override func viewWillAppear(animated: Bool) {
        
    }
    
}

