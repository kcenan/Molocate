//
//  profileLocation.swift
//  Molocate
//
//  Created by Kagan Cenan on 23.02.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class profileLocation: UIViewController {

    @IBOutlet var tableView: UITableView!
    

    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var followButton: UIBarButtonItem!
   
    @IBOutlet var toolBar: UIToolbar!
    @IBAction func followButton(sender: AnyObject) {
        
        
    }
    @IBOutlet var followerCount: UIButton!
    
    @IBAction func followersButton(sender: AnyObject) {
    }
    
    var players = ["Hamza Hamzaoğlu","Jem Paul Karacan", "Umut Bulut", "Sabri Sarıoğlu", "Ceyhun Gülselam"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = swiftColor3
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight : CGFloat = 108 + screenSize.width
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = videoCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        cell.Username.titleLabel?.text = "sadsda"
        print(players[indexPath.row])
        cell.reportButton.addTarget(self, action: "report:", forControlEvents: UIControlEvents.TouchUpInside)
        //cell.Place.text = "dsakjldsajkldsa"
        
        return cell
    }
    
    func report(sender: UIButton) {
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
    
    
//    @IBAction func back(sender: AnyObject) {
//        dispatch_async(dispatch_get_main_queue()) {
//            self.performSegueWithIdentifier("backFromFollowers", sender: self)
//            choosedIndex = 3
//            
//        }
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
