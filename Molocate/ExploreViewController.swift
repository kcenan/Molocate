//
//  ExploreViewController.swift
//  Molocate
//
//  Created by Kagan Cenan on 15.11.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit

var scrollWidth: CGFloat = 0.0
var scrollHeight: CGFloat = 0.0

class ExploreViewController: UIViewController, UITableViewDelegate, UIToolbarDelegate{
    
    var willcamera = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds

    @IBOutlet var tableView: UITableView!
    
var newarray = ["asasad" , "sdasdasdsa" , "dsasaddas", "dsakjjsadjdsakljklj", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
         tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)}
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = screenSize.width + 90
        return rowHeight
    }
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.newarray.count
    }
    
    
    
    
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        //swipe geçişleri için
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: "swiped:")
//        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
//        self.view.addGestureRecognizer(swipeRight)
//         let swipeLeft = UISwipeGestureRecognizer(target: self, action: "swiped:")
//        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
//        self.view.addGestureRecognizer(swipeLeft)
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    
    
    
    //yana swipe yaparak kaydırma için fonksiyon
//    func swiped(gesture : UISwipeGestureRecognizer){
//        
//        if let swipeGesture = gesture as? UISwipeGestureRecognizer{
//        
//            switch swipeGesture.direction {
//            
//            case UISwipeGestureRecognizerDirection.Right:
//                
//                  let slideInFromLeftTransition = CATransition()
//                  // Customize the animation's properties
//                  slideInFromLeftTransition.type = kCATransitionPush
//                  slideInFromLeftTransition.subtype = kCATransitionFromLeft
//                  slideInFromLeftTransition.duration = 0.5
//                  slideInFromLeftTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//                  slideInFromLeftTransition.fillMode = kCAFillModeRemoved
//                  willcamera = true
//                  // Add the animation to the View's layer
//                  self.navigationController?.view.layer.addAnimation(slideInFromLeftTransition, forKey: "slideInFromLeftTransition")
//                  
//                  performSegueWithIdentifier("swipeRight", sender: self)
//            case UISwipeGestureRecognizerDirection.Left:
//                
//                performSegueWithIdentifier("swipeLeft", sender: self)
//                
//            default:
//                break
//            
//            }
//        }
//    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
      //  NSURLCache.sharedURLCache().removeAllCachedResponses()
      //  print("MEMORY WARNING RECEIVED!")
    }
    

    @IBAction func sideBar(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("openSideBar", object: nil)
    }
   

    // MARK: - Table view data source

//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 3
//    }
//
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
//        cell.textLabel?.text = "sdafa"
//        // Configure the cell...
//        
//        return cell
//        
//    }


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
