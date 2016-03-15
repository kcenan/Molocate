//
//  Followers.swift
//  Molocate
//
//  Created by Kagan Cenan on 11.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit

class Followers: UIViewController ,  UITableViewDataSource, UITableViewDelegate{
    
    
    
    
    
    var players = ["Hamza Hamzaoğlu","Jem Paul Karacan", "Umut Bulut", "Sabri Sarıoğlu", "Ceyhun Gülselam"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     

        //self.navigationController?.navigationBarHidden = false
        let tableView: UITableView  =   UITableView()
        self.navigationController?.navigationBar.hidden = false
        tableView.frame         =   CGRectMake(0, 60, screenSize.width, screenSize.height-60);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        view.addSubview(tableView)
//        dispatch_async(dispatch_get_main_queue()) {
//            Molocate.getFollowers(currentUser.username, completionHandler: { (data, response, error, count, next, previous) -> () in
//                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//                for thing in data{
//                    
//                }
//            })
//            
//  
//        }
       
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
        return players.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        cell.myButton1.setTitle("\(players[indexPath.row])", forState: .Normal)
        print(players[indexPath.row])
        cell.myButton1.addTarget(self, action: "pressedProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.fotoButton.addTarget(self, action: "pressedProfile2:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        
    }
    
    func pressedProfile2(sender: UIButton) {
        print("pressedProfile")
        let controller:profileOther = self.storyboard!.instantiateViewControllerWithIdentifier("profileOther") as! profileOther
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controller.view.frame = self.view.bounds;
        controller.willMoveToParentViewController(self)
        self.view.addSubview(controller.view)
        self.addChildViewController(controller)
        controller.didMoveToParentViewController(self)
    }
   
    func pressedProfile(sender: UIButton) {
        print("pressedProfile değil")
    }
    
    
    @IBAction func back(sender: AnyObject) {
         dispatch_async(dispatch_get_main_queue()) {
        //self.performSegueWithIdentifier("backFromFollowers", sender: self)
        //choosedIndex = 3
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
    }
    
    
    
    


}
