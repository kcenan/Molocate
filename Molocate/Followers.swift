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
    
    
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    
    @IBOutlet var toolBar: UINavigationBar!
    

    
    var users = [User]()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var myTable: UITableView!
    
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
        self.myTable.frame         =   CGRectMake(0, 60, self.screenSize.width, self.screenSize.height-60);
        if(follewersclicked){
            self.TitleLabel.text = "Followers"
            Molocate.getFollowers(currentUser.username) { (data, response, error, count, next, previous) -> () in
            
                for thing in data{
                self.users.append(thing)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.myTable.reloadData()
                }
            
        }}else{
                self.TitleLabel.text = "Followings"
            Molocate.getFollowings(currentUser.username) { (data, response, error, count, next, previous) -> () in
                
                for thing in data{
                    self.users.append(thing)
                }
                dispatch_async(dispatch_get_main_queue()){
                    self.myTable.reloadData()
                }
                
            }
            
        }
       
            
  
        
       
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
        return users.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       
        let cell = TableViewCellFollowerFollowing(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier2")
        cell.myButton1.setTitle("\(users[indexPath.row].username)", forState: .Normal)
        print(users[indexPath.row].username)
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
       
            self.willMoveToParentViewController(nil)
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
            
            
        }
    }
    
    
    
    


}
