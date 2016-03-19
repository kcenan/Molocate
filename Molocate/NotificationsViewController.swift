//
//  NotificationsViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 26.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation

class NotificationsViewController: UIViewController,UITableViewDelegate , UITableViewDataSource ,UIToolbarDelegate , UICollectionViewDelegate  ,CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var locationManager: CLLocationManager!
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var toolBar: UIToolbar!
    //var catDictionary = [0:"All",1:"Fun",2:"Food",3:"Travel",4:"Fashion",5:"Sport", 6:"Beauty",7:"Event",8:"University" ]
    
    
    var videoArray = [NSURL]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var players = ["Didier Drogba", "Elmander", "Harry Kewell", "Milan Baros", "Wesley Sneijder"]
    var categories = ["Hepsi","Eğlence","Yemek","Gezinti","Moda" , "Güzellik", "Spor","Etkinlik","Kampüs"]
    var numbers = ["11", "9","19", "15", "10"]
    
    //    let ExploreController:ExploreViewController = ExploreViewController(nibName:"ExploreViewController",bundle: nil)
    //    let FollowingController:FollowingViewController = FollowingViewController(nibName:"ExploreViewController",bundle:nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = true
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        
        dispatch_async(dispatch_get_main_queue()){
            //self.tableView.delegate      =   self
            //self.tableView.dataSource    =   self
            
            //self.view.addSubview(self.tableView)
            
        }
        
        self.view.backgroundColor = swiftColor
        
        
        
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        var rowHeight:CGFloat = 0
        rowHeight = screenSize.width+90
        
        return rowHeight
        
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = notificationCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
        
        
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
    
    
    @IBAction func openCamera(sender: AnyObject) {
        self.parentViewController!.performSegueWithIdentifier("goToCamera", sender: self.parentViewController)
    }
    
    
    // 3
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize.init(width: screenSize.width * 2 / 9, height: 44)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let myCell : myCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! myCollectionViewCell
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
        
        //        let myCell : myCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("myCell", forIndexPath: indexPath) as! myCollectionViewCell
        //
        //            myCell.myLabel.textColor = UIColor.purpleColor()
        
        print(indexPath.row)
        
        
        
        
        //  cell.backgroundColor = UIColor.purpleColor()
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
}


