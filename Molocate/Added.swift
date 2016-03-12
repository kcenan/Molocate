//
//  Added.swift
//  Molocate
//
//  Created by Kagan Cenan on 5.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit

class Added: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var newarray = ["asasad" , "sdasdasdsa" , "dsasaddas", "dsakjjsadjdsakljklj", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk", "asdjkdsajksdsadjk"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-190)
        let tableView: UITableView  =   UITableView()
        
       // tableView.center = CGPointMake(screenSize.width/2,screenSize.height/2)
        tableView.frame         =   CGRectMake(0, 0 , screenSize.width, screenSize.height - 190);
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
  
       
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let rowHeight = screenSize.width + 138
        return rowHeight
    }
    internal func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
    return self.newarray.count
    }
    

    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        cell.textLabel?.text = self.newarray[indexPath.row]
        
        return cell
    }
//
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
