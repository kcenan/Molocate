//
//  Tagged.swift
//  Molocate
//
//  Created by Kagan Cenan on 5.12.2015.
//  Copyright © 2015 MellonApp. All rights reserved.
//

import UIKit

class Tagged: UIViewController , UITableViewDataSource, UITableViewDelegate  {
    var players = ["Didier Drogba", "Elmander", "Harry Kewell", "Milan Baros", "Wesley Sneijder"]
    var numbers = ["11", "9","19", "15", "10"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
   

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRectMake(0, 0, screenSize.width, screenSize.height-190)
        let tableView: UITableView  =   UITableView()
        var scrollPosition = true

    
        tableView.frame         =   CGRectMake(0, 0 , screenSize.width, screenSize.height - 190)
        tableView.delegate      =   self
        tableView.dataSource    =   self
       
        view.addSubview(tableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let rowHeight = screenSize.width + 138
        return rowHeight
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
       //let cell2 = TableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
       // cell.myButton1.addTarget(self, action: "pressedProfile:", forControlEvents: UIControlEvents.TouchUpInside)
       let cell = videoCell(style: UITableViewCellStyle.Default, reuseIdentifier: "myIdentifier")
//        if (indexPath.row < 1){
       // cell2.myButton1.titleLabel?.text = players[indexPath.row]
       //cell.myButton1.addTarget(self, action: "pressedProfile2:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        }
//        else {
      cell.Username.titleLabel?.text = players[indexPath.row]
      
     // cell.Place.text = numbers[indexPath.row]
//        }
                return cell
    }
    func pressedProfile2(sender: UIButton) {
        print("pressedProfile")
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
