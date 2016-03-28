//
//  oneVideo.swift
//  Molocate
//
//  Created by Kagan Cenan on 22.03.2016.
//  Copyright © 2016 MellonApp. All rights reserved.
//

import UIKit

class oneVideo: UIViewController {

    @IBAction func backButton(sender: AnyObject) {
        
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.toolBar.clipsToBounds = true
        self.toolBar.translucent = false
        self.toolBar.barTintColor = swiftColor
        // Do any additional setup after loading the view.
    }
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
       
        return screenSize.width + 150
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let cell = videoCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        
        return cell
    }


}
