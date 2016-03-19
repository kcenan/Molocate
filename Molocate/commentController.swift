//
//  commentController.swift
//  Molocate
//
//  Created by MellonCorp on 3/15/16.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class commentController: UIViewController,UITableViewDelegate , UITableViewDataSource {

    var hotels:[String: String] = ["The Grand Del Mar": "5300 Grand Del Mar Court, San Diego, CA 92130",
        "French Quarter Inn": "166 Church St, Charleston, SC 29401",
        "Bardessono": "6526 Yount Street, Yountville, CA 94599",
        "Hotel Yountville": "6462 Washington Street, Yountville, CA 94599",
        "Islington Hotel": "321 Davey Street, Hobart, Tasmania 7000, Australia",
        "The Henry Jones Art Hotel": "25 Hunter Street, Hobart, Tasmania 7000, Australia",
        "Clarion Hotel City Park Grand": "22 Tamar Street, Launceston, Tasmania 7250, Australia",
        "Quality Hotel Colonial Launceston": "31 Elizabeth St, Launceston, Tasmania 7250, Australia",
        "Premier Inn Swansea Waterfront": "Waterfront Development, Langdon Rd, Swansea SA1 8PL, Wales",
        "Hatcher's Manor": "73 Prossers Road, Richmond, Clarence, Tasmania 7025, Australia"]
    
    @IBAction func backButton(sender: AnyObject) {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        
        self.removeFromParentViewController()
    }
    @IBOutlet var toolBar: UIToolbar!
    
    @IBOutlet var tableView: UITableView!
    
    
    
    var hotelNames:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.estimatedRowHeight = 68
        tableView.rowHeight = UITableViewAutomaticDimension
        hotelNames = [String](hotels.keys)
        
        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! commentCell
        
        let hotelName = hotelNames[indexPath.row]
        cell.username.setTitle(hotelName, forState: .Normal)
        cell.comment.text = hotels[hotelName]
        
        return cell
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
