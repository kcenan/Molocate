//
//  SideBarController.swift
//  Molocate
//
//  Created by Kagan Cenan on 14.01.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

var choosedIndex = 100

class SideBarController: UITableViewController {

    var menuArray = ["Haber Kaynağı","Keşfet","Activities","Profile"]
   var tableData: [String] = ["home.png", "explore.png", "people.png", "sound.png"]
    let cellIdentifier = "cell"
    var attractionImages = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //self.tableView.frame.size.height =
        self.tableView.separatorColor = UIColor.clearColor()
        self.tableView.backgroundColor = swiftColor2
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var rowHeight:CGFloat = 0
        if indexPath.row == 0{
        rowHeight = screenSize.height / 8 + 26
            return rowHeight
        }
        else{
        rowHeight = screenSize.height/8 + 4
            return rowHeight
        }
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
       //let cell = sideCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cellIdentifier")
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! sideCell
        cell.label?.text = self.menuArray[indexPath.row]
     
       // var imageView = UIImageView(image: image!)
        cell.imageFrame.image = UIImage(named: tableData[indexPath.row])
        cell.label.textColor = UIColor.whiteColor()
        // Configure the cell...
        cell.backgroundColor = swiftColor2
        cell.label.sizeToFit()
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print(self.parentViewController?.description)
        //self.parentViewController.
        choosedIndex = indexPath.row
        self.parentViewController?.childViewControllers[1].childViewControllers[0].tabBarController?.selectedIndex = indexPath.row
        NSNotificationCenter.defaultCenter().postNotificationName("closeSideBar", object: nil )
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
