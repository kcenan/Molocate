//
//  commentController.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource {

    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var tableView: UITableView!
    
  var players = ["Hamza Hamzaoğlu","Jem Paul Karacan", "Umut Bulut", "Sabri Sarıoğlu", "Ceyhun Gülselam"]
    
    @IBAction func back(sender: AnyObject) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

     
        
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = commentCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
         print(players[indexPath.row])
       cell.commentUser.setTitle("\(self.players[indexPath.row])", forState: .Normal)
       
        
        cell.commentUser.addTarget(self, action: "pressedProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.profileImage.addTarget(self, action: "pressedProfile:", forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
        

        
    }
//
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
